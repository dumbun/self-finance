// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_contacts_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AsyncCustomersContacts)
final asyncCustomersContactsProvider = AsyncCustomersContactsProvider._();

final class AsyncCustomersContactsProvider
    extends $AsyncNotifierProvider<AsyncCustomersContacts, List<Contact>> {
  AsyncCustomersContactsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'asyncCustomersContactsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$asyncCustomersContactsHash();

  @$internal
  @override
  AsyncCustomersContacts create() => AsyncCustomersContacts();
}

String _$asyncCustomersContactsHash() =>
    r'92a66e0eba6ff2d409dbe8e2f9545cc95c7d4256';

abstract class _$AsyncCustomersContacts extends $AsyncNotifier<List<Contact>> {
  FutureOr<List<Contact>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Contact>>, List<Contact>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Contact>>, List<Contact>>,
              AsyncValue<List<Contact>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
