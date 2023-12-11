import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/backend/user_db.dart';
import 'package:self_finance/models/user_model.dart';

final userDataProvider = FutureProvider<List>((ref) async {
  List result = await UserBackEnd.fetchUserData();
  return result;
});

final up = StateProvider<User>((ref) => User(userName: "", userPin: "", profilePicture: ""));
