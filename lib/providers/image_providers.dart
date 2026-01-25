import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:image_picker/image_picker.dart';

part 'image_providers.g.dart';

@riverpod
class ImageFile extends _$ImageFile {
  @override
  XFile? build() => null;

  void set(XFile? file) => state = file;

  void clear() => state = null;
}

@riverpod
class ProofFile extends _$ProofFile {
  @override
  XFile? build() => null;

  void set(XFile? file) => state = file;

  void clear() => state = null;
}

@riverpod
class ItemFile extends _$ItemFile {
  @override
  XFile? build() => null;

  void set(XFile? file) => state = file;

  void clear() => state = null;
}
