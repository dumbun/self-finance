class Payment {
  final String? id;
  final String transactionId;
  final DateTime paymentDate;
  final double amountpaid;
  final String type;
  final DateTime createdDate;
  Payment({
    this.id,
    required this.transactionId,
    required this.paymentDate,
    required this.amountpaid,
    required this.type,
    required this.createdDate,
  });

  static List<Payment> toList(List<Map<String, dynamic>> data) {
    if (data.isEmpty) {
      return []; // If data is empty, return an empty list directly
    }

    return data.map((e) {
      return Payment(
        id: e["Payment_ID"]?.toString(),
        transactionId: e["Transaction_ID"]?.toString() ?? '',
        paymentDate: e["Payment_Date"] is DateTime
            ? e["Payment_Date"] as DateTime
            : DateTime.tryParse(e["Payment_Date"]?.toString() ?? '') ??
                DateTime.now(),
        amountpaid: (e["Amount_Paid"] is num)
            ? (e["Amount_Paid"] as num).toDouble()
            : double.tryParse(e["Amount_Paid"]?.toString() ?? '0.0') ?? 0.0,
        type: e["Payment_Type"]?.toString() ?? '',
        createdDate: e["Created_Date"] is DateTime
            ? e["Created_Date"] as DateTime
            : DateTime.tryParse(e["Created_Date"]?.toString() ?? '') ??
                DateTime.now(),
      );
    }).toList();
  }

  Payment copyWith({
    String? id,
    String? transactionId,
    DateTime? paymentDate,
    double? amountpaid,
    String? type,
    DateTime? createdDate,
  }) {
    return Payment(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      paymentDate: paymentDate ?? this.paymentDate,
      amountpaid: amountpaid ?? this.amountpaid,
      type: type ?? this.type,
      createdDate: createdDate ?? this.createdDate,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'transactionId': transactionId,
      'paymentDate': paymentDate,
      'amountpaid': amountpaid,
      'type': type,
      'createdDate': createdDate,
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id']?.toString(),
      transactionId: map['transactionId']?.toString() ?? '',
      paymentDate: map['paymentDate'] is DateTime
          ? map['paymentDate'] as DateTime
          : DateTime.tryParse(map['paymentDate']?.toString() ?? '') ??
              DateTime.now(),
      amountpaid: (map['amountpaid'] is num)
          ? (map['amountpaid'] as num).toDouble()
          : double.tryParse(map['amountpaid']?.toString() ?? '0.0') ?? 0.0,
      type: map['type']?.toString() ?? '',
      createdDate: map['createdDate'] is DateTime
          ? map['createdDate'] as DateTime
          : DateTime.tryParse(map['createdDate']?.toString() ?? '') ??
              DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'Payment(id: $id, transactionId: $transactionId, paymentDate: $paymentDate, amountpaid: $amountpaid, type: $type, createdDate: $createdDate)';
  }

  @override
  bool operator ==(covariant Payment other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.transactionId == transactionId &&
        other.paymentDate == paymentDate &&
        other.amountpaid == amountpaid &&
        other.type == type &&
        other.createdDate == createdDate;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        transactionId.hashCode ^
        paymentDate.hashCode ^
        amountpaid.hashCode ^
        type.hashCode ^
        createdDate.hashCode;
  }
}
