import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/utility/image_catch_manager.dart';
import 'package:url_launcher/url_launcher.dart';

class Utility {
  // make call
  static makeCall({required String phoneNumber}) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (!await launchUrl(launchUri)) {
      throw Exception('Could not launch $launchUri');
    }
  }

  static Future<void> launchInBrowserView(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.inAppBrowserView)) {
      throw Exception('Could not launch $url');
    }
  }

  // to unfocus keyboard when user touches the white space in screen
  static void unfocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  static Widget imageFromBase64String(String base64String, {double? height, double? width}) {
    if (base64String.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(100.sp),
        child: ImageCacheManager.getCachedImage(
          base64String,
          height,
          width,
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  static Uint8List dataFromBase64String(String base64String) {
    return base64Decode(base64String);
  }

  static String base64String(Uint8List data) {
    return base64Encode(data);
  }

  static String numberFormate(int number) {
    return NumberFormat('#,##0').format(number);
  }

  static String doubleFormate(double number) {
    return NumberFormat('#,##0').format(number);
  }

  static bool isValidPhoneNumber(String? value) =>
      RegExp(r'(^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}$)').hasMatch(value ?? '');

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

  static Future<String> pickImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    String result = "";

    final XFile? imgFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 25,
    );

    if (imgFile != null) {
      Uint8List imgBytes = Uint8List.fromList(
        await imgFile.readAsBytes(),
      );
      result = Utility.base64String(imgBytes);
    }

    return result;
  }

  static Future<String> pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    String result = "";

    final XFile? imgFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 25,
    );

    if (imgFile != null) {
      Uint8List imgBytes = Uint8List.fromList(
        await imgFile.readAsBytes(),
      );
      result = Utility.base64String(imgBytes);
    }

    return result;
  }
}
