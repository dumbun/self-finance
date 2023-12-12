import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/models/customer_model.dart';

import 'package:self_finance/models/transaction_model.dart';

class BackendProvider extends ChangeNotifier {
  List<Transactions> trnx = [];
  List<Customer> ctrx = [];

  List<Transactions> get transactions => trnx;

  List<Customer> get customers {
    return ctrx;
  }

  void update() async {
    trnx = await BackEnd.fetchLatestTransactions();
    notifyListeners();
  }

  void printf() {
    notifyListeners();
    for (var element in trnx) {
      print(element);
    }
  }

  Future<bool> createTransaction(Transactions t, Customer c) async {
    bool result = await BackEnd.createNewTransaction(t);
    result = await BackEnd.createNewEntry(c);
    if (result) {
      trnx.add(t);
      ctrx.add(c);
      notifyListeners();
    }
    return result;
  }

  void doMobileSearch(String mobileNumber) async {
    print("object");
    List<Transactions> showdowData = await BackEnd.fetchLatestTransactions();
    var result = showdowData.where((element) {
      if (element.mobileNumber.contains(mobileNumber)) {
        return true;
      } else {
        return false;
      }
    }).toList();
    trnx = result;
    notifyListeners();
    // ref.read(listOfTransactionsProvider.notifier).state = result;
  }
}

final backendProvider = ChangeNotifierProvider.autoDispose((ref) => BackendProvider());
