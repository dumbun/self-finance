// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserHistory {
  int? id;
  final int userID;
  final int customerID;
  final int itemID;
  final int transactionID;
  final String eventDate;
  final String eventType; // credited or debited
  final double amount;

  UserHistory({
    this.id,
    required this.userID,
    required this.customerID,
    required this.itemID,
    required this.transactionID,
    required this.eventDate,
    required this.eventType,
    required this.amount,
  });

  static List<UserHistory> toList(List<Map<String, Object?>> data) {
    if (data.isEmpty) {
      return []; // If data is empty, return an empty list directly
    }
    return data.map((e) {
      return UserHistory(
        id: e["Customer_ID"] as int,
        amount: e["Amount"] as double,
        customerID: e["Customer_ID"] as int,
        eventDate: e["Event_Date"] as String,
        eventType: e["Event_Type"] as String,
        itemID: e["Item_ID"] as int,
        transactionID: e["Transacrtion_ID"] as int,
        userID: e["User_ID"] as int,
      );
    }).toList();
  }

  UserHistory copyWith({
    int? id,
    int? userID,
    int? customerID,
    int? itemID,
    int? transactionID,
    String? eventDate,
    String? eventType,
    double? amount,
  }) {
    return UserHistory(
      id: id ?? this.id,
      userID: userID ?? this.userID,
      customerID: customerID ?? this.customerID,
      itemID: itemID ?? this.itemID,
      transactionID: transactionID ?? this.transactionID,
      eventDate: eventDate ?? this.eventDate,
      eventType: eventType ?? this.eventType,
      amount: amount ?? this.amount,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userID': userID,
      'customerID': customerID,
      'itemID': itemID,
      'transactionID': transactionID,
      'eventDate': eventDate,
      'eventType': eventType,
      'amount': amount,
    };
  }

  factory UserHistory.fromMap(Map<String, dynamic> map) {
    return UserHistory(
      id: map['id'] != null ? map['id'] as int : null,
      userID: map['userID'] as int,
      customerID: map['customerID'] as int,
      itemID: map['itemID'] as int,
      transactionID: map['transactionID'] as int,
      eventDate: map['eventDate'] as String,
      eventType: map['eventType'] as String,
      amount: map['amount'] as double,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserHistory.fromJson(String source) => UserHistory.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserHistory(id: $id, userID: $userID, customerID: $customerID, itemID: $itemID, transactionID: $transactionID, eventDate: $eventDate, eventType: $eventType, amount: $amount)';
  }

  @override
  bool operator ==(covariant UserHistory other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.userID == userID &&
        other.customerID == customerID &&
        other.itemID == itemID &&
        other.transactionID == transactionID &&
        other.eventDate == eventDate &&
        other.eventType == eventType &&
        other.amount == amount;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userID.hashCode ^
        customerID.hashCode ^
        itemID.hashCode ^
        transactionID.hashCode ^
        eventDate.hashCode ^
        eventType.hashCode ^
        amount.hashCode;
  }
}
