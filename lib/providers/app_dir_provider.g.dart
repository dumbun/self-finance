// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_dir_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appDir)
final appDirProvider = AppDirProvider._();

final class AppDirProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  AppDirProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDirProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDirHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return appDir(ref);
  }
}

String _$appDirHash() => r'8d417624e17ada353b68ba92dc3275674a8c0930';
