import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/backend/user_db.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/models/user_model.dart';

final FutureProvider<User?> userDataProvider = FutureProvider<User?>((ref) async {
  try {
    User? result = await UserBackEnd.fetchUserData();
    return result;
  } catch (e) {
    return null;
  }
});

final createNewEntryProvider = FutureProvider.autoDispose.family<bool, Customer>((ref, customer) async {
  final bool result = await BackEnd.createNewEntry(customer);
  return result;
});

final createNewTransactionProvider = FutureProvider.autoDispose.family<bool, Transactions>((ref, transactions) async {
  final bool result = await BackEnd.createNewTransaction(transactions);
  return result;
});
