// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AsyncHistory)
final asyncHistoryProvider = AsyncHistoryProvider._();

final class AsyncHistoryProvider
    extends $AsyncNotifierProvider<AsyncHistory, List<UserHistory>> {
  AsyncHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'asyncHistoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$asyncHistoryHash();

  @$internal
  @override
  AsyncHistory create() => AsyncHistory();
}

String _$asyncHistoryHash() => r'c75aba488064a0960bf780ebfdfbe701c77f6182';

abstract class _$AsyncHistory extends $AsyncNotifier<List<UserHistory>> {
  FutureOr<List<UserHistory>> build();
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
