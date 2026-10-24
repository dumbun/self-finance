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
        isAutoDispose: false,
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

String _$itDataDatabaseHash() => r'd1c8fb31fecc0fe987ecad28ec78c5299bf39e96';

@ProviderFor(userDatabase)
final userDatabaseProvider = UserDatabaseProvider._();

final class UserDatabaseProvider
    extends $FunctionalProvider<UserDatabase, UserDatabase, UserDatabase>
    with $Provider<UserDatabase> {
  UserDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userDatabaseHash();

  @$internal
  @override
  $ProviderElement<UserDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UserDatabase create(Ref ref) {
    return userDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserDatabase>(value),
    );
  }
}

String _$userDatabaseHash() => r'74df672cd636c7276288b79b02b8a1789299f6ef';
