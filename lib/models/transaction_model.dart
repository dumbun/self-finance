import 'dart:convert';

import 'package:flutter/widgets.dart';

class Transactions {
  final int? id;
  final String mobileNumber;
  final String address;
  final String customerName;
  final String guardianName;
  final String takenDate;
  final int takenAmount;
  final double rateOfInterest;
  final String itemName;
  final int transactionType;
  final String? paidDate;
  final String? via;
  final int? paidAmount;
  final int? totalIntrest;
  final String? dueTime;
  final String photoProof;
  final String photoItem;
  final String photoCustomer;

  Transactions({
    this.id,
    required this.mobileNumber,
    required this.address,
    required this.customerName,
    required this.guardianName,
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
    required this.photoCustomer,
  });

  static List<Transactions> toList(data) {
    List<Transactions> custData = [];
    data.forEach(
      (Map<String, dynamic> e) {
        custData.add(
          Transactions(
            id: e["ID"],
            mobileNumber: e["MOBILE_NUMBER"],
            address: e["ADDRESS"],
            customerName: e["CUSTOMER_NAME"],
            guardianName: e["GUARDIAN_NAME"],
            takenDate: e["TAKEN_DATE"],
            takenAmount: e["TAKEN_AMOUNT"],
            rateOfInterest: e["RATE_OF_INTEREST"],
            itemName: e["ITEM_NAME"],
            transactionType: e["TRANSACTION_TYPE"],
            paidDate: e["PAID_DATE"],
            via: e["VIA"],
            paidAmount: e["PAID_AMOUNT"],
            totalIntrest: e["TOTAL_INTREST"],
            dueTime: e["DUE_TIME"],
            photoProof: e["PHOTO_PROOF"],
            photoCustomer: e["PHOTO_CUSTOMER"],
            photoItem: e["PHOTO_ITEM"],
          ),
        );
      },
    );
    return custData;
  }

  Transactions copyWith({
    ValueGetter<int?>? id,
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
    ValueGetter<int?>? paidAmount,
    ValueGetter<int?>? totalIntrest,
    ValueGetter<String?>? dueTime,
    String? photoProof,
    String? photoItem,
    String? photoCustomer,
  }) {
    return Transactions(
      id: id != null ? id() : this.id,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      address: address ?? this.address,
      customerName: customerName ?? this.customerName,
      guardianName: guardianName ?? this.guardianName,
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
      photoCustomer: photoCustomer ?? this.photoCustomer,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mobileNumber': mobileNumber,
      'address': address,
      'customerName': customerName,
      'guardianName': guardianName,
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
      'photoCustomer': photoCustomer,
      'photoItem': photoItem,
      'photoProof': photoProof,
    };
  }

  factory Transactions.fromMap(Map<String, dynamic> map) {
    return Transactions(
      id: map['id']?.toInt(),
      mobileNumber: map['mobileNumber'] ?? '',
      address: map['address'] ?? '',
      customerName: map['customerName'] ?? '',
      guardianName: map['guardianName'] ?? '',
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
      photoCustomer: map['photoCustomer'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Transactions.fromJson(String source) => Transactions.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Transactions(id: $id, mobileNumber: $mobileNumber, address: $address, customerName: $customerName, guardianName: $guardianName, takenDate: $takenDate, takenAmount: $takenAmount, rateOfInterest: $rateOfInterest, itemName: $itemName, transactionType: $transactionType, paidDate: $paidDate, via: $via, paidAmount: $paidAmount, totalIntrest: $totalIntrest, dueTime: $dueTime)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Transactions &&
        other.id == id &&
        other.mobileNumber == mobileNumber &&
        other.address == address &&
        other.customerName == customerName &&
        other.guardianName == guardianName &&
        other.takenDate == takenDate &&
        other.takenAmount == takenAmount &&
        other.rateOfInterest == rateOfInterest &&
        other.itemName == itemName &&
        other.transactionType == transactionType &&
        other.paidDate == paidDate &&
        other.via == via &&
        other.paidAmount == paidAmount &&
        other.totalIntrest == totalIntrest &&
        other.dueTime == dueTime;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        mobileNumber.hashCode ^
        address.hashCode ^
        customerName.hashCode ^
        guardianName.hashCode ^
        takenDate.hashCode ^
        takenAmount.hashCode ^
        rateOfInterest.hashCode ^
        itemName.hashCode ^
        transactionType.hashCode ^
        paidDate.hashCode ^
        via.hashCode ^
        paidAmount.hashCode ^
        totalIntrest.hashCode ^
        dueTime.hashCode;
  }
}
