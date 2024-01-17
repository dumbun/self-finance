import 'dart:convert';

class UserHistory {
  final int? id;
  final int mobileNumber;
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
  final double? paidAmount;
  final double? totalIntrest;
  final String? dueTime;
  final String photoProof;
  final String photoItem;
  final String photoCustomer;
  UserHistory({
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

  UserHistory copyWith({
    int? id,
    int? mobileNumber,
    String? address,
    String? customerName,
    String? guardianName,
    String? takenDate,
    int? takenAmount,
    double? rateOfInterest,
    String? itemName,
    int? transactionType,
    String? paidDate,
    String? via,
    double? paidAmount,
    double? totalIntrest,
    String? dueTime,
    String? photoProof,
    String? photoItem,
    String? photoCustomer,
  }) {
    return UserHistory(
      id: id ?? this.id,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      address: address ?? this.address,
      customerName: customerName ?? this.customerName,
      guardianName: guardianName ?? this.guardianName,
      takenDate: takenDate ?? this.takenDate,
      takenAmount: takenAmount ?? this.takenAmount,
      rateOfInterest: rateOfInterest ?? this.rateOfInterest,
      itemName: itemName ?? this.itemName,
      transactionType: transactionType ?? this.transactionType,
      paidDate: paidDate ?? this.paidDate,
      via: via ?? this.via,
      paidAmount: paidAmount ?? this.paidAmount,
      totalIntrest: totalIntrest ?? this.totalIntrest,
      dueTime: dueTime ?? this.dueTime,
      photoProof: photoProof ?? this.photoProof,
      photoItem: photoItem ?? this.photoItem,
      photoCustomer: photoCustomer ?? this.photoCustomer,
    );
  }

  static List<UserHistory> toList(List<Map<String, Object?>> data) {
    return List.generate(
      data.length,
      (index) => UserHistory(
        id: data[index]["CUST_ID"] as int,
        mobileNumber: data[index]["MOBILE_NUMBER"] as int,
        address: data[index]["ADDRESS"] as String,
        customerName: data[index]["CUSTOMER_NAME"] as String,
        guardianName: data[index]["GUARDIAN_NAME"] as String,
        takenDate: data[index]["TAKEN_DATE"] as String,
        takenAmount: data[index]["TAKEN_AMOUNT"] as int,
        rateOfInterest: data[index]["RATE_OF_INTEREST"] as double,
        itemName: data[index]["ITEM_NAME"] as String,
        transactionType: data[index]["TRANSACTION_TYPE"] as int,
        paidDate: data[index]["PAID_DATE"] as String,
        via: data[index]["VIA"] as String,
        paidAmount: data[index]["PAID_AMOUNT"] as double,
        totalIntrest: data[index]["TOTAL_INTREST"] as double,
        dueTime: data[index]["DUE_TIME"] as String,
        photoProof: data[index]["PHOTO_PROOF"] as String,
        photoCustomer: data[index]["PHOTO_CUSTOMER"] as String,
        photoItem: data[index]["PHOTO_ITEM"] as String,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
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
      'photoProof': photoProof,
      'photoItem': photoItem,
      'photoCustomer': photoCustomer,
    };
  }

  factory UserHistory.fromMap(Map<String, dynamic> map) {
    return UserHistory(
      id: map['id'] != null ? map['id'] as int : null,
      mobileNumber: map['mobileNumber'] as int,
      address: map['address'] as String,
      customerName: map['customerName'] as String,
      guardianName: map['guardianName'] as String,
      takenDate: map['takenDate'] as String,
      takenAmount: map['takenAmount'] as int,
      rateOfInterest: map['rateOfInterest'] as double,
      itemName: map['itemName'] as String,
      transactionType: map['transactionType'] as int,
      paidDate: map['paidDate'] != null ? map['paidDate'] as String : null,
      via: map['via'] != null ? map['via'] as String : null,
      paidAmount: map['paidAmount'] != null ? map['paidAmount'] as double : null,
      totalIntrest: map['totalIntrest'] != null ? map['totalIntrest'] as double : null,
      dueTime: map['dueTime'] != null ? map['dueTime'] as String : null,
      photoProof: map['photoProof'] as String,
      photoItem: map['photoItem'] as String,
      photoCustomer: map['photoCustomer'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserHistory.fromJson(String source) => UserHistory.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserHistory(id: $id, mobileNumber: $mobileNumber, address: $address, customerName: $customerName, guardianName: $guardianName, takenDate: $takenDate, takenAmount: $takenAmount, rateOfInterest: $rateOfInterest, itemName: $itemName, transactionType: $transactionType, paidDate: $paidDate, via: $via, paidAmount: $paidAmount, totalIntrest: $totalIntrest, dueTime: $dueTime, photoProof: $photoProof, photoItem: $photoItem, photoCustomer: $photoCustomer)';
  }

  @override
  bool operator ==(covariant UserHistory other) {
    if (identical(this, other)) return true;

    return other.id == id &&
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
        other.dueTime == dueTime &&
        other.photoProof == photoProof &&
        other.photoItem == photoItem &&
        other.photoCustomer == photoCustomer;
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
        dueTime.hashCode ^
        photoProof.hashCode ^
        photoItem.hashCode ^
        photoCustomer.hashCode;
  }
}
