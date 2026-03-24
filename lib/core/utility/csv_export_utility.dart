import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:self_finance/models/csv_model.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/models/payment_model.dart';
import 'package:self_finance/models/transaction_model.dart';

class CsvExportUtility {
  // CSV helpers ---------------------------------------------------------------

  static String _escape(dynamic value) {
    final String s = (value ?? '').toString();
    // Wrap in quotes if the value contains comma, quote, or newline
    if (s.contains(',') || s.contains('"') || s.contains('\n')) {
      return '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }

  static String _row(List<dynamic> cells) => cells.map(_escape).join(',');

  static String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd-MM-yyyy').format(date);
  }

  static String _formatAmount(double amount) => amount.toStringAsFixed(2);

  // Customer lookup -----------------------------------------------------------

  static Future<Map<int, Customer>> _buildCustomerMap() async {
    final List<Customer> customers = await BackEnd.fetchAllCustomerData();
    return {for (final c in customers) c.id!: c};
  }

  // ─── CSV builders ──────────────────────────────────────────────────────────

  static Future<String> _buildTransactionsCsv({
    required List<Trx> transactions,
    required Map<int, Customer> customerMap,
  }) async {
    final buffer = StringBuffer();

    // Header
    buffer.writeln(
      _row([
        'Transaction ID',
        'Customer ID',
        'Customer Name',
        'Customer Phone',
        'Customer Address',
        'Transaction Date',
        'Status',
        'Principal Amount',
        'Interest Rate (%)',
        'Interest Amount',
        'Remaining Amount',
        'Created Date',
      ]),
    );

    for (final trx in transactions) {
      final Customer? customer = customerMap[trx.customerId];
      buffer.writeln(
        _row([
          trx.id ?? '',
          trx.customerId,
          customer?.name ?? 'Unknown',
          customer?.number ?? '',
          customer?.address ?? '',
          _formatDate(trx.transacrtionDate),
          trx.transacrtionType,
          _formatAmount(trx.amount),
          _formatAmount(trx.intrestRate),
          _formatAmount(trx.intrestAmount),
          _formatAmount(trx.remainingAmount),
          _formatDate(trx.createdDate),
        ]),
      );
    }

    return buffer.toString();
  }

  static Future<String> _buildPaymentsCsv({
    required List<Payment> payments,
    required Map<int, Customer> customerMap,
    required Map<int, Trx> transactionMap,
  }) async {
    final buffer = StringBuffer();

    // Header
    buffer.writeln(
      _row([
        'Payment ID',
        'Transaction ID',
        'Customer ID',
        'Customer Name',
        'Customer Phone',
        'Payment Date',
        'Amount Paid',
        'Payment Type',
        'Created Date',
      ]),
    );

    for (final pay in payments) {
      final Trx? trx = transactionMap[pay.transactionId];
      final Customer? customer = trx != null
          ? customerMap[trx.customerId]
          : null;

      buffer.writeln(
        _row([
          pay.id ?? '',
          pay.transactionId,
          trx?.customerId ?? '',
          customer?.name ?? 'Unknown',
          customer?.number ?? '',
          _formatDate(pay.paymentDate),
          _formatAmount(pay.amountpaid),
          pay.type,
          _formatDate(pay.createdDate),
        ]),
      );
    }

    return buffer.toString();
  }

  // ─── File I/O ──────────────────────────────────────────────────────────────

  static Future<Directory> _exportDir() async {
    final Directory appCache = await getApplicationCacheDirectory();
    final Directory dir = Directory(p.join(appCache.path, 'exports_cache'));
    await dir.create(recursive: true);
    return dir;
  }

  static Future<File> _writeFile(String fileName, String content) async {
    final Directory dir = await _exportDir();
    final File file = File(p.join(dir.path, fileName));
    await file.writeAsString(content, flush: true);
    return file;
  }

  static String _timestamp() =>
      DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());

  // ─── Public API ────────────────────────────────────────────────────────────

  static Future<CsvExportResult> export({
    required Set<CsvExportType> types,
    CsvProgressCallback? onProgress,
  }) async {
    try {
      onProgress?.call(0.05, 'Loading customer data…');
      final Map<int, Customer> customerMap = await _buildCustomerMap();

      onProgress?.call(0.15, 'Loading transactions…');
      final List<Trx> allTrx = await BackEnd.fetchAllTransactions();
      final Map<int, Trx> transactionMap = {
        for (final t in allTrx)
          if (t.id != null) t.id!: t,
      };

      final List<File> exportedFiles = [];
      final String ts = _timestamp();
      double progress = 0.15;
      final double step = 0.70 / (types.length + 1);

      // ── All Transactions ──────────────────────────────────────────────────
      if (types.contains(CsvExportType.allTransactions)) {
        onProgress?.call(progress += step, 'Building all-transactions CSV…');
        final String csv = await _buildTransactionsCsv(
          transactions: allTrx,
          customerMap: customerMap,
        );
        exportedFiles.add(await _writeFile('all_transactions_$ts.csv', csv));
      }

      // ── Active Loans ──────────────────────────────────────────────────────
      if (types.contains(CsvExportType.activeLoans)) {
        onProgress?.call(progress += step, 'Building active-loans CSV…');
        final List<Trx> active = allTrx
            .where((t) => t.transacrtionType == 'Active')
            .toList();
        final String csv = await _buildTransactionsCsv(
          transactions: active,
          customerMap: customerMap,
        );
        exportedFiles.add(await _writeFile('active_loans_$ts.csv', csv));
      }

      // ── Completed Loans ───────────────────────────────────────────────────
      if (types.contains(CsvExportType.completedLoans)) {
        onProgress?.call(progress += step, 'Building completed-loans CSV…');
        final List<Trx> completed = allTrx
            .where((t) => t.transacrtionType == 'Inactive')
            .toList();
        final String csv = await _buildTransactionsCsv(
          transactions: completed,
          customerMap: customerMap,
        );
        exportedFiles.add(await _writeFile('completed_loans_$ts.csv', csv));
      }

      // ── Payment History ───────────────────────────────────────────────────
      if (types.contains(CsvExportType.paymentHistory)) {
        onProgress?.call(progress += step, 'Building payment-history CSV…');
        // Collect all payments across all transactions
        final List<Payment> allPayments = [];
        for (final trx in allTrx) {
          if (trx.id == null) continue;
          final List<Payment> pays =
              await BackEnd.fetchRequriedPaymentsOfTransaction(
                transactionId: trx.id!,
              );
          allPayments.addAll(pays);
        }
        // Sort by payment date descending
        allPayments.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));

        final String csv = await _buildPaymentsCsv(
          payments: allPayments,
          customerMap: customerMap,
          transactionMap: transactionMap,
        );
        exportedFiles.add(await _writeFile('payment_history_$ts.csv', csv));
      }

      if (exportedFiles.isEmpty) {
        clearExports();
        return CsvExportResult.failure('No data types selected for export.');
      }

      for (final file in exportedFiles) {
        final params = SaveFileDialogParams(
          sourceFilePath: file.path,
          fileName: p.basename(file.path),
        );
        await FlutterFileDialog.saveFile(params: params);
      }

      onProgress?.call(1.0, 'Done!');
      clearExports();
      return CsvExportResult.success(exportedFiles.map((f) => f.path).toList());
    } catch (e, st) {
      clearExports();
      debugPrint('CSV export error: $e\n$st');
      return CsvExportResult.failure(e.toString());
    }
  }

  // ─── Cleanup ───────────────────────────────────────────────────────────────

  /// Delete all previously exported CSV files from the exports directory.
  static Future<void> clearExports() async {
    try {
      final Directory dir = await _exportDir();
      if (!await dir.exists()) return;
      await for (final FileSystemEntity entity in dir.list(recursive: false)) {
        if (entity is File && entity.path.endsWith('.csv')) {
          await entity.delete();
        }
      }
    } catch (e) {
      debugPrint('Failed to clear exports: $e');
    }
  }
}
