// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'items_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AsyncItems)
final asyncItemsProvider = AsyncItemsProvider._();

final class AsyncItemsProvider
    extends $AsyncNotifierProvider<AsyncItems, List<Items>> {
  AsyncItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'asyncItemsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$asyncItemsHash();

  @$internal
  @override
  AsyncItems create() => AsyncItems();
}

String _$asyncItemsHash() => r'7157c023bf103d729e46388516f99f88528869cc';

abstract class _$AsyncItems extends $AsyncNotifier<List<Items>> {
  FutureOr<List<Items>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Items>>, List<Items>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Items>>, List<Items>>,
              AsyncValue<List<Items>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
