// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AsyncUser)
final asyncUserProvider = AsyncUserProvider._();

final class AsyncUserProvider
    extends $AsyncNotifierProvider<AsyncUser, List<User>> {
  AsyncUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'asyncUserProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$asyncUserHash();

  @$internal
  @override
  AsyncUser create() => AsyncUser();
}

String _$asyncUserHash() => r'49cf5fc0cd84c6b76db3affc128d6527a423d25e';

abstract class _$AsyncUser extends $AsyncNotifier<List<User>> {
  FutureOr<List<User>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<User>>, List<User>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<User>>, List<User>>,
              AsyncValue<List<User>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
