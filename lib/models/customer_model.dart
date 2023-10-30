import 'dart:convert';

class Customer {
  final int? id;
  final String mobileNumber;
  final String address;
  final String customerName;
  final String guardianName;
  final String takenDate;
  final int takenAmount;
  final double rateOfInterest;
  final String itemName;
  final int transaction;

  const Customer({
    this.id,
    required this.mobileNumber,
    required this.address,
    required this.customerName,
    required this.guardianName,
    required this.takenDate,
    required this.takenAmount,
    required this.rateOfInterest,
    required this.itemName,
    required this.transaction,
  });

  Customer copyWith({
    int? id,
    String? mobileNumber,
    String? address,
    String? customerName,
    String? guardianName,
    String? takenDate,
    int? takenAmount,
    double? rateOfInterest,
    String? itemName,
    int? transaction,
  }) {
    return Customer(
      id: id ?? this.id,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      address: address ?? this.address,
      customerName: customerName ?? this.customerName,
      guardianName: guardianName ?? this.guardianName,
      takenDate: takenDate ?? this.takenDate,
      takenAmount: takenAmount ?? this.takenAmount,
      rateOfInterest: rateOfInterest ?? this.rateOfInterest,
      itemName: itemName ?? this.itemName,
      transaction: transaction ?? this.transaction,
    );
  }

  static List<Customer> toList(data) {
    List<Customer> custData = [];
    data.forEach((Map<String, dynamic> e) {
      custData.add(Customer(
        id: e["ID"],
        mobileNumber: e["MOBILE_NUMBER"],
        address: e["ADDRESS"],
        customerName: e["CUSTOMER_NAME"],
        guardianName: e["GUARDIAN_NAME"],
        takenDate: e["TAKEN_DATE"],
        takenAmount: e["TAKEN_AMOUNT"],
        rateOfInterest: e["RATE_OF_INTEREST"],
        itemName: e["ITEM_NAME"],
        transaction: e["TRANSFER"],
      ));
    });
    return custData;
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
      'transaction': transaction,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id']?.toInt(),
      mobileNumber: map['mobileNumber'] ?? '',
      address: map['address'] ?? '',
      customerName: map['customerName'] ?? '',
      guardianName: map['guardianName'] ?? '',
      takenDate: map['takenDate'] ?? '',
      takenAmount: map['takenAmount']?.toInt() ?? 0,
      rateOfInterest: map['rateOfInterest']?.toDouble() ?? 0.0,
      itemName: map['itemName'] ?? '',
      transaction: map['transaction']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Customer.fromJson(String source) => Customer.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Customer(id: $id, mobileNumber: $mobileNumber, address: $address, customerName: $customerName, guardianName: $guardianName, takenDate: $takenDate, takenAmount: $takenAmount, rateOfInterest: $rateOfInterest, itemName: $itemName, transaction: $transaction)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Customer &&
        other.id == id &&
        other.mobileNumber == mobileNumber &&
        other.address == address &&
        other.customerName == customerName &&
        other.guardianName == guardianName &&
        other.takenDate == takenDate &&
        other.takenAmount == takenAmount &&
        other.rateOfInterest == rateOfInterest &&
        other.itemName == itemName &&
        other.transaction == transaction;
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
        transaction.hashCode;
  }
}
