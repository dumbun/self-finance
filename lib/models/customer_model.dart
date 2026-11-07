class Customer {
  final String? id;
  final int userID;
  final String name;
  final String guardianName;
  final String address;
  final String number;
  final String photo;
  final String proof;
  final DateTime createdDate;

  Customer({
    this.id,
    required this.userID,
    required this.name,
    required this.guardianName,
    required this.address,
    required this.number,
    required this.photo,
    required this.proof,
    required this.createdDate,
  });

  static Future<List<Customer>> toList(List<Map<String, Object?>> data) async {
    if (data.isEmpty) {
      return []; // If data is empty, return an empty list directly
    }
    return data.map((e) {
      return Customer(
        id: e["Customer_ID"]?.toString(),
        userID: (e["User_ID"] is num)
            ? (e["User_ID"] as num).toInt()
            : int.tryParse(e["User_ID"]?.toString() ?? '1') ?? 1,
        name: e["Customer_Name"]?.toString() ?? '',
        guardianName: e["Gaurdian_Name"]?.toString() ?? '',
        address: e["Customer_Address"]?.toString() ?? '',
        number: e["Contact_Number"]?.toString() ?? '',
        photo: e["Customer_Photo"]?.toString() ?? '',
        proof: e["Proof_Photo"]?.toString() ?? '',
        createdDate: e["Created_Date"] is DateTime
            ? e["Created_Date"] as DateTime
            : DateTime.tryParse(e["Created_Date"]?.toString() ?? '') ??
                DateTime.now(),
      );
    }).toList();
  }

  Customer copyWith({
    String? id,
    int? userID,
    String? name,
    String? guardianName,
    String? address,
    String? number,
    String? photo,
    String? proof,
    DateTime? createdDate,
  }) {
    return Customer(
      id: id ?? this.id,
      userID: userID ?? this.userID,
      name: name ?? this.name,
      guardianName: guardianName ?? this.guardianName,
      address: address ?? this.address,
      number: number ?? this.number,
      photo: photo ?? this.photo,
      proof: proof ?? this.proof,
      createdDate: createdDate ?? this.createdDate,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userID': userID,
      'name': name,
      'guardianName': guardianName,
      'address': address,
      'number': number,
      'photo': photo,
      'proof': proof,
      'createdDate': createdDate,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id']?.toString(),
      name: map['name']?.toString() ?? '',
      guardianName: map['guardianName']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      number: map['number']?.toString() ?? '',
      photo: map['photo']?.toString() ?? '',
      proof: map['proof']?.toString() ?? '',
      createdDate: map['createdDate'] is DateTime
          ? map['createdDate'] as DateTime
          : DateTime.tryParse(map['createdDate']?.toString() ?? '') ??
              DateTime.now(),
      userID: (map['userID'] is num)
          ? (map['userID'] as num).toInt()
          : int.tryParse(map['userID']?.toString() ?? '1') ?? 1,
    );
  }

  @override
  String toString() {
    return 'Customer(id: $id, userID: $userID, name: $name, guardianName: $guardianName, address: $address, number: $number, photo: $photo, proof: $proof, createdDate: $createdDate)';
  }

  @override
  bool operator ==(covariant Customer other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.userID == userID &&
        other.name == name &&
        other.guardianName == guardianName &&
        other.address == address &&
        other.number == number &&
        other.photo == photo &&
        other.proof == proof &&
        other.createdDate == createdDate;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userID.hashCode ^
        name.hashCode ^
        guardianName.hashCode ^
        address.hashCode ^
        number.hashCode ^
        photo.hashCode ^
        proof.hashCode ^
        createdDate.hashCode;
  }
}
