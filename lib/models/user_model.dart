import 'dart:convert';

class User {
  final int? id;
  final String userName;
  final String userPin;
  final String profilePicture;
  final String userCurrency;

  User({
    this.id,
    required this.userName,
    required this.userPin,
    required this.profilePicture,
    required this.userCurrency,
  });

  static List<User> toList(data) {
    List<User> userData = [];
    if (data != []) {
      data.forEach((Map<String, dynamic> e) {
        userData.add(User(
            id: e['ID'],
            userName: e['USER_NAME'],
            userPin: e['USER_PIN'],
            profilePicture: e['USER_PROFILE_PICTURE'],
            userCurrency: e['USER_CURRENCY']));
      });
    }
    return userData;
  }

  User copyWith({
    int? id,
    String? userName,
    String? userPin,
    String? profilePicture,
    String? userCurrency,
  }) {
    return User(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      userPin: userPin ?? this.userPin,
      profilePicture: profilePicture ?? this.profilePicture,
      userCurrency: userCurrency ?? this.userCurrency,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userName': userName,
      'userPin': userPin,
      'profilePicture': profilePicture,
      'userCurrency': userCurrency,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] != null ? map['id'] as int : null,
      userName: map['userName'] as String,
      userPin: map['userPin'] as String,
      profilePicture: map['profilePicture'] as String,
      userCurrency: map['userCurrency'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'User(id: $id, userName: $userName, userPin: $userPin, profilePicture: $profilePicture, userCurrency: $userCurrency)';
  }

  @override
  bool operator ==(covariant User other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.userName == userName &&
        other.userPin == userPin &&
        other.profilePicture == profilePicture &&
        other.userCurrency == userCurrency;
  }

  @override
  int get hashCode {
    return id.hashCode ^ userName.hashCode ^ userPin.hashCode ^ profilePicture.hashCode ^ userCurrency.hashCode;
  }
}
