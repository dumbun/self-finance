import 'package:material_ui/material_ui.dart';
import 'package:flutter/widget_previews.dart';

/// A [MultiPreview] annotation that generates both light and dark mode previews
/// for Flutter Widget Previewer.
final class MultiBrightnessPreview extends MultiPreview {
  const MultiBrightnessPreview({required this.name, this.previewGroup});

  final String name;
  final String? previewGroup;

  @override
  List<Preview> get previews => const [
        Preview(brightness: Brightness.light),
        Preview(brightness: Brightness.dark),
      ];

  @override
  List<Preview> transform() {
    final previews = super.transform();
    return previews.map((preview) {
      final builder = preview.toBuilder()
        ..group = previewGroup ?? 'Components'
        ..name = '$name - ${preview.brightness!.name}';
      return builder.build();
    }).toList();
  }
}
