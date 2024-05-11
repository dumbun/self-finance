class Payment {
  int? id;
  final int transactionId;
  final String paymentDate;
  final double amountpaid;
  final String type;
  final String createdDate;
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
        id: e["Payment_ID"],
        transactionId: e["Transaction_ID"],
        paymentDate: e["Payment_Date"],
        amountpaid: e["Amount_Paid"],
        type: e["Payment_Type"],
        createdDate: e["Created_Date"],
      );
    }).toList();
  }

  Payment copyWith({
    int? id,
    int? transactionId,
    String? paymentDate,
    double? amountpaid,
    String? type,
    String? createdDate,
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
      id: map['id'] != null ? map['id'] as int : null,
      transactionId: map['transactionId'] as int,
      paymentDate: map['paymentDate'] as String,
      amountpaid: map['amountpaid'] as double,
      type: map['type'] as String,
      createdDate: map['createdDate'] as String,
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
