import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/models/contacts_model.dart';

part 'contacts_provider.g.dart';

@riverpod
class ContactsSearchQuery extends _$ContactsSearchQuery {
  @override
  String build() => '';

  void set(String q) => state = q;

  void clear() => state = '';
}

@riverpod
class ContactsNotifier extends _$ContactsNotifier {
  Stream<List<Contact>> _fetchAllContacts() {
    return BackEnd.watchAllCustomerNumbersWithNames();
  }

  @override
  Stream<List<Contact>> build() {
    final String query = ref
        .watch(contactsSearchQueryProvider)
        .trim()
        .toLowerCase();
    final Stream<List<Contact>> base = _fetchAllContacts();

    if (query.isEmpty) return base;

    return base.map((List<Contact> contacts) {
      return contacts.where((Contact c) {
        final String name = c.name.toLowerCase();
        final String number = c.number.toLowerCase();
        final String id = c.id.toString();
        return name.contains(query) ||
            number.contains(query) ||
            id.contains(query);
      }).toList();
    });
  }

  void doSearch(String input) {
    ref.read(contactsSearchQueryProvider.notifier).set(input);
  }

  void clearSearch() {
    ref.read(contactsSearchQueryProvider.notifier).clear();
  }

  Future<List<String>> fetchContactsNumber() async {
    return await BackEnd.fetchAllCustomerNumbers();
  }
}
