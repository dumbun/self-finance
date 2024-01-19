// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class ImageCacheManager {
  static final Map<String, Image> _imageCache = {};
  static int _maxCacheSize = 100;

  static const platform = MethodChannel('ramInfoChannel');

  static Future<void> updateMaxCacheSize() async {
    try {
      final totalRAM = await platform.invokeMethod('getTotalRAM');
      _maxCacheSize = _calculateMaxCacheSize(totalRAM);
    } on PlatformException catch (e) {
      print("Failed to get RAM info: ${e.message}");
      // Set a default cache size in case of failure
      _maxCacheSize = 100;
    }
  }

  static pr() async {
    final totalRAM = await platform.invokeMethod('getTotalRAM');
    print(totalRAM);
  }

  static int _calculateMaxCacheSize(int totalRAM) {
    // Adjust cache size based on available RAM
    if (totalRAM <= 1073741824) {
      return 40; // 1 GB or less
    } else if (totalRAM <= 2147483648) {
      return 60; // 2 GB
    } else {
      return 80; // More than 2 GB
    }
  }

  static Image getCachedImage(String base64String, double? height, double? width) {
    if (_imageCache.containsKey(base64String)) {
      final cachedImage = _imageCache[base64String]!;
      _reorderCache(base64String, cachedImage);
      return cachedImage;
    } else {
      final decodedImage = Image.memory(
        gaplessPlayback: true,
        base64Decode(base64String),
        fit: BoxFit.cover,
        height: height ?? 40.sp,
        width: height ?? 40.sp,
      );

      if (_imageCache.length >= _maxCacheSize) {
        _removeLeastUsedImage();
      }

      _imageCache[base64String] = decodedImage;
      return decodedImage;
    }
  }

  static void _reorderCache(String key, Image value) {
    _imageCache.remove(key);
    _imageCache[key] = value;
  }

  static void _removeLeastUsedImage() {
    _imageCache.remove(_imageCache.keys.first);
  }
}

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

  // to unfocus keyboard when user touches the white space in screen
  static void unfocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  static Widget imageFromBase64String(String base64String, {double? height, double? width}) {
    if (base64String.isNotEmpty) {
      final decodedImage = ImageCacheManager.getCachedImage(base64String, height, width);
      return ClipRRect(
        borderRadius: BorderRadius.circular(100.sp),
        child: decodedImage,
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
}

Future<String> pickImageFromCamera() async {
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

Future<String> pickImageFromGallery() async {
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
