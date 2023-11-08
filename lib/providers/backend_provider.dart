import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/backend/user_db.dart';
import 'package:self_finance/models/user_model.dart';

final FutureProvider<User?> userDataProvider = FutureProvider<User?>((ref) async {
  try {
    User? result = await UserBackEnd.fetchUserData();
    return result;
  } catch (e) {
    print(e);
    return null;
  }
});
