// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contacts_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ContactsSearchQuery)
final contactsSearchQueryProvider = ContactsSearchQueryProvider._();

final class ContactsSearchQueryProvider
    extends $NotifierProvider<ContactsSearchQuery, String> {
  ContactsSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contactsSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contactsSearchQueryHash();

  @$internal
  @override
  ContactsSearchQuery create() => ContactsSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$contactsSearchQueryHash() =>
    r'43d45d796df98178c78836f75e0d059480c15d7f';

abstract class _$ContactsSearchQuery extends $Notifier<String> {
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

@ProviderFor(ContactsNotifier)
final contactsProvider = ContactsNotifierProvider._();

final class ContactsNotifierProvider
    extends $StreamNotifierProvider<ContactsNotifier, List<Contact>> {
  ContactsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contactsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contactsNotifierHash();

  @$internal
  @override
  ContactsNotifier create() => ContactsNotifier();
}

String _$contactsNotifierHash() => r'6b51e8b88c83aa9d5f860eaef43ca43f3eb6778f';

abstract class _$ContactsNotifier extends $StreamNotifier<List<Contact>> {
  Stream<List<Contact>> build();
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
