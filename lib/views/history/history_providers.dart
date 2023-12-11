// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/models/transaction_model.dart';

final listOfTransactionsProvider = StateProvider.autoDispose<List<Transactions>>((ref) {
  ref.keepAlive();
  return [];
});

final hintTextProvider = StateProvider.autoDispose<String>((ref) => searchMobile);
final selectedFilterProvider = StateProvider.autoDispose<String>((ref) => "Mobile Number");

class Tranx extends Notifier<List<Transactions>> {
  late List<Transactions> _l = [];

  doFuture() async {
    _l = await BackEnd.fetchLatestTransactions();
  }

  addNew(Transactions t) async {
    await BackEnd.createNewTransaction(t);
    doFuture();
  }

  @override
  List<Transactions> build() {
    doFuture();
    return _l;
  }
}

final counterProvider = NotifierProvider<Tranx, List<Transactions>>(() {
  return Tranx();
});
