class Items {
  final String? id;
  final String customerid;
  final String name;
  final String description;
  final DateTime pawnedDate;
  final DateTime expiryDate;
  final double pawnAmount;
  final String status;
  final String photo;
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
    required this.photo,
    required this.createdDate,
  });

  static List<Items> toList(List<Map<String, Object?>> data) {
    if (data.isEmpty) {
      return []; // If data is empty, return an empty list directly
    }
    return data.map((e) {
      return Items(
        id: e["Item_ID"]?.toString(),
        customerid: e["Customer_ID"]?.toString() ?? '',
        name: e["Item_Name"] as String,
        description: e["Item_Description"] as String,
        pawnedDate: e["Pawned_Date"] as DateTime,
        expiryDate: e["Expiry_Date"] as DateTime,
        pawnAmount: e["Pawn_Amount"] as double,
        status: e["Item_Status"] as String,
        photo: e["Item_Photo"] as String,
        createdDate: e["Created_Date"] as DateTime,
      );
    }).toList();
  }

  Items copyWith({
    String? id,
    String? customerid,
    String? name,
    String? description,
    DateTime? pawnedDate,
    DateTime? expiryDate,
    double? pawnAmount,
    String? status,
    String? photo,
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
      photo: photo ?? this.photo,
      createdDate: createdDate ?? this.createdDate,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'customerid': customerid,
      'name': name,
      'description': description,
      'pawnedDate': pawnedDate,
      'expiryDate': expiryDate,
      'pawnAmount': pawnAmount,
      'status': status,
      'photo': photo,
      'createdDate': createdDate,
    };
  }

  factory Items.fromMap(Map<String, dynamic> map) {
    return Items(
      id: map['id']?.toString(),
      customerid: map['customerid']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      pawnedDate: map['pawnedDate'] is DateTime
          ? map['pawnedDate'] as DateTime
          : DateTime.tryParse(map['pawnedDate']?.toString() ?? '') ??
              DateTime.now(),
      expiryDate: map['expiryDate'] is DateTime
          ? map['expiryDate'] as DateTime
          : DateTime.tryParse(map['expiryDate']?.toString() ?? '') ??
              DateTime.now(),
      pawnAmount: (map['pawnAmount'] is num)
          ? (map['pawnAmount'] as num).toDouble()
          : double.tryParse(map['pawnAmount']?.toString() ?? '0.0') ?? 0.0,
      status: map['status']?.toString() ?? '',
      photo: map['photo']?.toString() ?? '',
      createdDate: map['createdDate'] is DateTime
          ? map['createdDate'] as DateTime
          : DateTime.tryParse(map['createdDate']?.toString() ?? '') ??
              DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'Items(id: $id, customerid: $customerid, name: $name, description: $description, pawnedDate: $pawnedDate, expiryDate: $expiryDate, pawnAmount: $pawnAmount, status: $status, photo: $photo, createdDate: $createdDate)';
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
        other.photo == photo &&
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
        photo.hashCode ^
        createdDate.hashCode;
  }
}
