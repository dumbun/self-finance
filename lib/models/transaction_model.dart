import 'dart:convert';

import 'package:flutter/widgets.dart';

class TransactionsHistory {
  final int? id;
  final int custId;
  final String takenDate;
  final int takenAmount;
  final double rateOfInterest;
  final String itemName;
  final int transactionType;
  final String? paidDate;
  final String? via;
  final double? paidAmount;
  final double? totalIntrest;
  final String? dueTime;
  final String? photoProof;
  final String? photoItem;

  TransactionsHistory({
    this.id,
    required this.custId,
    required this.takenDate,
    required this.takenAmount,
    required this.rateOfInterest,
    required this.itemName,
    required this.transactionType,
    this.paidDate,
    this.via,
    this.paidAmount,
    this.totalIntrest,
    this.dueTime,
    required this.photoProof,
    required this.photoItem,
  });

  static List<TransactionsHistory> toList(List<Map<String, Object?>> e) {
    return List.generate(
      e.length,
      (index) => TransactionsHistory(
        id: e[index]["ID"] as int,
        custId: e[index][" CUST_ID"] as int,
        takenDate: e[index]["TAKEN_DATE"] as String,
        takenAmount: e[index]["TAKEN_AMOUNT"] as int,
        rateOfInterest: e[index]["RATE_OF_INTEREST"] as double,
        itemName: e[index]["ITEM_NAME"] as String,
        transactionType: e[index]["TRANSACTION_TYPE"] as int,
        paidDate: e[index]["PAID_DATE"] as String,
        via: e[index]["VIA"] as String,
        paidAmount: e[index]["PAID_AMOUNT"] as double,
        totalIntrest: e[index]["TOTAL_INTREST"] as double,
        dueTime: e[index]["DUE_TIME"] as String,
        photoProof: e[index]["PHOTO_PROOF"] as String,
        photoItem: e[index]["PHOTO_ITEM"] as String,
      ),
    );
  }

  TransactionsHistory copyWith({
    ValueGetter<int?>? id,
    int? custId,
    String? mobileNumber,
    String? address,
    String? customerName,
    String? guardianName,
    String? takenDate,
    int? takenAmount,
    double? rateOfInterest,
    String? itemName,
    int? transactionType,
    ValueGetter<String?>? paidDate,
    ValueGetter<String?>? via,
    ValueGetter<double?>? paidAmount,
    ValueGetter<double?>? totalIntrest,
    ValueGetter<String?>? dueTime,
    String? photoProof,
    String? photoItem,
    String? photoCustomer,
  }) {
    return TransactionsHistory(
      id: id != null ? id() : this.id,
      custId: custId ?? this.custId,
      takenDate: takenDate ?? this.takenDate,
      takenAmount: takenAmount ?? this.takenAmount,
      rateOfInterest: rateOfInterest ?? this.rateOfInterest,
      itemName: itemName ?? this.itemName,
      transactionType: transactionType ?? this.transactionType,
      paidDate: paidDate != null ? paidDate() : this.paidDate,
      via: via != null ? via() : this.via,
      paidAmount: paidAmount != null ? paidAmount() : this.paidAmount,
      totalIntrest: totalIntrest != null ? totalIntrest() : this.totalIntrest,
      dueTime: dueTime != null ? dueTime() : this.dueTime,
      photoProof: photoProof ?? this.photoProof,
      photoItem: photoItem ?? this.photoItem,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'custId': custId,
      'takenDate': takenDate,
      'takenAmount': takenAmount,
      'rateOfInterest': rateOfInterest,
      'itemName': itemName,
      'transactionType': transactionType,
      'paidDate': paidDate,
      'via': via,
      'paidAmount': paidAmount,
      'totalIntrest': totalIntrest,
      'dueTime': dueTime,
      'photoItem': photoItem,
      'photoProof': photoProof,
    };
  }

  factory TransactionsHistory.fromMap(Map<String, dynamic> map) {
    return TransactionsHistory(
      id: map['id']?.toInt(),
      custId: map['custId'],
      takenDate: map['takenDate'] ?? '',
      takenAmount: map['takenAmount']?.toInt() ?? 0,
      rateOfInterest: map['rateOfInterest']?.toDouble() ?? 0.0,
      itemName: map['itemName'] ?? '',
      transactionType: map['transactionType']?.toInt() ?? 0,
      paidDate: map['paidDate'],
      via: map['via'],
      paidAmount: map['paidAmount']?.toInt(),
      totalIntrest: map['totalIntrest']?.toInt(),
      dueTime: map['dueTime'],
      photoProof: map['photoProof'] ?? '',
      photoItem: map['photoItem'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory TransactionsHistory.fromJson(String source) => TransactionsHistory.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Transactions(id: $id,takenDate: $takenDate, takenAmount: $takenAmount, rateOfInterest: $rateOfInterest, itemName: $itemName, transactionType: $transactionType, paidDate: $paidDate, via: $via, paidAmount: $paidAmount, totalIntrest: $totalIntrest, dueTime: $dueTime)';
  }
}
