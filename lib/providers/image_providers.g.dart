// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ImageFile)
final imageFileProvider = ImageFileProvider._();

final class ImageFileProvider extends $NotifierProvider<ImageFile, XFile?> {
  ImageFileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'imageFileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$imageFileHash();

  @$internal
  @override
  ImageFile create() => ImageFile();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(XFile? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<XFile?>(value),
    );
  }
}

String _$imageFileHash() => r'3be77a20999ab89d1479ae2c48d5ab7ba9bf3712';

abstract class _$ImageFile extends $Notifier<XFile?> {
  XFile? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<XFile?, XFile?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<XFile?, XFile?>,
              XFile?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(ProofFile)
final proofFileProvider = ProofFileProvider._();

final class ProofFileProvider extends $NotifierProvider<ProofFile, XFile?> {
  ProofFileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'proofFileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$proofFileHash();

  @$internal
  @override
  ProofFile create() => ProofFile();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(XFile? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<XFile?>(value),
    );
  }
}

String _$proofFileHash() => r'd99079d63f94cac85785d701273a90be77464f7c';

abstract class _$ProofFile extends $Notifier<XFile?> {
  XFile? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<XFile?, XFile?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<XFile?, XFile?>,
              XFile?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(ItemFile)
final itemFileProvider = ItemFileProvider._();

final class ItemFileProvider extends $NotifierProvider<ItemFile, XFile?> {
  ItemFileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'itemFileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$itemFileHash();

  @$internal
  @override
  ItemFile create() => ItemFile();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(XFile? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<XFile?>(value),
    );
  }
}

String _$itemFileHash() => r'af9a56d0d59bfb56acd5a53b521c78f9f2594afd';

abstract class _$ItemFile extends $Notifier<XFile?> {
  XFile? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<XFile?, XFile?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<XFile?, XFile?>,
              XFile?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
