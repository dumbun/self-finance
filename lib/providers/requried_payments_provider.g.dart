// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'requried_payments_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$asyncRequriedPaymentHash() =>
    r'ae4388886a189c2341d6e9bce769696cfda5ec06';

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

abstract class _$AsyncRequriedPayment
    extends BuildlessAutoDisposeAsyncNotifier<List<Payment>> {
  late final dynamic transactionId;

  FutureOr<List<Payment>> build(
    dynamic transactionId,
  );
}

/// See also [AsyncRequriedPayment].
@ProviderFor(AsyncRequriedPayment)
const asyncRequriedPaymentProvider = AsyncRequriedPaymentFamily();

/// See also [AsyncRequriedPayment].
class AsyncRequriedPaymentFamily extends Family<AsyncValue<List<Payment>>> {
  /// See also [AsyncRequriedPayment].
  const AsyncRequriedPaymentFamily();

  /// See also [AsyncRequriedPayment].
  AsyncRequriedPaymentProvider call(
    dynamic transactionId,
  ) {
    return AsyncRequriedPaymentProvider(
      transactionId,
    );
  }

  @override
  AsyncRequriedPaymentProvider getProviderOverride(
    covariant AsyncRequriedPaymentProvider provider,
  ) {
    return call(
      provider.transactionId,
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
  String? get name => r'asyncRequriedPaymentProvider';
}

/// See also [AsyncRequriedPayment].
class AsyncRequriedPaymentProvider extends AutoDisposeAsyncNotifierProviderImpl<
    AsyncRequriedPayment, List<Payment>> {
  /// See also [AsyncRequriedPayment].
  AsyncRequriedPaymentProvider(
    dynamic transactionId,
  ) : this._internal(
          () => AsyncRequriedPayment()..transactionId = transactionId,
          from: asyncRequriedPaymentProvider,
          name: r'asyncRequriedPaymentProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$asyncRequriedPaymentHash,
          dependencies: AsyncRequriedPaymentFamily._dependencies,
          allTransitiveDependencies:
              AsyncRequriedPaymentFamily._allTransitiveDependencies,
          transactionId: transactionId,
        );

  AsyncRequriedPaymentProvider._internal(
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
  FutureOr<List<Payment>> runNotifierBuild(
    covariant AsyncRequriedPayment notifier,
  ) {
    return notifier.build(
      transactionId,
    );
  }

  @override
  Override overrideWith(AsyncRequriedPayment Function() create) {
    return ProviderOverride(
      origin: this,
      override: AsyncRequriedPaymentProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<AsyncRequriedPayment, List<Payment>>
      createElement() {
    return _AsyncRequriedPaymentProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AsyncRequriedPaymentProvider &&
        other.transactionId == transactionId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, transactionId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin AsyncRequriedPaymentRef
    on AutoDisposeAsyncNotifierProviderRef<List<Payment>> {
  /// The parameter `transactionId` of this provider.
  dynamic get transactionId;
}

class _AsyncRequriedPaymentProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<AsyncRequriedPayment,
        List<Payment>> with AsyncRequriedPaymentRef {
  _AsyncRequriedPaymentProviderElement(super.provider);

  @override
  dynamic get transactionId =>
      (origin as AsyncRequriedPaymentProvider).transactionId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
