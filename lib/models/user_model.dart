class User {
  final int? id;
  final String userName;
  final String userPin;
  final String profilePicture;

  User({this.id, required this.userName, required this.userPin, required this.profilePicture});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userName': userName,
      'userPin': userPin,
      'profilePicture': profilePicture,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id']?.toInt(),
      userName: map['userName'] ?? '',
      userPin: map['userPin'] ?? '',
      profilePicture: map['profilePicture'] ?? '',
    );
  }

  static List<User> toList(data) {
    List<User> userData = [];
    if (data != []) {
      data.forEach((Map<String, dynamic> e) {
        userData.add(User(
          id: e["ID"],
          userName: e["USER_NAME"],
          userPin: e["USER_PIN"],
          profilePicture: e["USER_PROFILE_PICTURE"],
        ));
      });
    }
    return userData;
  }
}
