import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/providers/app_dir_provider.dart';
import 'package:self_finance/providers/transactions_provider.dart';

part 'customer_provider.g.dart';

@riverpod
class CustomerNotifier extends _$CustomerNotifier {
  @override
  Stream<Customer?> build(int id) => BackEnd.watchSingleCustomer(id: id);

  Future<int> updateCustomer({required Customer customer}) async {
    final int res = await BackEnd.updateCustomerDetails(
      customerId: customer.id!,
      newCustomerName: customer.name,
      newGuardianName: customer.guardianName,
      newCustomerAddress: customer.address,
      newContactNumber: customer.number,
      newCustomerPhoto: customer.photo,
      newProofPhoto: customer.proof,
      newCreatedDate: DateTime.now(),
    );

    if (res != 0) {
      ref.invalidate(transactionsProvider);
    }
    return res;
  }

  Future<void> deleteCustomer(int customerID) async {
    await BackEnd.deleteTheCustomer(customerID: customerID);
    ref.invalidate(transactionsProvider);
  }

  Future<void> shareCustomerDetails(Customer customer) async {
    await SharePlus.instance.share(
      ShareParams(
        subject: "Customer Info - ${customer.name}",
        text:
            "Customer Details:\n"
            "Name: ${customer.name}\n"
            "Phone: ${customer.number}\n"
            "Guardian: ${customer.guardianName}\n"
            "Address: ${customer.address}\n"
            "Customer ID: #${customer.id}",
      ),
    );
  }
}

/// Immutable aggregated financial summary model for a specific customer
class CustomerFinancialSummary {
  const CustomerFinancialSummary({
    required this.totalBorrowed,
    required this.activeBalance,
    required this.activeCount,
    required this.closedCount,
    required this.totalTransactionsCount,
    required this.totalMonthlyInterest,
  });

  final double totalBorrowed;
  final double activeBalance;
  final int activeCount;
  final int closedCount;
  final int totalTransactionsCount;
  final double totalMonthlyInterest;

  static const CustomerFinancialSummary empty = CustomerFinancialSummary(
    totalBorrowed: 0.0,
    activeBalance: 0.0,
    activeCount: 0,
    closedCount: 0,
    totalTransactionsCount: 0,
    totalMonthlyInterest: 0.0,
  );
}

/// Memoized provider for customer financial calculations
final customerFinancialSummaryProvider = Provider.family
    .autoDispose<CustomerFinancialSummary, int>((ref, customerId) {
  final transactionsAsync =
      ref.watch(requriedCustomerTransactionsProvider(customerId));
  final List<Trx> transactions = transactionsAsync.asData?.value ?? [];

  if (transactions.isEmpty) return CustomerFinancialSummary.empty;

  double totalBorrowed = 0.0;
  double activeBalance = 0.0;
  int activeCount = 0;
  int closedCount = 0;
  double totalMonthlyInterest = 0.0;

  for (final Trx trx in transactions) {
    totalBorrowed += trx.amount;
    if (trx.transacrtionType == Constant.active) {
      activeCount++;
      activeBalance += trx.amount;
      totalMonthlyInterest += trx.intrestAmount;
    } else {
      closedCount++;
    }
  }

  return CustomerFinancialSummary(
    totalBorrowed: totalBorrowed,
    activeBalance: activeBalance,
    activeCount: activeCount,
    closedCount: closedCount,
    totalTransactionsCount: transactions.length,
    totalMonthlyInterest: totalMonthlyInterest,
  );
});

/// Memoized provider to resolve customer KYC proof file path without blocking UI
final customerProofPathProvider =
    Provider.family.autoDispose<String?, int>((ref, customerId) {
  final Customer? customer =
      ref.watch(customerProvider(customerId)).asData?.value;
  if (customer == null || customer.proof.isEmpty) return null;

  final String appDir = ref.watch(appDirProvider);
  final String fullPath = p.join(appDir, customer.proof);

  return File(fullPath).existsSync() ? fullPath : null;
});

/// Memoized provider to resolve customer avatar file path without blocking UI
final customerPhotoPathProvider =
    Provider.family.autoDispose<String?, int>((ref, customerId) {
  final Customer? customer =
      ref.watch(customerProvider(customerId)).asData?.value;
  if (customer == null || customer.photo.isEmpty) return null;

  final String appDir = ref.watch(appDirProvider);
  final String fullPath = p.join(appDir, customer.photo);

  return File(fullPath).existsSync() ? fullPath : null;
});
