import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/providers/p.dart';

final listOfTransactionsProvider = StateProvider.autoDispose<List<Transactions>>((ref) {
  ref.keepAlive();
  return ref.watch(backendProvider.notifier).trnx;
});

final hintTextProvider = StateProvider.autoDispose<String>((ref) => searchMobile);
final selectedFilterProvider = StateProvider.autoDispose<String>((ref) => "Mobile Number");
