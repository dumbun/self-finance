// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transactions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$asyncTransactionsHash() => r'4a7b1422f3b391b36fe6ce43a7e93251b3c950f2';

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
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
