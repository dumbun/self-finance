import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class Utility {
  static Widget imageFromBase64String(String base64String, {double? height, double? width}) {
    final decodedImage = Image.memory(
      gaplessPlayback: true,
      base64Decode(base64String),
      fit: BoxFit.fill, // Adjust this based on your image's aspect ratio requirement
      height: height ?? 40.sp,
      width: height ?? 40.sp,
    );
    if (base64String.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(120.sp),
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
}

double reduceDecimals(double value) {
  return double.parse(value.toStringAsFixed(2));
}

double textToDouble(String value) {
  return double.parse(value);
}

int textToInt(String value) {
  return int.parse(value);
}

DateTime presentDate() {
  return DateTime.now();
}

Future<String> pickImageFromCamera() async {
  final ImagePicker picker = ImagePicker();
  String result = "";
  final imgFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 50);

  if (imgFile != null) {
    Uint8List imgBytes = Uint8List.fromList(await imgFile.readAsBytes());
    result = Utility.base64String(imgBytes);
  }

  return result;
}
