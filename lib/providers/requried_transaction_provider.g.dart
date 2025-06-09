// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'requried_transaction_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$asyncRequriedTransactionsHash() =>
    r'da27fc7f3d4ca0eac653cf06cd81cd5889378342';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$AsyncRequriedTransactions
    extends BuildlessAutoDisposeAsyncNotifier<List<Trx>> {
  late final dynamic id;

  FutureOr<List<Trx>> build(
    dynamic id,
  );
}

/// See also [AsyncRequriedTransactions].
@ProviderFor(AsyncRequriedTransactions)
const asyncRequriedTransactionsProvider = AsyncRequriedTransactionsFamily();

/// See also [AsyncRequriedTransactions].
class AsyncRequriedTransactionsFamily extends Family<AsyncValue<List<Trx>>> {
  /// See also [AsyncRequriedTransactions].
  const AsyncRequriedTransactionsFamily();

  /// See also [AsyncRequriedTransactions].
  AsyncRequriedTransactionsProvider call(
    dynamic id,
  ) {
    return AsyncRequriedTransactionsProvider(
      id,
    );
  }

  @override
  AsyncRequriedTransactionsProvider getProviderOverride(
    covariant AsyncRequriedTransactionsProvider provider,
  ) {
    return call(
      provider.id,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'asyncRequriedTransactionsProvider';
}

/// See also [AsyncRequriedTransactions].
class AsyncRequriedTransactionsProvider
    extends AutoDisposeAsyncNotifierProviderImpl<AsyncRequriedTransactions,
        List<Trx>> {
  /// See also [AsyncRequriedTransactions].
  AsyncRequriedTransactionsProvider(
    dynamic id,
  ) : this._internal(
          () => AsyncRequriedTransactions()..id = id,
          from: asyncRequriedTransactionsProvider,
          name: r'asyncRequriedTransactionsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$asyncRequriedTransactionsHash,
          dependencies: AsyncRequriedTransactionsFamily._dependencies,
          allTransitiveDependencies:
              AsyncRequriedTransactionsFamily._allTransitiveDependencies,
          id: id,
        );

  AsyncRequriedTransactionsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final dynamic id;

  @override
  FutureOr<List<Trx>> runNotifierBuild(
    covariant AsyncRequriedTransactions notifier,
  ) {
    return notifier.build(
      id,
    );
  }

  @override
  Override overrideWith(AsyncRequriedTransactions Function() create) {
    return ProviderOverride(
      origin: this,
      override: AsyncRequriedTransactionsProvider._internal(
        () => create()..id = id,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<AsyncRequriedTransactions, List<Trx>>
      createElement() {
    return _AsyncRequriedTransactionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AsyncRequriedTransactionsProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AsyncRequriedTransactionsRef
    on AutoDisposeAsyncNotifierProviderRef<List<Trx>> {
  /// The parameter `id` of this provider.
  dynamic get id;
}

class _AsyncRequriedTransactionsProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<AsyncRequriedTransactions,
        List<Trx>> with AsyncRequriedTransactionsRef {
  _AsyncRequriedTransactionsProviderElement(super.provider);

  @override
  dynamic get id => (origin as AsyncRequriedTransactionsProvider).id;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
