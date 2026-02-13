// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transactions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AsyncTransactions)
final asyncTransactionsProvider = AsyncTransactionsProvider._();

final class AsyncTransactionsProvider
    extends $AsyncNotifierProvider<AsyncTransactions, List<Trx>> {
  AsyncTransactionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'asyncTransactionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$asyncTransactionsHash();

  @$internal
  @override
  AsyncTransactions create() => AsyncTransactions();
}

String _$asyncTransactionsHash() => r'36269f27a904c793eb180a3fda11a8627b9390b2';

abstract class _$AsyncTransactions extends $AsyncNotifier<List<Trx>> {
  FutureOr<List<Trx>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Trx>>, List<Trx>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Trx>>, List<Trx>>,
              AsyncValue<List<Trx>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(transactionsByCustomerId)
final transactionsByCustomerIdProvider = TransactionsByCustomerIdFamily._();

final class TransactionsByCustomerIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Trx?>>,
          List<Trx?>,
          FutureOr<List<Trx?>>
        >
    with $FutureModifier<List<Trx?>>, $FutureProvider<List<Trx?>> {
  TransactionsByCustomerIdProvider._({
    required TransactionsByCustomerIdFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'transactionsByCustomerIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$transactionsByCustomerIdHash();

  @override
  String toString() {
    return r'transactionsByCustomerIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Trx?>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Trx?>> create(Ref ref) {
    final argument = this.argument as int;
    return transactionsByCustomerId(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TransactionsByCustomerIdProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$transactionsByCustomerIdHash() =>
    r'5f04a74a585c53b72305e3cf80451248eea8db1b';

final class TransactionsByCustomerIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Trx?>>, int> {
  TransactionsByCustomerIdFamily._()
    : super(
        retry: null,
        name: r'transactionsByCustomerIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TransactionsByCustomerIdProvider call(int customerId) =>
      TransactionsByCustomerIdProvider._(argument: customerId, from: this);

  @override
  String toString() => r'transactionsByCustomerIdProvider';
}

@ProviderFor(fetchRequriedTransaction)
final fetchRequriedTransactionProvider = FetchRequriedTransactionFamily._();

final class FetchRequriedTransactionProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Trx>>,
          List<Trx>,
          FutureOr<List<Trx>>
        >
    with $FutureModifier<List<Trx>>, $FutureProvider<List<Trx>> {
  FetchRequriedTransactionProvider._({
    required FetchRequriedTransactionFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'fetchRequriedTransactionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$fetchRequriedTransactionHash();

  @override
  String toString() {
    return r'fetchRequriedTransactionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Trx>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Trx>> create(Ref ref) {
    final argument = this.argument as int;
    return fetchRequriedTransaction(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FetchRequriedTransactionProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$fetchRequriedTransactionHash() =>
    r'85691b785714f8c10db4ec2a7bfcbd2aba916239';

final class FetchRequriedTransactionFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Trx>>, int> {
  FetchRequriedTransactionFamily._()
    : super(
        retry: null,
        name: r'fetchRequriedTransactionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FetchRequriedTransactionProvider call(int transactionId) =>
      FetchRequriedTransactionProvider._(argument: transactionId, from: this);

  @override
  String toString() => r'fetchRequriedTransactionProvider';
}
