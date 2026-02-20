import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/backend/user_database.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/logic/logic.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/models/payment_model.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/models/user_model.dart';
import 'package:share_plus/share_plus.dart';

/// Invoice Generator Utility
///
/// Production-ready PDF invoice generator that creates professional invoices
/// using the logged-in user's data as company information.
///
/// Features:
/// - Automatic user data fetching
/// - Professional invoice layout
/// - Share, print, and save functionality
/// - Error handling and validation
/// - File management utilities
class InvoiceGenerator {
  // Cache user data to avoid repeated database calls
  static User? _cachedUser;
  static DateTime? _cacheTime;
  static const Duration _cacheValidity = Duration(minutes: 5);

  /// Get current user data with caching
  static Future<User> _getCurrentUser() async {
    // Check cache validity
    if (_cachedUser != null &&
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!) < _cacheValidity) {
      return _cachedUser!;
    }

    // Fetch fresh user data
    try {
      final User users = await UserBackEnd.fetchUserData();

      _cachedUser = users;
      _cacheTime = DateTime.now();

      return _cachedUser!;
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      rethrow;
    }
  }

  /// Clear cached user data (call after user updates profile)
  static void clearUserCache() {
    _cachedUser = null;
    _cacheTime = null;
  }

  /// Generate a professional PDF invoice for a transaction
  ///
  /// Automatically uses the logged-in user's name as company name.
  ///
  /// Parameters:
  /// - [transaction]: The transaction details
  /// - [customer]: The customer information
  /// - [userCurrency]: Optional currency symbol (fetched from user if not provided)
  ///
  /// Returns the file path of the generated PDF
  ///
  /// Throws:
  /// - [Exception] if user data cannot be fetched
  /// - [Exception] if file cannot be saved
  static Future<String> generateInvoice({
    required Trx transaction,
    required Customer customer,
    String? userCurrency,
  }) async {
    // Fetch user data
    final User user = await _getCurrentUser();
    final List<Payment> payments =
        await BackEnd.fetchRequriedPaymentsOfTransaction(
          transactionId: transaction.id!,
        );

    // Get currency if not provided
    final String currency = userCurrency ?? user.userCurrency;

    // Validate inputs
    if (transaction.id == null) {
      throw ArgumentError('Transaction ID cannot be null');
    }
    if (customer.name.trim().isEmpty) {
      throw ArgumentError('Customer name cannot be empty');
    }

    ByteData data = await rootBundle.load("assets/fonts/Helvetica.ttf");
    ByteData font = data.buffer.asByteData();
    ByteData dataBold = await rootBundle.load(
      "assets/fonts/Helvetica-Bold.ttf",
    );
    ByteData fontBold = dataBold.buffer.asByteData();
    try {
      final pw.Document pdf = pw.Document(
        theme: pw.ThemeData.withFont(
          base: pw.Font.ttf(font),
          bold: pw.Font.ttf(fontBold),
        ),
      );

      // Calculate loan details with validation
      final loanCalculator = transaction.transacrtionType == Constant.active
          ? LoanCalculator(
              takenAmount: transaction.amount,
              rateOfInterest: transaction.intrestRate,
              takenDate: transaction.transacrtionDate,
              tenureDate: DateTime.now(),
            )
          : LoanCalculator(
              takenAmount: transaction.amount,
              rateOfInterest: transaction.intrestRate,
              takenDate: transaction.transacrtionDate,
              tenureDate: payments.first.paymentDate,
            );

      // Format dates
      final transactionDate = _formatDate(
        transaction.transacrtionDate.toIso8601String(),
      );
      final generatedDate = DateFormat(
        'dd-MM-yyyy HH:mm',
      ).format(DateTime.now());

      // Build PDF pages
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // Header with user data
              _buildHeader(companyName: user.userName),

              pw.SizedBox(height: 20),

              // Invoice Title and Info
              _buildInvoiceInfo(
                transactionId: transaction.id!,
                transactionDate: transactionDate,
                generatedDate: generatedDate,
              ),

              pw.SizedBox(height: 20),

              // Customer Details
              _buildCustomerDetails(customer),

              pw.SizedBox(height: 20),

              // Transaction Details Table
              _buildTransactionDetailsTable(
                transaction: transaction,
                loanCalculator: loanCalculator,
                currency: currency,
              ),

              pw.SizedBox(height: 20),

              // Summary Section
              _buildSummary(transaction, loanCalculator, currency),

              pw.SizedBox(height: 30),

              // Terms and Conditions
              _buildTermsAndConditions(transaction.signature),

              pw.SizedBox(height: 20),

              // Footer
              _buildFooter(generatedDate, user.userName),
            ];
          },
        ),
      );

      // Save PDF to file
      final output = await _savePdfToFile(
        pdf: pdf,
        fileName:
            'Invoice_${transaction.id}_${customer.name.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );

      return output;
    } catch (e) {
      debugPrint('Error generating invoice: $e');
      throw Exception('Failed to generate invoice: ${e.toString()}');
    }
  }

  /// Share the invoice PDF
  ///
  /// Automatically fetches user data for company information
  static Future<void> shareInvoice({required Trx transaction}) async {
    try {
      final List<Customer> customerResponce =
          await BackEnd.fetchSingleContactDetails(id: transaction.customerId);

      final Customer customer = customerResponce.first;

      final String filePath = await generateInvoice(
        transaction: transaction,
        customer: customer,
      );

      final xFile = XFile(filePath);
      ShareParams s = ShareParams(
        files: [xFile],
        subject: 'Transaction Invoice #${transaction.id}',
        text: 'Invoice for ${customer.name} - Transaction #${transaction.id}',
      );
      await SharePlus.instance.share(s);
      await deleteInvoice(filePath);
    } catch (e) {
      debugPrint('Error sharing invoice: $e');
      rethrow;
    }
  }

  // Private helper methods

  static pw.Widget _buildHeader({required String companyName}) {
    return pw.Container(
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(width: 2, color: PdfColors.blue700),
        ),
      ),
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                companyName,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue700,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Finance Services',
                style: const pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'TRANSACTION INVOICE',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildInvoiceInfo({
    required int transactionId,
    required String transactionDate,
    required String generatedDate,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey200,
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Invoice #: TXN-$transactionId',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Transaction Date: $transactionDate',
                style: const pw.TextStyle(fontSize: 10),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Generated: $generatedDate',
                style: const pw.TextStyle(fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildCustomerDetails(Customer customer) {
    late Uint8List imageBytes;
    late pw.MemoryImage pdfImage;
    if (customer.photo.isNotEmpty) {
      imageBytes = File(customer.photo).readAsBytesSync();
      pdfImage = pw.MemoryImage(imageBytes);
    }
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'CUSTOMER DETAILS',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue700,
            ),
          ),
          pw.SizedBox(height: 10),

          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Name:', customer.name),
                    pw.SizedBox(height: 4),
                    _buildDetailRow('Guardian:', customer.guardianName),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Contact:', customer.number),
                    pw.SizedBox(height: 4),
                    _buildDetailRow('Address:', customer.address),
                  ],
                ),
              ),
              if (customer.photo.isNotEmpty)
                pw.Image(pdfImage, height: 80, width: 80),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTransactionDetailsTable({
    required Trx transaction,
    required LoanCalculator loanCalculator,
    required String currency,
  }) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.blue700),
          children: [
            _buildTableCell('Description', isHeader: true),
            _buildTableCell('Details', isHeader: true),
          ],
        ),
        // Rows
        _buildTableRow('Transaction ID', '#${transaction.id}'),
        _buildTableRow('Status', transaction.transacrtionType),
        _buildTableRow(
          'Principal Amount',
          '$currency ${Utility.doubleFormate(transaction.amount)}',
        ),
        _buildTableRow(
          'Interest Rate',
          '${transaction.intrestRate}% per month',
        ),
        _buildTableRow(
          'Transaction Date',
          _formatDate(transaction.transacrtionDate.toIso8601String()),
        ),
        if (transaction.transacrtionType == Constant.inactive)
          _buildTableRow(
            'Payment Date',
            DateFormat('dd-MM-yyyy HH:mm').format(loanCalculator.tenureDate!),
          ),
        _buildTableRow('Duration', loanCalculator.monthsAndRemainingDays),
        _buildTableRow(
          'Interest Per Month',
          '$currency ${Utility.doubleFormate(loanCalculator.interestPerDay * 30)}',
        ),
        _buildTableRow(
          'Total Interest',
          '$currency ${Utility.doubleFormate(loanCalculator.totalInterestAmount)}',
        ),
      ],
    );
  }

  static pw.Widget _buildSummary(
    Trx transaction,
    LoanCalculator loanCalculator,
    String currency,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        border: pw.Border.all(color: PdfColors.blue700, width: 2),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            transaction.transacrtionType == Constant.active
                ? 'TOTAL AMOUNT PAYABLE'
                : 'TOTAL AMOUNT PAID',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue700,
            ),
          ),
          pw.Text(
            '$currency ${Utility.doubleFormate(loanCalculator.totalAmount)}',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTermsAndConditions(String signaturePath) {
    late Uint8List imageBytes;
    late pw.MemoryImage pdfImage;
    if (signaturePath.isNotEmpty) {
      imageBytes = File(signaturePath).readAsBytesSync();
      pdfImage = pw.MemoryImage(imageBytes);
    }
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'TERMS & CONDITIONS',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                '1. Interest is calculated on a monthly basis from the transaction date.',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                '2. The borrower agrees to repay the total amount as per the agreed terms.',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                '3. All data is stored locally and is the responsibility of the app user.',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                '4. This document is generated electronically and is invalid without signature.',
                style: const pw.TextStyle(fontSize: 9),
              ),
            ],
          ),
          pw.Column(
            children: [
              if (signaturePath.isNotEmpty)
                pw.Image(pdfImage, height: 48, width: 48),
              pw.Text('Signature'),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(String generatedDate, String userName) {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey400),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Generated by $userName',
              style: pw.TextStyle(
                fontSize: 8,
                color: PdfColors.grey600,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              generatedDate,
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
          ],
        ),
        pw.SizedBox(height: 5),
        pw.Center(
          child: pw.Text(
            'Thank you for your business',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue700,
            ),
          ),
        ),
      ],
    );
  }

  // Helper widgets

  static pw.Widget _buildDetailRow(String label, String value) {
    return pw.Row(
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(width: 5),
        pw.Expanded(
          child: pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
        ),
      ],
    );
  }

  static pw.TableRow _buildTableRow(String label, String value) {
    return pw.TableRow(
      children: [_buildTableCell(label), _buildTableCell(value)],
    );
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.white : PdfColors.black,
        ),
      ),
    );
  }

  // Utility methods

  static String _formatDate(String dateString) {
    try {
      // Try parsing as DD-MM-YYYY format
      final parts = dateString.split('-');
      if (parts.length == 3) {
        return dateString;
      }
      // If it's already formatted differently, return as is
      return dateString;
    } catch (e) {
      return dateString;
    }
  }

  static Future<String> _savePdfToFile({
    required pw.Document pdf,
    required String fileName,
  }) async {
    final bytes = await pdf.save();

    // Get the downloads directory or documents directory
    Directory? directory;

    if (Platform.isAndroid) {
      directory = await getTemporaryDirectory();
    } else if (Platform.isIOS) {
      directory = await getTemporaryDirectory();
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    // Create invoices subdirectory
    final invoicesDir = Directory('${directory.path}/Files/Invoices');
    if (!await invoicesDir.exists()) {
      await invoicesDir.create(recursive: true);
    }

    final file = File('${invoicesDir.path}/$fileName');
    await file.writeAsBytes(bytes);

    return file.path;
  }

  /// Get all generated invoices
  static Future<List<FileSystemEntity>> getAllInvoices() async {
    Directory? directory;

    if (Platform.isAndroid) {
      directory = await getTemporaryDirectory();
    } else if (Platform.isIOS) {
      directory = await getTemporaryDirectory();
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    final invoicesDir = Directory('${directory.path}/Invoices');
    if (!await invoicesDir.exists()) {
      return [];
    }

    return invoicesDir.listSync();
  }

  /// Delete an invoice
  static Future<bool> deleteInvoice(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
