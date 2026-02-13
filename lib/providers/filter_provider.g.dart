// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filter_provider.dart';

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

String _$filterHash() => r'97bd1b4d12a1e8429ae9ecbef3396850135e1f14';

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
