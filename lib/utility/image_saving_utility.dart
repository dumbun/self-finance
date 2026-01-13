// import 'dart:io';
// import 'dart:typed_data';
// import 'dart:ui' as ui;

// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:path_provider/path_provider.dart';

// class ImageSavingUtility {
//   //// Save Signature
//   static void saveSignaturesInStorage({
//     required GlobalKey<SfSignaturePadState> signatureGlobalKey,
//     required String imageName,
//   }) async {
//     List<Path> paths = signatureGlobalKey.currentState!.toPathList();
//     // checks wether the signature pad is empty
//     if (paths.isNotEmpty) {
//       final ui.Image data = await signatureGlobalKey.currentState!.toImage(pixelRatio: 3.0);
//       final ByteData? bytes = await data.toByteData(format: ui.ImageByteFormat.png);
//       if (bytes != null && signatureGlobalKey.currentState != null) {
//         Directory applictionDocumentDirectory = await getApplicationDocumentsDirectory();
//         String path = applictionDocumentDirectory.path;
//         // create directory on external storage
//         await Directory('$path/signature').create(recursive: true);
//         File('$path/signature/$imageName.png').writeAsBytesSync(bytes.buffer.asInt8List());
//       }
//     }
//   }

// Save image

//   static void saveImage({
//     required String imageName,
//     required String locationName,
//     required XFile imageFile,
//   }) async {
//     Directory applictionDocumentDirectory = await getApplicationDocumentsDirectory();
//     String path = applictionDocumentDirectory.path;
//     // create directory on external storage
//     await Directory('$path/$locationName').create(recursive: true);
//     await imageFile.saveTo('$path/$locationName/$imageName');
//   }
// }
