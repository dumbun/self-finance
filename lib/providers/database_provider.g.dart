// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// NOTE:
/// With the new drift-based `BackEnd` (singleton), you usually don't need a
/// separate database provider.
/// This is kept for backwards compatibility. Prefer using `BackEnd` directly.

@ProviderFor(itDataDatabase)
final itDataDatabaseProvider = ItDataDatabaseProvider._();

/// NOTE:
/// With the new drift-based `BackEnd` (singleton), you usually don't need a
/// separate database provider.
/// This is kept for backwards compatibility. Prefer using `BackEnd` directly.

final class ItDataDatabaseProvider
    extends $FunctionalProvider<ItDataDatabase, ItDataDatabase, ItDataDatabase>
    with $Provider<ItDataDatabase> {
  /// NOTE:
  /// With the new drift-based `BackEnd` (singleton), you usually don't need a
  /// separate database provider.
  /// This is kept for backwards compatibility. Prefer using `BackEnd` directly.
  ItDataDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'itDataDatabaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$itDataDatabaseHash();

  @$internal
  @override
  $ProviderElement<ItDataDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ItDataDatabase create(Ref ref) {
    return itDataDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ItDataDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ItDataDatabase>(value),
    );
  }
}

String _$itDataDatabaseHash() => r'10d09d61e0ad2b8ca205cf6f715b938d2d528a27';
