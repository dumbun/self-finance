import 'dart:convert';

class Customer {
  int? id;
  final String name;
  final String guardianName;
  final String address;
  final String number;
  final String photo;
  final DateTime createdDate;

  Customer({
    this.id,
    required this.name,
    required this.guardianName,
    required this.address,
    required this.number,
    required this.photo,
    required this.createdDate,
  });

  static List<Customer> toList(List<Map<String, dynamic>> data) {
    List<Customer> userData = [];
    if (data != [] && data.isNotEmpty) {
      for (var e in data) {
        userData.add(
          Customer(
            id: e["Customer_ID"],
            name: e["Customer_Name"],
            guardianName: e["Gaurdian_Name"],
            address: e["Customer_Address"],
            number: e["Contact_Number"],
            photo: e["Customer_Photo"],
            createdDate: e["Created_Date"],
          ),
        );
      }
    }
    return userData;
  }

  Customer copyWith({
    int? id,
    String? name,
    String? guardianName,
    String? address,
    String? number,
    String? photo,
    DateTime? createdDate,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      guardianName: guardianName ?? this.guardianName,
      address: address ?? this.address,
      number: number ?? this.number,
      photo: photo ?? this.photo,
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
      'createdDate': createdDate.millisecondsSinceEpoch,
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
      createdDate: DateTime.fromMillisecondsSinceEpoch(map['createdDate'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory Customer.fromJson(String source) => Customer.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Customer(id: $id, name: $name, guardianName: $guardianName, address: $address, number: $number, photo: $photo, createdDate: $createdDate)';
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
        createdDate.hashCode;
  }
}
