// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payments_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AsyncPayment)
final asyncPaymentProvider = AsyncPaymentFamily._();

final class AsyncPaymentProvider
    extends $AsyncNotifierProvider<AsyncPayment, List<Payment>> {
  AsyncPaymentProvider._({
    required AsyncPaymentFamily super.from,
    required dynamic super.argument,
  }) : super(
         retry: null,
         name: r'asyncPaymentProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$asyncPaymentHash();

  @override
  String toString() {
    return r'asyncPaymentProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AsyncPayment create() => AsyncPayment();

  @override
  bool operator ==(Object other) {
    return other is AsyncPaymentProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$asyncPaymentHash() => r'5068957ac139aa88aefc3f66271c0b5b2dc65f9b';

final class AsyncPaymentFamily extends $Family
    with
        $ClassFamilyOverride<
          AsyncPayment,
          AsyncValue<List<Payment>>,
          List<Payment>,
          FutureOr<List<Payment>>,
          dynamic
        > {
  AsyncPaymentFamily._()
    : super(
        retry: null,
        name: r'asyncPaymentProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AsyncPaymentProvider call(dynamic transactionId) =>
      AsyncPaymentProvider._(argument: transactionId, from: this);

  @override
  String toString() => r'asyncPaymentProvider';
}

abstract class _$AsyncPayment extends $AsyncNotifier<List<Payment>> {
  late final _$args = ref.$arg as dynamic;
  dynamic get transactionId => _$args;

  FutureOr<List<Payment>> build(dynamic transactionId);
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
    element.handleCreate(ref, () => build(_$args));
  }
}
