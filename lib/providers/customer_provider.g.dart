// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$asyncCustomersHash() => r'b18088e39dcd937e1790b756453f3a4fb1683d19';

/// See also [AsyncCustomers].
@ProviderFor(AsyncCustomers)
final asyncCustomersProvider =
    AutoDisposeAsyncNotifierProvider<AsyncCustomers, List<Customer>>.internal(
  AsyncCustomers.new,
  name: r'asyncCustomersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$asyncCustomersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AsyncCustomers = AutoDisposeAsyncNotifier<List<Customer>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member