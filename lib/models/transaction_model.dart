class Trx {
  Trx({
    this.id,
    required this.customerId,
    required this.itemId,
    required this.transacrtionDate,
    required this.transacrtionType,
    required this.amount,
    required this.intrestRate,
    required this.intrestAmount,
    required this.remainingAmount,
    required this.createdDate,
  });

  int? id;
  final int customerId;
  final int itemId;
  final String transacrtionDate;
  final String transacrtionType;
  final double amount;
  final double intrestRate;
  final double intrestAmount;
  final double remainingAmount;
  final String createdDate;

  /// [Trx] is a shortform of Transaction class
  /// using this class we can create a [Transaction] which contains the
  /// 1. [customerId] : which is used for the reference the [Customer] in the data base
  /// 2. [itemId] : which is used for the reference the [Item] in the DataBase
  /// 3. [transacrtionDate] : the time when transaction take place
  /// 4. [transacrtionType] : the type of trancation [Debit] or [Credit]
  /// 5. [amount] : Amount involved in the transaction
  /// 6. [intrestRate] : rate of intrest for the transaction
  /// 7. [remainingAmount] : remaning amount after the transaction
  /// 8. [proofPhoto] : proof of the customer who did the transaction
  /// 9. [createdDate] : when the transaction happened

  static List<Trx> toList(List<Map<String, dynamic>> data) {
    if (data.isEmpty) {
      return []; // If data is empty, return an empty list directly
    }

    return data.map((e) {
      return Trx(
        id: e["Transaction_ID"],
        customerId: e["Customer_ID"],
        itemId: e["Item_ID"],
        transacrtionDate: e["Transaction_Date"],
        transacrtionType: e["Transaction_Type"],
        amount: e["Amount"],
        intrestRate: e["Interest_Rate"],
        intrestAmount: e["Interest_Amount"],
        remainingAmount: e["Remaining_Amount"],
        createdDate: e["Created_Date"],
      );
    }).toList();
  }

  Trx copyWith({
    int? id,
    int? customerId,
    int? itemId,
    String? transacrtionDate,
    String? transacrtionType,
    double? amount,
    double? intrestRate,
    double? intrestAmount,
    double? remainingAmount,
    String? proofPhoto,
    String? createdDate,
  }) {
    return Trx(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      itemId: itemId ?? this.itemId,
      transacrtionDate: transacrtionDate ?? this.transacrtionDate,
      transacrtionType: transacrtionType ?? this.transacrtionType,
      amount: amount ?? this.amount,
      intrestRate: intrestRate ?? this.intrestRate,
      intrestAmount: intrestAmount ?? this.intrestAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      createdDate: createdDate ?? this.createdDate,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'customerId': customerId,
      'itemId': itemId,
      'transacrtionDate': transacrtionDate,
      'transacrtionType': transacrtionType,
      'amount': amount,
      'intrestRate': intrestRate,
      'intrestAmount': intrestAmount,
      'remainingAmount': remainingAmount,
      'createdDate': createdDate,
    };
  }

  factory Trx.fromMap(Map<String, dynamic> map) {
    return Trx(
      id: map['id'] != null ? map['id'] as int : null,
      customerId: map['customerId'] as int,
      itemId: map['itemId'] as int,
      transacrtionDate: map['transacrtionDate'] as String,
      transacrtionType: map['transacrtionType'] as String,
      amount: map['amount'] as double,
      intrestRate: map['intrestRate'] as double,
      intrestAmount: map['intrestAmount'] as double,
      remainingAmount: map['remainingAmount'] as double,
      createdDate: map['createdDate'] as String,
    );
  }

  @override
  String toString() {
    return 'Transaction(id: $id, customerId: $customerId, itemId: $itemId, transacrtionDate: $transacrtionDate, transacrtionType: $transacrtionType, amount: $amount, intrestRate: $intrestRate, intrestAmount: $intrestAmount, remainingAmount: $remainingAmount, createdDate: $createdDate)';
  }

  @override
  bool operator ==(covariant Trx other) {
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
        createdDate.hashCode;
  }
}
