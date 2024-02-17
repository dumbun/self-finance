import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:self_finance/backend/user_db.dart';
import 'package:self_finance/models/user_model.dart';
part 'user_provider.g.dart';

@riverpod
class AsyncUser extends _$AsyncUser {
  Future<List<User>> _fetchAllUsers() async {
    return UserBackEnd.fetchIDOneUser();
  }

  @override
  FutureOr<List<User>> build() {
    // Load initial todo list from the remote repository
    return _fetchAllUsers();
  }

  Future<bool> addUser({required User user}) async {
    bool result = false;
    // Set the state to loading
    state = const AsyncValue.loading();
    // Add the new todo and reload the todo list from the remote repository
    state = await AsyncValue.guard(() async {
      result = await UserBackEnd.createNewUser(user);
      return _fetchAllUsers();
    });
    return result;
  }

  Future<void> updateUserProfile({required int userId, required String updatedImageString}) async {
    state = const AsyncValue.loading();
    // Add the new todo and reload the todo list from the remote repository
    state = await AsyncValue.guard(() async {
      await UserBackEnd.updateProfilePic(userId, updatedImageString);
      return _fetchAllUsers();
    });
  }

  Future<void> updateUserName({required int userId, required String updateUserName}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await UserBackEnd.updateUserName(userId, updateUserName);
      return _fetchAllUsers();
    });
  }

  Future<void> updateUserPin({required int userId, required String updateUserPin}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await UserBackEnd.updateUserPin(userId, updateUserPin);
      return _fetchAllUsers();
    });
  }
}
