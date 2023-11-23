import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/models/transaction_model.dart';

final listOfTransactionsProvider = StateProvider.autoDispose<List<Transactions>>((ref) {
  ref.keepAlive();
  return [];
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
