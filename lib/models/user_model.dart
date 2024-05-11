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

  static List<User> toList(List<Map<String, Object?>> data) {
    if (data.isNotEmpty) {
      return data.map((e) {
        return User(
          id: e['ID'] as int,
          userName: e['USER_NAME'] as String,
          userPin: e['USER_PIN'] as String,
          profilePicture: e['USER_PROFILE_PICTURE'] as String,
          userCurrency: e['USER_CURRENCY'] as String,
        );
      }).toList();
    } else {
      return [];
    }
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
