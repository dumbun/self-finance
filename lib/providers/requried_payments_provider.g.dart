// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'requried_payments_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(requriedPayments)
final requriedPaymentsProvider = RequriedPaymentsFamily._();

final class RequriedPaymentsProvider
    extends $FunctionalProvider<List<Payment>, List<Payment>, List<Payment>>
    with $Provider<List<Payment>> {
  RequriedPaymentsProvider._({
    required RequriedPaymentsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'requriedPaymentsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$requriedPaymentsHash();

  @override
  String toString() {
    return r'requriedPaymentsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<Payment>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Payment> create(Ref ref) {
    final argument = this.argument as int;
    return requriedPayments(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Payment> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Payment>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RequriedPaymentsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$requriedPaymentsHash() => r'78e678813dcb88711d4caffb6bdd6fcee6fd64ab';

final class RequriedPaymentsFamily extends $Family
    with $FunctionalFamilyOverride<List<Payment>, int> {
  RequriedPaymentsFamily._()
    : super(
        retry: null,
        name: r'requriedPaymentsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RequriedPaymentsProvider call(int transactionId) =>
      RequriedPaymentsProvider._(argument: transactionId, from: this);

  @override
  String toString() => r'requriedPaymentsProvider';
}
