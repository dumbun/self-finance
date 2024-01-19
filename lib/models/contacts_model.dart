import 'dart:convert';

class Contact {
  final int id;
  final String name;
  final String number;
  Contact({
    required this.id,
    required this.name,
    required this.number,
  });

  static List<Contact> toList(List<Map<String, Object?>> data) {
    if (data.isEmpty) {
      return []; // If data is empty, return an empty list directly
    }
    return data.map((e) {
      return Contact(
        id: e["Customer_ID"] as int,
        name: e["Customer_Name"] as String,
        number: e["Contact_Number"] as String,
      );
    }).toList();
  }

  Contact copyWith({
    int? id,
    String? name,
    String? number,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      number: number ?? this.number,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'number': number,
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'] as int,
      name: map['name'] as String,
      number: map['number'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Contact.fromJson(String source) => Contact.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Contact(id: $id, name: $name, number: $number)';

  @override
  bool operator ==(covariant Contact other) {
    if (identical(this, other)) return true;

    return other.id == id && other.name == name && other.number == number;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ number.hashCode;
}
