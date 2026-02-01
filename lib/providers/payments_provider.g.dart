// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payments_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$asyncPaymentHash() => r'5068957ac139aa88aefc3f66271c0b5b2dc65f9b';

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

abstract class _$AsyncPayment
    extends BuildlessAutoDisposeAsyncNotifier<List<Payment>> {
  late final dynamic transactionId;

  FutureOr<List<Payment>> build(dynamic transactionId);
}

/// See also [AsyncPayment].
@ProviderFor(AsyncPayment)
const asyncPaymentProvider = AsyncPaymentFamily();

/// See also [AsyncPayment].
class AsyncPaymentFamily extends Family<AsyncValue<List<Payment>>> {
  /// See also [AsyncPayment].
  const AsyncPaymentFamily();

  /// See also [AsyncPayment].
  AsyncPaymentProvider call(dynamic transactionId) {
    return AsyncPaymentProvider(transactionId);
  }

  @override
  AsyncPaymentProvider getProviderOverride(
    covariant AsyncPaymentProvider provider,
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
  String? get name => r'asyncPaymentProvider';
}

/// See also [AsyncPayment].
class AsyncPaymentProvider
    extends AutoDisposeAsyncNotifierProviderImpl<AsyncPayment, List<Payment>> {
  /// See also [AsyncPayment].
  AsyncPaymentProvider(dynamic transactionId)
    : this._internal(
        () => AsyncPayment()..transactionId = transactionId,
        from: asyncPaymentProvider,
        name: r'asyncPaymentProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$asyncPaymentHash,
        dependencies: AsyncPaymentFamily._dependencies,
        allTransitiveDependencies:
            AsyncPaymentFamily._allTransitiveDependencies,
        transactionId: transactionId,
      );

  AsyncPaymentProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.transactionId,
  }) : super.internal();

  final dynamic transactionId;

  @override
  FutureOr<List<Payment>> runNotifierBuild(covariant AsyncPayment notifier) {
    return notifier.build(transactionId);
  }

  @override
  Override overrideWith(AsyncPayment Function() create) {
    return ProviderOverride(
      origin: this,
      override: AsyncPaymentProvider._internal(
        () => create()..transactionId = transactionId,
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
  AutoDisposeAsyncNotifierProviderElement<AsyncPayment, List<Payment>>
  createElement() {
    return _AsyncPaymentProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AsyncPaymentProvider &&
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
mixin AsyncPaymentRef on AutoDisposeAsyncNotifierProviderRef<List<Payment>> {
  /// The parameter `transactionId` of this provider.
  dynamic get transactionId;
}

class _AsyncPaymentProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<AsyncPayment, List<Payment>>
    with AsyncPaymentRef {
  _AsyncPaymentProviderElement(super.provider);

  @override
  dynamic get transactionId => (origin as AsyncPaymentProvider).transactionId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
