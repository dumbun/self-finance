import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/models/user_model.dart';
import 'package:self_finance/providers/user_provider.dart';
import 'package:self_finance/views/pin_auth_view.dart';
import 'package:self_finance/views/terms_and_conditions.dart';

class AuthView extends ConsumerWidget {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(userProvider)
        .when(
          data: (User? data) {
            final User? user = data;
            if (user == null) {
              _getPermissions();
              return const TermsAndConditons();
            } else {
              return PinAuthView(userDate: user);
            }
          },
          error: (error, stackTrace) =>
              const BodyTwoDefaultText(text: Constant.errorUserFetch),
          loading: () =>
              const Center(child: CircularProgressIndicator.adaptive()),
        );
  }

  void _getPermissions() async {
    PermissionStatus camera = await Permission.camera.status;
    PermissionStatus photos = await Permission.photos.status;
    PermissionStatus storageStatus = await Permission.storage.status;

    if (camera.isDenied) {
      await Permission.camera.request();
    }
    if (photos.isDenied) {
      await Permission.photos.request();
    }
    if (storageStatus.isDenied) {
      await Permission.storage.request();
    }
  }
}
