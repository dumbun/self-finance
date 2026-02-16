// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CustomerNotifier)
final customerProvider = CustomerNotifierFamily._();

final class CustomerNotifierProvider
    extends $StreamNotifierProvider<CustomerNotifier, Customer?> {
  CustomerNotifierProvider._({
    required CustomerNotifierFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'customerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$customerNotifierHash();

  @override
  String toString() {
    return r'customerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CustomerNotifier create() => CustomerNotifier();

  @override
  bool operator ==(Object other) {
    return other is CustomerNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$customerNotifierHash() => r'a4f6cc7d07a5bbbfda9e6a8b07b09584842e558f';

final class CustomerNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          CustomerNotifier,
          AsyncValue<Customer?>,
          Customer?,
          Stream<Customer?>,
          int
        > {
  CustomerNotifierFamily._()
    : super(
        retry: null,
        name: r'customerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CustomerNotifierProvider call(int id) =>
      CustomerNotifierProvider._(argument: id, from: this);

  @override
  String toString() => r'customerProvider';
}

abstract class _$CustomerNotifier extends $StreamNotifier<Customer?> {
  late final _$args = ref.$arg as int;
  int get id => _$args;

  Stream<Customer?> build(int id);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Customer?>, Customer?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Customer?>, Customer?>,
              AsyncValue<Customer?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
