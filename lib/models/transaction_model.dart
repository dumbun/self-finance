import 'dart:convert';

class Transaction {
  int? id;
  final int customerId;
  final int itemId;
  final DateTime transacrtionDate;
  final String transacrtionType;
  final double amount;
  final double intrestRate;
  final double intrestAmount;
  final double remainingAmount;
  final String proofPhoto;
  final DateTime createdDate;

  Transaction({
    this.id,
    required this.customerId,
    required this.itemId,
    required this.transacrtionDate,
    required this.transacrtionType,
    required this.amount,
    required this.intrestRate,
    required this.intrestAmount,
    required this.remainingAmount,
    required this.proofPhoto,
    required this.createdDate,
  });

  static List<Transaction> toList(List<Map<String, dynamic>> data) {
    if (data.isEmpty) {
      return []; // If data is empty, return an empty list directly
    }

    return data.map((e) {
      return Transaction(
        id: e["Transaction_ID"],
        customerId: e["Customer_ID"],
        itemId: e["Item_ID"],
        transacrtionDate: e["Transaction_Date"],
        transacrtionType: e["Transaction_Type"],
        amount: e["Amount"],
        intrestRate: e["Interest_Rate"],
        intrestAmount: e["Interest_Amount"],
        remainingAmount: e["Remaining_Amount"],
        proofPhoto: e["Proof_Photo"],
        createdDate: e["Created_Date"],
      );
    }).toList();
  }

  Transaction copyWith({
    int? id,
    int? customerId,
    int? itemId,
    DateTime? transacrtionDate,
    String? transacrtionType,
    double? amount,
    double? intrestRate,
    double? intrestAmount,
    double? remainingAmount,
    String? proofPhoto,
    DateTime? createdDate,
  }) {
    return Transaction(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      itemId: itemId ?? this.itemId,
      transacrtionDate: transacrtionDate ?? this.transacrtionDate,
      transacrtionType: transacrtionType ?? this.transacrtionType,
      amount: amount ?? this.amount,
      intrestRate: intrestRate ?? this.intrestRate,
      intrestAmount: intrestAmount ?? this.intrestAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      proofPhoto: proofPhoto ?? this.proofPhoto,
      createdDate: createdDate ?? this.createdDate,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'customerId': customerId,
      'itemId': itemId,
      'transacrtionDate': transacrtionDate.millisecondsSinceEpoch,
      'transacrtionType': transacrtionType,
      'amount': amount,
      'intrestRate': intrestRate,
      'intrestAmount': intrestAmount,
      'remainingAmount': remainingAmount,
      'proofPhoto': proofPhoto,
      'createdDate': createdDate.millisecondsSinceEpoch,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] != null ? map['id'] as int : null,
      customerId: map['customerId'] as int,
      itemId: map['itemId'] as int,
      transacrtionDate: DateTime.fromMillisecondsSinceEpoch(map['transacrtionDate'] as int),
      transacrtionType: map['transacrtionType'] as String,
      amount: map['amount'] as double,
      intrestRate: map['intrestRate'] as double,
      intrestAmount: map['intrestAmount'] as double,
      remainingAmount: map['remainingAmount'] as double,
      proofPhoto: map['proofPhoto'] as String,
      createdDate: DateTime.fromMillisecondsSinceEpoch(map['createdDate'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory Transaction.fromJson(String source) => Transaction.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Transactions(id: $id, customerId: $customerId, itemId: $itemId, transacrtionDate: $transacrtionDate, transacrtionType: $transacrtionType, amount: $amount, intrestRate: $intrestRate, intrestAmount: $intrestAmount, remainingAmount: $remainingAmount, proofPhoto: $proofPhoto, createdDate: $createdDate)';
  }

  @override
  bool operator ==(covariant Transaction other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.customerId == customerId &&
        other.itemId == itemId &&
        other.transacrtionDate == transacrtionDate &&
        other.transacrtionType == transacrtionType &&
        other.amount == amount &&
        other.intrestRate == intrestRate &&
        other.intrestAmount == intrestAmount &&
        other.remainingAmount == remainingAmount &&
        other.proofPhoto == proofPhoto &&
        other.createdDate == createdDate;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        customerId.hashCode ^
        itemId.hashCode ^
        transacrtionDate.hashCode ^
        transacrtionType.hashCode ^
        amount.hashCode ^
        intrestRate.hashCode ^
        intrestAmount.hashCode ^
        remainingAmount.hashCode ^
        proofPhoto.hashCode ^
        createdDate.hashCode;
  }
}
