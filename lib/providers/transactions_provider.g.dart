// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transactions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Filter)
final filterProvider = FilterProvider._();

final class FilterProvider
    extends $NotifierProvider<Filter, Set<TransactionsFilters>> {
  FilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filterHash();

  @$internal
  @override
  Filter create() => Filter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<TransactionsFilters> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<TransactionsFilters>>(value),
    );
  }
}

String _$filterHash() => r'd72d92ed1bd70181203ace7fc0914fc2d180cd43';

abstract class _$Filter extends $Notifier<Set<TransactionsFilters>> {
  Set<TransactionsFilters> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<Set<TransactionsFilters>, Set<TransactionsFilters>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<TransactionsFilters>, Set<TransactionsFilters>>,
              Set<TransactionsFilters>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(TransactionsSearchQuery)
final transactionsSearchQueryProvider = TransactionsSearchQueryProvider._();

final class TransactionsSearchQueryProvider
    extends $NotifierProvider<TransactionsSearchQuery, String> {
  TransactionsSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionsSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionsSearchQueryHash();

  @$internal
  @override
  TransactionsSearchQuery create() => TransactionsSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$transactionsSearchQueryHash() =>
    r'69f71f607142c9e4088097a558232ed7ec464148';

abstract class _$TransactionsSearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(TransactionsDateSearchQuery)
final transactionsDateSearchQueryProvider =
    TransactionsDateSearchQueryProvider._();

final class TransactionsDateSearchQueryProvider
    extends $NotifierProvider<TransactionsDateSearchQuery, DateTime?> {
  TransactionsDateSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionsDateSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionsDateSearchQueryHash();

  @$internal
  @override
  TransactionsDateSearchQuery create() => TransactionsDateSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime?>(value),
    );
  }
}

String _$transactionsDateSearchQueryHash() =>
    r'cf2be1aabaa4bd194973aaedb50efcb4555c7fa8';

abstract class _$TransactionsDateSearchQuery extends $Notifier<DateTime?> {
  DateTime? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DateTime?, DateTime?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DateTime?, DateTime?>,
              DateTime?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(TransactionsNotifier)
final transactionsProvider = TransactionsNotifierProvider._();

final class TransactionsNotifierProvider
    extends $StreamNotifierProvider<TransactionsNotifier, List<Trx>> {
  TransactionsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionsNotifierHash();

  @$internal
  @override
  TransactionsNotifier create() => TransactionsNotifier();
}

String _$transactionsNotifierHash() =>
    r'146db9da8f2dcc1cea413c5a99e70f76d16e51da';

abstract class _$TransactionsNotifier extends $StreamNotifier<List<Trx>> {
  Stream<List<Trx>> build();
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

@ProviderFor(TransactionByID)
final transactionByIDProvider = TransactionByIDFamily._();

final class TransactionByIDProvider
    extends $StreamNotifierProvider<TransactionByID, Trx?> {
  TransactionByIDProvider._({
    required TransactionByIDFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'transactionByIDProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$transactionByIDHash();

  @override
  String toString() {
    return r'transactionByIDProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TransactionByID create() => TransactionByID();

  @override
  bool operator ==(Object other) {
    return other is TransactionByIDProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$transactionByIDHash() => r'e0f99aaf971b079223c6661f940d80df7b2e1e73';

final class TransactionByIDFamily extends $Family
    with
        $ClassFamilyOverride<
          TransactionByID,
          AsyncValue<Trx?>,
          Trx?,
          Stream<Trx?>,
          int
        > {
  TransactionByIDFamily._()
    : super(
        retry: null,
        name: r'transactionByIDProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TransactionByIDProvider call(int transactionId) =>
      TransactionByIDProvider._(argument: transactionId, from: this);

  @override
  String toString() => r'transactionByIDProvider';
}

abstract class _$TransactionByID extends $StreamNotifier<Trx?> {
  late final _$args = ref.$arg as int;
  int get transactionId => _$args;

  Stream<Trx?> build(int transactionId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Trx?>, Trx?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Trx?>, Trx?>,
              AsyncValue<Trx?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
