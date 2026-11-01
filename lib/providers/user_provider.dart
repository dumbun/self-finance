import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:self_finance/backend/user_database.dart';
import 'package:self_finance/core/utility/image_saving_utility.dart';
import 'package:self_finance/core/utility/invoice_generator_utility.dart';
import 'package:self_finance/models/user_model.dart';
import 'package:self_finance/providers/auth_provider.dart';
part 'user_provider.g.dart';

@Riverpod(keepAlive: true)
class UserNotifier extends _$UserNotifier {
  Stream<User?> _fetchUser() {
    // Guard: if the account-scoped database hasn't been opened yet,
    // don't fall through to the legacy default database.
    if (UserBackEnd.activeDatabase == null) {
      return Stream.value(null);
    }
    return UserBackEnd.watchUserData();
  }

  @override
  Stream<User?> build() {
    ref.watch(authStateProvider);
    return _fetchUser();
  }

  Future<void> changeUserName({
    required int id,
    required String newUserName,
  }) async {
    try {
      await UserBackEnd.updateUserName(id: id, newUserName: newUserName);
      InvoiceGenerator.clearUserCache();
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
      InvoiceGenerator.clearUserCache();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> removeProfilePic({required int userId}) async {
    try {
      await UserBackEnd.deleteUserProfilePic(id: userId);
      InvoiceGenerator.clearUserCache();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> updateProfilePicture({
    required int id,
    required String photoPath,
    required bool camera,
  }) async {
    try {
      final String newImagePath = await ImageSavingUtility.updateUserImage(
        userImage: photoPath,
        camera: camera,
      );
      if (newImagePath.isNotEmpty) {
        await UserBackEnd.updateProfilePicture(id: id, photoPath: newImagePath);
        InvoiceGenerator.clearUserCache();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
