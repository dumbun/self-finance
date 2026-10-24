// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_dir_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appDir)
final appDirProvider = AppDirProvider._();

final class AppDirProvider extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
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
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return appDir(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$appDirHash() => r'1192e2635821abb05b43fc456134a2317de5e782';
