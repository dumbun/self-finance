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
        isAutoDispose: true,
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

String _$appDirHash() => r'52e3d0f40771503bb484ba500b4500f4fd6658a4';
