import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:self_finance/backend/user_db.dart' show UserBackEnd;
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/models/user_model.dart';
import 'package:self_finance/views/pin_auth_view.dart';
import 'package:self_finance/views/terms_and_conditions.dart';

class AuthView extends StatelessWidget {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: UserBackEnd.fetchIDOneUser(),
      builder: (BuildContext context, AsyncSnapshot<List<User>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const Center(child: CircularProgressIndicator());
          default:
            if (snapshot.hasError) {
              return BodyOneDefaultText(text: 'Error: ${snapshot.error}');
            } else {
              if (snapshot.data!.isNotEmpty) {
                return PinAuthView(userDate: snapshot.requireData);
              } else {
                getPermissions();
                return const TermsAndConditons();
              }
            }
        }
      },
    );
  }

  void getPermissions() async {
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
