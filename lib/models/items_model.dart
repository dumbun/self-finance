// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Items {
  final int? id;
  final int customerid;
  final String name;
  final String description;
  final DateTime pawnedDate;
  final DateTime expiryDate;
  final double pawnAmount;
  final String status;
  final DateTime createdDate;

  Items({
    this.id,
    required this.customerid,
    required this.name,
    required this.description,
    required this.pawnedDate,
    required this.expiryDate,
    required this.pawnAmount,
    required this.status,
    required this.createdDate,
  });

  static List<Items> toList(List<Map<String, dynamic>> data) {
    if (data.isEmpty) {
      return []; // If data is empty, return an empty list directly
    }
    return data.map((e) {
      return Items(
        id: e["Item_ID"],
        customerid: e["Customer_ID"],
        name: e["Item_Name"],
        description: e["Item_Description"],
        pawnedDate: e["Pawned_Date"],
        expiryDate: e["Expiry_Date"],
        pawnAmount: e["Pawn_Amount"],
        status: e["Item_Status"],
        createdDate: e["Created_Date"],
      );
    }).toList();
  }

  Items copyWith({
    int? id,
    int? customerid,
    String? name,
    String? description,
    DateTime? pawnedDate,
    DateTime? expiryDate,
    double? pawnAmount,
    String? status,
    DateTime? createdDate,
  }) {
    return Items(
      id: id ?? this.id,
      customerid: customerid ?? this.customerid,
      name: name ?? this.name,
      description: description ?? this.description,
      pawnedDate: pawnedDate ?? this.pawnedDate,
      expiryDate: expiryDate ?? this.expiryDate,
      pawnAmount: pawnAmount ?? this.pawnAmount,
      status: status ?? this.status,
      createdDate: createdDate ?? this.createdDate,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'customerid': customerid,
      'name': name,
      'description': description,
      'pawnedDate': pawnedDate.millisecondsSinceEpoch,
      'expiryDate': expiryDate.millisecondsSinceEpoch,
      'pawnAmount': pawnAmount,
      'status': status,
      'createdDate': createdDate.millisecondsSinceEpoch,
    };
  }

  factory Items.fromMap(Map<String, dynamic> map) {
    return Items(
      id: map['id'] != null ? map['id'] as int : null,
      customerid: map['customerid'] as int,
      name: map['name'] as String,
      description: map['description'] as String,
      pawnedDate: DateTime.fromMillisecondsSinceEpoch(map['pawnedDate'] as int),
      expiryDate: DateTime.fromMillisecondsSinceEpoch(map['expiryDate'] as int),
      pawnAmount: map['pawnAmount'] as double,
      status: map['status'] as String,
      createdDate: DateTime.fromMillisecondsSinceEpoch(map['createdDate'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory Items.fromJson(String source) => Items.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Items(id: $id, customerid: $customerid, name: $name, description: $description, pawnedDate: $pawnedDate, expiryDate: $expiryDate, pawnAmount: $pawnAmount, status: $status, createdDate: $createdDate)';
  }

  @override
  bool operator ==(covariant Items other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.customerid == customerid &&
        other.name == name &&
        other.description == description &&
        other.pawnedDate == pawnedDate &&
        other.expiryDate == expiryDate &&
        other.pawnAmount == pawnAmount &&
        other.status == status &&
        other.createdDate == createdDate;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        customerid.hashCode ^
        name.hashCode ^
        description.hashCode ^
        pawnedDate.hashCode ^
        expiryDate.hashCode ^
        pawnAmount.hashCode ^
        status.hashCode ^
        createdDate.hashCode;
  }
}
