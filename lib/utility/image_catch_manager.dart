import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

/// [ImageCacheManager] is a manager used to save the images which are rendendered and this will helps to load imahes to faster
/// this manager checkes for the avilabele ram and stores the images with respect to the ram
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
