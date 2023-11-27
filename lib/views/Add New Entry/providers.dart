import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/models/transaction_model.dart';

final createNewEntryProvider = FutureProvider.autoDispose.family<bool, Customer>((ref, customer) async {
  final bool result = await BackEnd.createNewEntry(customer);
  return result;
});

final createNewTransactionProvider = FutureProvider.autoDispose.family<bool, Transactions>((ref, transactions) async {
  final bool result = await BackEnd.createNewTransaction(transactions);
  return result;
});

final pickedCustomerProfileImageStringProvider = StateProvider<String>((ref) {
  // Initial value is an empty string
  return "";
});
final pickedCustomerProofImageStringProvider = StateProvider<String>((ref) {
  // Initial value is an empty string
  return "";
});
final pickedCustomerItemImageStringProvider = StateProvider<String>((ref) {
  // Initial value is an empty string
  return "";
});
