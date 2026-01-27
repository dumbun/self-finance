// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transactions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$transactionsByCustomerIdHash() =>
    r'5f04a74a585c53b72305e3cf80451248eea8db1b';

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

/// See also [transactionsByCustomerId].
@ProviderFor(transactionsByCustomerId)
const transactionsByCustomerIdProvider = TransactionsByCustomerIdFamily();

/// See also [transactionsByCustomerId].
class TransactionsByCustomerIdFamily extends Family<AsyncValue<List<Trx?>>> {
  /// See also [transactionsByCustomerId].
  const TransactionsByCustomerIdFamily();

  /// See also [transactionsByCustomerId].
  TransactionsByCustomerIdProvider call(int customerId) {
    return TransactionsByCustomerIdProvider(customerId);
  }

  @override
  TransactionsByCustomerIdProvider getProviderOverride(
    covariant TransactionsByCustomerIdProvider provider,
  ) {
    return call(provider.customerId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'transactionsByCustomerIdProvider';
}

/// See also [transactionsByCustomerId].
class TransactionsByCustomerIdProvider
    extends AutoDisposeFutureProvider<List<Trx?>> {
  /// See also [transactionsByCustomerId].
  TransactionsByCustomerIdProvider(int customerId)
    : this._internal(
        (ref) => transactionsByCustomerId(
          ref as TransactionsByCustomerIdRef,
          customerId,
        ),
        from: transactionsByCustomerIdProvider,
        name: r'transactionsByCustomerIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$transactionsByCustomerIdHash,
        dependencies: TransactionsByCustomerIdFamily._dependencies,
        allTransitiveDependencies:
            TransactionsByCustomerIdFamily._allTransitiveDependencies,
        customerId: customerId,
      );

  TransactionsByCustomerIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.customerId,
  }) : super.internal();

  final int customerId;

  @override
  Override overrideWith(
    FutureOr<List<Trx?>> Function(TransactionsByCustomerIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TransactionsByCustomerIdProvider._internal(
        (ref) => create(ref as TransactionsByCustomerIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        customerId: customerId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Trx?>> createElement() {
    return _TransactionsByCustomerIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TransactionsByCustomerIdProvider &&
        other.customerId == customerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, customerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TransactionsByCustomerIdRef on AutoDisposeFutureProviderRef<List<Trx?>> {
  /// The parameter `customerId` of this provider.
  int get customerId;
}

class _TransactionsByCustomerIdProviderElement
    extends AutoDisposeFutureProviderElement<List<Trx?>>
    with TransactionsByCustomerIdRef {
  _TransactionsByCustomerIdProviderElement(super.provider);

  @override
  int get customerId => (origin as TransactionsByCustomerIdProvider).customerId;
}

String _$fetchRequriedTransactionHash() =>
    r'85691b785714f8c10db4ec2a7bfcbd2aba916239';

/// See also [fetchRequriedTransaction].
@ProviderFor(fetchRequriedTransaction)
const fetchRequriedTransactionProvider = FetchRequriedTransactionFamily();

/// See also [fetchRequriedTransaction].
class FetchRequriedTransactionFamily extends Family<AsyncValue<List<Trx>>> {
  /// See also [fetchRequriedTransaction].
  const FetchRequriedTransactionFamily();

  /// See also [fetchRequriedTransaction].
  FetchRequriedTransactionProvider call(int transactionId) {
    return FetchRequriedTransactionProvider(transactionId);
  }

  @override
  FetchRequriedTransactionProvider getProviderOverride(
    covariant FetchRequriedTransactionProvider provider,
  ) {
    return call(provider.transactionId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'fetchRequriedTransactionProvider';
}

/// See also [fetchRequriedTransaction].
class FetchRequriedTransactionProvider
    extends AutoDisposeFutureProvider<List<Trx>> {
  /// See also [fetchRequriedTransaction].
  FetchRequriedTransactionProvider(int transactionId)
    : this._internal(
        (ref) => fetchRequriedTransaction(
          ref as FetchRequriedTransactionRef,
          transactionId,
        ),
        from: fetchRequriedTransactionProvider,
        name: r'fetchRequriedTransactionProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$fetchRequriedTransactionHash,
        dependencies: FetchRequriedTransactionFamily._dependencies,
        allTransitiveDependencies:
            FetchRequriedTransactionFamily._allTransitiveDependencies,
        transactionId: transactionId,
      );

  FetchRequriedTransactionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.transactionId,
  }) : super.internal();

  final int transactionId;

  @override
  Override overrideWith(
    FutureOr<List<Trx>> Function(FetchRequriedTransactionRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FetchRequriedTransactionProvider._internal(
        (ref) => create(ref as FetchRequriedTransactionRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        transactionId: transactionId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Trx>> createElement() {
    return _FetchRequriedTransactionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FetchRequriedTransactionProvider &&
        other.transactionId == transactionId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, transactionId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FetchRequriedTransactionRef on AutoDisposeFutureProviderRef<List<Trx>> {
  /// The parameter `transactionId` of this provider.
  int get transactionId;
}

class _FetchRequriedTransactionProviderElement
    extends AutoDisposeFutureProviderElement<List<Trx>>
    with FetchRequriedTransactionRef {
  _FetchRequriedTransactionProviderElement(super.provider);

  @override
  int get transactionId =>
      (origin as FetchRequriedTransactionProvider).transactionId;
}

String _$asyncTransactionsHash() => r'857b5dc1b00e997884dfbaa67b93f5e4c3689619';

/// See also [AsyncTransactions].
@ProviderFor(AsyncTransactions)
final asyncTransactionsProvider =
    AutoDisposeAsyncNotifierProvider<AsyncTransactions, List<Trx>>.internal(
      AsyncTransactions.new,
      name: r'asyncTransactionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$asyncTransactionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AsyncTransactions = AutoDisposeAsyncNotifier<List<Trx>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
