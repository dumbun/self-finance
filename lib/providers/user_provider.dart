import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:self_finance/backend/user_database.dart';
import 'package:self_finance/models/user_model.dart';
part 'user_provider.g.dart';

@riverpod
class UserNotifier extends _$UserNotifier {
  Stream<User?> _fetchUser() {
    return UserBackEnd.watchUserData();
  }

  @override
  Stream<User?> build() {
    return _fetchUser();
  }

  Future<void> changeUserName({
    required int id,
    required String newUserName,
  }) async {
    try {
      await UserBackEnd.updateUserName(id: id, newUserName: newUserName);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> changeUserPin({required int id, required String newPin}) async {
    try {
      await UserBackEnd.updateUserPin(id: id, newPin: newPin);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> changeCurrency({
    required int id,
    required String newCurrency,
  }) async {
    try {
      await UserBackEnd.updateUserCurrency(id: id, currency: newCurrency);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> updateProfilePicture({
    required int id,
    required String photoPath,
  }) async {
    try {
      await UserBackEnd.updateProfilePicture(id: id, photoPath: photoPath);
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
