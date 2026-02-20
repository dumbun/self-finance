// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PaymentByTrxId)
final paymentByTrxIdProvider = PaymentByTrxIdFamily._();

final class PaymentByTrxIdProvider
    extends $StreamNotifierProvider<PaymentByTrxId, List<Payment>> {
  PaymentByTrxIdProvider._({
    required PaymentByTrxIdFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'paymentByTrxIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$paymentByTrxIdHash();

  @override
  String toString() {
    return r'paymentByTrxIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PaymentByTrxId create() => PaymentByTrxId();

  @override
  bool operator ==(Object other) {
    return other is PaymentByTrxIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$paymentByTrxIdHash() => r'1574346b6438bffde1bd65f67904af64649805ad';

final class PaymentByTrxIdFamily extends $Family
    with
        $ClassFamilyOverride<
          PaymentByTrxId,
          AsyncValue<List<Payment>>,
          List<Payment>,
          Stream<List<Payment>>,
          int
        > {
  PaymentByTrxIdFamily._()
    : super(
        retry: null,
        name: r'paymentByTrxIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PaymentByTrxIdProvider call({required int transactionId}) =>
      PaymentByTrxIdProvider._(argument: transactionId, from: this);

  @override
  String toString() => r'paymentByTrxIdProvider';
}

abstract class _$PaymentByTrxId extends $StreamNotifier<List<Payment>> {
  late final _$args = ref.$arg as int;
  int get transactionId => _$args;

  Stream<List<Payment>> build({required int transactionId});
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Payment>>, List<Payment>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Payment>>, List<Payment>>,
              AsyncValue<List<Payment>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(transactionId: _$args));
  }
}
