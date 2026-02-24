import 'dart:core';
import 'dart:io';

import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/models/user_model.dart';
import 'package:self_finance/views/pin_auth_view.dart';
import 'package:signature/signature.dart';
import 'package:url_launcher/url_launcher.dart';

class Utility {
  static Future<void> closeApp({
    required BuildContext context,
    required User userData,
  }) async {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return PinAuthView(userDate: userData);
        },
      ),
      (Route<dynamic> route) => false,
    );
    BackEnd.close();
    await FlutterExitApp.exitApp();
  }

  static String formatDate({required DateTime date}) {
    try {
      return DateFormat("dd-MM-yyyy").format(date);
    } catch (e) {
      Exception(e.toString());
      return "";
    }
  }

  /// Format numbers compactly for charts (e.g., 1000 -> 1K, 1000000 -> 1M)
  static String compactNumber(double value) {
    if (value >= 10000000) {
      return '${(value / 10000000).toStringAsFixed(1)}Cr';
    } else if (value >= 100000) {
      return '${(value / 100000).toStringAsFixed(1)}L';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }

  /// [getAppVersion] this method provides application version
  ///code taken from (https://www.geeksforgeeks.org/flutter-how-to-get-app-name-package-name-version-build-number/)
  // app version provider
  static Future<String> getAppVersion() async {
    String? version;
    await PackageInfo.fromPlatform().then((PackageInfo value) {
      version = ("${value.version}+${value.buildNumber}").toString();
      // Value will be our all details we get from package info package
    });
    return version ?? "";
  }

  // send feedback email

  static void sendFeedbackEmail(BuildContext context) {
    BetterFeedback.of(context).show((feedback) async {
      // draft an email and send to developer
      final screenshotFilePath = await Utility.writeImageToStorage(
        feedback.screenshot,
      );

      final Email email = Email(
        body: feedback.text,
        subject: Constant.feedbackSubject,
        recipients: [Constant.applicationHandleEmail],
        attachmentPaths: [screenshotFilePath],
        isHTML: false,
      );
      await FlutterEmailSender.send(email);
    });
  }

  // writefeedback image to the storage
  static Future<String> writeImageToStorage(
    Uint8List feedbackScreenshot,
  ) async {
    final Directory output = await getTemporaryDirectory();
    final String screenshotFilePath = '${output.path}/feedback.png';
    final File screenshotFile = File(screenshotFilePath);
    await screenshotFile.writeAsBytes(feedbackScreenshot);
    return screenshotFilePath;
  }

  // make call
  static void makeCall({required String phoneNumber}) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (!await launchUrl(launchUri)) {
      throw Exception('Could not launch $launchUri');
    }
  }

  static Future<void> launchInBrowserView(String url) async {
    final Uri toLaunch = Uri.parse(url);
    if (!await launchUrl(toLaunch, mode: LaunchMode.inAppBrowserView)) {
      throw Exception('Could not launch $url');
    }
  }

  // to unfocus keyboard when user touches the white space in screen
  static void unfocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  static String numberFormate(int number) {
    return NumberFormat('#,##0').format(number);
  }

  static String doubleFormate(double number) {
    return NumberFormat('#,##0').format(number);
  }

  static Future<bool> isNumberPresent(String value) async {
    final List<String> a = await BackEnd.fetchAllCustomerNumbers();
    return a.contains(value);
  }

  static bool isValidPhoneNumber(String? value) => RegExp(
    r'(^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}$)',
  ).hasMatch(value ?? '');

  static double reduceDecimals(double value) {
    return double.parse(value.toStringAsFixed(2));
  }

  static double textToDouble(String value) {
    return double.parse(value);
  }

  static int textToInt(String value) {
    return int.parse(value);
  }

  static DateTime presentDate() {
    return DateTime.now();
  }

  static String? amountValidation({required String? value}) {
    if (value == null || value.isEmpty || value == "") {
      return 'Please enter a valid value';
    }
    if (value.contains(",") || value.contains(" ") || value.contains("-")) {
      return "please enter the correct value";
    } else {
      return null;
    }
  }

  static Future<String> saveSignaturesInStorage({
    required SignatureController signatureController,
    required String imageName,
  }) async {
    // [saveSignaturesInStorage] returns the path of the file in a future String
    // checks wether the signature pad is empty
    try {
      if (signatureController.isNotEmpty) {
        final Uint8List? bytes = await signatureController.toPngBytes(
          height: 300,
          width: 300,
        );
        if (bytes != null && signatureController.isNotEmpty) {
          final Directory applicationDocumentDirectory =
              await getApplicationDocumentsDirectory();
          String path = applicationDocumentDirectory.path;
          // create directory on external storage
          await Directory('$path/Images/signatures').create(recursive: true);
          final String fullImageName =
              "signature_itemid_${imageName}_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now()}.png";
          String fullPath = '$path/Images/signatures/$fullImageName';
          final File file = File(fullPath);
          await file.writeAsBytes(bytes, flush: true);
          return p.join("Images", "signatures", fullImageName);
        }
      }
      return "";
    } catch (e) {
      SnackBar(content: Text(e.toString()));
      rethrow;
    }
  }
}
