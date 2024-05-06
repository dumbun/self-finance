import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

/// [ImageCacheManager] is a manager used to save the images which are rendendered and this will helps to load imahes to faster
/// this manager checkes for the avilabele ram and stores the images with respect to the ram
class ImageCacheManager {
  static final Map<String, Image> _imageCache = {};

  static Image getCachedImage(String base64String, double? height, double? width) {
    if (_imageCache.containsKey(base64String)) {
      final cachedImage = _imageCache[base64String]!;
      _reorderCache(base64String, cachedImage);
      return cachedImage;
    } else {
      final Image decodedImage = Image.memory(
        gaplessPlayback: true,
        base64Decode(base64String),
        fit: BoxFit.cover,
        height: height ?? 40.sp,
        width: height ?? 40.sp,
      );

      if (_imageCache.length >= 60) {
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
