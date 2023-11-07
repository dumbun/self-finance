import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:core';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class Utility {
  static Image imageFromBase64String(String base64String) {
    return Image.memory(
      base64Decode(base64String),
      fit: BoxFit.fill,
    );
  }

  static Uint8List dataFromBase64String(String base64String) {
    return base64Decode(base64String);
  }

  static String base64String(Uint8List data) {
    return base64Encode(data);
  }
}

double reduceDecimals(double value) {
  return double.parse(value.toStringAsFixed(1));
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
  final imgFile = await picker.pickImage(source: ImageSource.camera);

  if (imgFile != null) {
    Uint8List imgBytes = Uint8List.fromList(await imgFile.readAsBytes());
    result = Utility.base64String(imgBytes);
  }

  return result;
}
