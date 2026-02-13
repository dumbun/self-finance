// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AsyncCustomers)
final asyncCustomersProvider = AsyncCustomersProvider._();

final class AsyncCustomersProvider
    extends $AsyncNotifierProvider<AsyncCustomers, List<Customer>> {
  AsyncCustomersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'asyncCustomersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$asyncCustomersHash();

  @$internal
  @override
  AsyncCustomers create() => AsyncCustomers();
}

String _$asyncCustomersHash() => r'19ef6007237051fff645c44b961ac619b0d61da4';

abstract class _$AsyncCustomers extends $AsyncNotifier<List<Customer>> {
  FutureOr<List<Customer>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Customer>>, List<Customer>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Customer>>, List<Customer>>,
              AsyncValue<List<Customer>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(customerById)
final customerByIdProvider = CustomerByIdFamily._();

final class CustomerByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<Customer?>,
          Customer?,
          FutureOr<Customer?>
        >
    with $FutureModifier<Customer?>, $FutureProvider<Customer?> {
  CustomerByIdProvider._({
    required CustomerByIdFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'customerByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$customerByIdHash();

  @override
  String toString() {
    return r'customerByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Customer?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Customer?> create(Ref ref) {
    final argument = this.argument as int;
    return customerById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CustomerByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$customerByIdHash() => r'21844cb531e720c5efb3279687ef3975c62c7ea0';

final class CustomerByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Customer?>, int> {
  CustomerByIdFamily._()
    : super(
        retry: null,
        name: r'customerByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CustomerByIdProvider call(int customerId) =>
      CustomerByIdProvider._(argument: customerId, from: this);

  @override
  String toString() => r'customerByIdProvider';
}
