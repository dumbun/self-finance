// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HistorySearchQuery)
final historySearchQueryProvider = HistorySearchQueryProvider._();

final class HistorySearchQueryProvider
    extends $NotifierProvider<HistorySearchQuery, String> {
  HistorySearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'historySearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$historySearchQueryHash();

  @$internal
  @override
  HistorySearchQuery create() => HistorySearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$historySearchQueryHash() =>
    r'7a51deec573ed89d1cb2d3655a6168b1122d532a';

abstract class _$HistorySearchQuery extends $Notifier<String> {
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

@ProviderFor(HistoryNotifier)
final historyProvider = HistoryNotifierProvider._();

final class HistoryNotifierProvider
    extends $StreamNotifierProvider<HistoryNotifier, List<UserHistory>> {
  HistoryNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'historyProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$historyNotifierHash();

  @$internal
  @override
  HistoryNotifier create() => HistoryNotifier();
}

String _$historyNotifierHash() => r'6d5da4700581f5aa2d3949ec04abee25b47fd89b';

abstract class _$HistoryNotifier extends $StreamNotifier<List<UserHistory>> {
  Stream<List<UserHistory>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<UserHistory>>, List<UserHistory>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<UserHistory>>, List<UserHistory>>,
              AsyncValue<List<UserHistory>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
