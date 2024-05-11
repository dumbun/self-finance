class Customer {
  final int? id;
  final int userID;
  final String name;
  final String guardianName;
  final String address;
  final String number;
  final String photo;
  final String proof;
  final String createdDate;

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

  static List<Customer> toList(List<Map<String, Object?>> data) {
    if (data.isEmpty) {
      return []; // If data is empty, return an empty list directly
    }
    return data.map((e) {
      return Customer(
        id: e["Customer_ID"] as int,
        userID: e["User_ID"] as int,
        name: e["Customer_Name"] as String,
        guardianName: e["Gaurdian_Name"] as String,
        address: e["Customer_Address"] as String,
        number: e["Contact_Number"] as String,
        photo: e["Customer_Photo"] as String,
        proof: e["Proof_Photo"] as String,
        createdDate: e["Created_Date"] as String,
      );
    }).toList();
  }

  Customer copyWith({
    int? id,
    int? userID,
    String? name,
    String? guardianName,
    String? address,
    String? number,
    String? photo,
    String? proof,
    String? createdDate,
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
      id: map['id'] != null ? map['id'] as int : null,
      name: map['name'] as String,
      guardianName: map['guardianName'] as String,
      address: map['address'] as String,
      number: map['number'] as String,
      photo: map['photo'] as String,
      proof: map['proof'] as String,
      createdDate: map['createdDate'] as String,
      userID: map['userID'] as int,
    );
  }

  @override
  String toString() {
    return 'Customer(id: $id, name: $name, guardianName: $guardianName, address: $address, number: $number, photo: $photo, proof: $proof, createdDate: $createdDate)';
  }

  @override
  bool operator ==(covariant Customer other) {
    if (identical(this, other)) return true;

    return other.id == id &&
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
        name.hashCode ^
        guardianName.hashCode ^
        address.hashCode ^
        number.hashCode ^
        photo.hashCode ^
        proof.hashCode ^
        createdDate.hashCode;
  }
}
