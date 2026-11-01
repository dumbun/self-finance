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
    required this.signature,
    required this.createdDate,
    this.verificationToken,
  });

  final String? id;
  final String customerId;
  final String itemId;
  final DateTime transacrtionDate;
  final String transacrtionType;
  final double amount;
  final double intrestRate;
  final double intrestAmount;
  final double remainingAmount;
  final String signature;
  final DateTime createdDate;
  final String? verificationToken;

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
        id: e["Transaction_ID"]?.toString(),
        customerId: e["Customer_ID"]?.toString() ?? '',
        itemId: e["Item_ID"]?.toString() ?? '',
        transacrtionDate: e["Transaction_Date"],
        transacrtionType: e["Transaction_Type"],
        amount: e["Amount"],
        intrestRate: e["Interest_Rate"],
        intrestAmount: e["Interest_Amount"],
        remainingAmount: e["Remaining_Amount"],
        signature: e["Signature"],
        createdDate: e["Created_Date"],
        verificationToken: e["Verification_Token"]?.toString(),
      );
    }).toList();
  }

  Trx copyWith({
    String? id,
    String? customerId,
    String? itemId,
    DateTime? transacrtionDate,
    String? transacrtionType,
    double? amount,
    double? intrestRate,
    double? intrestAmount,
    double? remainingAmount,
    String? proofPhoto,
    String? signature,
    DateTime? createdDate,
    String? verificationToken,
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
      signature: signature ?? this.signature,
      createdDate: createdDate ?? this.createdDate,
      verificationToken: verificationToken ?? this.verificationToken,
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
      'signature': signature,
      'createdDate': createdDate,
      'verificationToken': verificationToken,
    };
  }

  factory Trx.fromMap(Map<String, dynamic> map) {
    return Trx(
      id: map['id']?.toString(),
      customerId: map['customerId']?.toString() ?? '',
      itemId: map['itemId']?.toString() ?? '',
      transacrtionDate: map['transacrtionDate'] is DateTime
          ? map['transacrtionDate'] as DateTime
          : DateTime.tryParse(map['transacrtionDate']?.toString() ?? '') ??
              DateTime.now(),
      transacrtionType: map['transacrtionType']?.toString() ?? '',
      amount: (map['amount'] is num)
          ? (map['amount'] as num).toDouble()
          : double.tryParse(map['amount']?.toString() ?? '0.0') ?? 0.0,
      intrestRate: (map['intrestRate'] is num)
          ? (map['intrestRate'] as num).toDouble()
          : double.tryParse(map['intrestRate']?.toString() ?? '0.0') ?? 0.0,
      intrestAmount: (map['intrestAmount'] is num)
          ? (map['intrestAmount'] as num).toDouble()
          : double.tryParse(map['intrestAmount']?.toString() ?? '0.0') ?? 0.0,
      remainingAmount: (map['remainingAmount'] is num)
          ? (map['remainingAmount'] as num).toDouble()
          : double.tryParse(map['remainingAmount']?.toString() ?? '0.0') ?? 0.0,
      signature: map['signature']?.toString() ?? '',
      createdDate: map['createdDate'] is DateTime
          ? map['createdDate'] as DateTime
          : DateTime.tryParse(map['createdDate']?.toString() ?? '') ??
              DateTime.now(),
      verificationToken: map['verificationToken']?.toString(),
    );
  }

  @override
  String toString() {
    return 'Transaction(id: $id, customerId: $customerId, itemId: $itemId, transacrtionDate: $transacrtionDate, transacrtionType: $transacrtionType, amount: $amount, intrestRate: $intrestRate, intrestAmount: $intrestAmount, remainingAmount: $remainingAmount, signature: $signature, createdDate: $createdDate)';
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
        other.signature == signature &&
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
        signature.hashCode ^
        createdDate.hashCode;
  }
}
