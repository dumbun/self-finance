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
    if (data.isNotEmpty) {
      return List.generate(data.length, (index) {
        final e = data[index];
        return Contact(
          id: e["Customer_ID"] as int,
          name: e["Customer_Name"] as String,
          number: e["Contact_Number"] as String,
        );
      }, growable: false);
    }
    return []; // Return empty list if no data
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
