class UserHistory {
  final String? id;
  final int userID;
  final String customerID;
  final String itemID;
  final String customerNumber;
  final String customerName;
  final String transactionID;
  final DateTime eventDate;
  final String eventType; // credited or debited
  final double amount;

  UserHistory({
    this.id,
    required this.userID,
    required this.customerID,
    required this.itemID,
    required this.customerNumber,
    required this.customerName,
    required this.transactionID,
    required this.eventDate,
    required this.eventType,
    required this.amount,
  });

  static List<UserHistory> toList(List<Map<String, Object?>> data) {
    if (data.isEmpty) {
      return []; // If data is empty, return an empty list directly
    }
    return data.map((Map<String, Object?> e) {
      return UserHistory(
        id: e["History_ID"]?.toString(),
        amount: e["Amount"] as double,
        customerID: e["Customer_ID"]?.toString() ?? '',
        eventDate: e["Event_Date"] as DateTime,
        eventType: e["Event_Type"] as String,
        itemID: e["Item_ID"]?.toString() ?? '',
        customerName: e["Customer_Name"] as String,
        customerNumber: e["Contact_Number"] as String,
        transactionID: (e["Transaction_ID"] == null || e["Transaction_ID"] == '0' || e["Transaction_ID"] == 0) ? '' : e["Transaction_ID"].toString(),
        userID: e["User_ID"] as int,
      );
    }).toList();
  }

  UserHistory copyWith({
    String? id,
    int? userID,
    String? customerID,
    String? itemID,
    String? customerNumber,
    String? customerName,
    String? transactionID,
    DateTime? eventDate,
    String? eventType,
    double? amount,
  }) {
    return UserHistory(
      id: id ?? this.id,
      userID: userID ?? this.userID,
      customerID: customerID ?? this.customerID,
      itemID: itemID ?? this.itemID,
      customerNumber: customerNumber ?? this.customerNumber,
      customerName: customerName ?? this.customerName,
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
      'customerNumber': customerNumber,
      'customerName': customerName,
      'transactionID': transactionID,
      'eventDate': eventDate,
      'eventType': eventType,
      'amount': amount,
    };
  }

  factory UserHistory.fromMap(Map<String, dynamic> map) {
    final rawTxnId = map['transactionID'] ?? map['Transaction_ID'];
    final normalizedTxnId = (rawTxnId == null || rawTxnId == '0' || rawTxnId == 0)
        ? ''
        : rawTxnId.toString();

    final rawUserId = map['userID'] ?? map['User_ID'] ?? 1;
    final int normalizedUserId = (rawUserId is num)
        ? rawUserId.toInt()
        : int.tryParse(rawUserId.toString()) ?? 1;

    return UserHistory(
      id: map['id']?.toString() ?? map['History_ID']?.toString(),
      userID: normalizedUserId,
      customerID: map['customerID']?.toString() ?? map['Customer_ID']?.toString() ?? '',
      itemID: map['itemID']?.toString() ?? map['Item_ID']?.toString() ?? '',
      customerNumber: map['customerNumber']?.toString() ?? map['Contact_Number']?.toString() ?? '',
      customerName: map['customerName']?.toString() ?? map['Customer_Name']?.toString() ?? '',
      transactionID: normalizedTxnId,
      eventDate: map['eventDate'] is DateTime
          ? map['eventDate'] as DateTime
          : DateTime.tryParse(map['eventDate']?.toString() ?? '') ??
              DateTime.now(),
      eventType: map['eventType']?.toString() ?? '',
      amount: (map['amount'] is num)
          ? (map['amount'] as num).toDouble()
          : double.tryParse(map['amount']?.toString() ?? '0.0') ?? 0.0,
    );
  }

  @override
  String toString() {
    return 'UserHistory(id: $id, userID: $userID, customerID: $customerID, itemID: $itemID, customerNumber: $customerNumber, customerName: $customerName, transactionID: $transactionID, eventDate: $eventDate, eventType: $eventType, amount: $amount)';
  }

  @override
  bool operator ==(covariant UserHistory other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.userID == userID &&
        other.customerID == customerID &&
        other.itemID == itemID &&
        other.customerNumber == customerNumber &&
        other.customerName == customerName &&
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
        customerNumber.hashCode ^
        customerName.hashCode ^
        transactionID.hashCode ^
        eventDate.hashCode ^
        eventType.hashCode ^
        amount.hashCode;
  }
}
