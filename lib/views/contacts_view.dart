import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/providers/contacts_provider.dart';
import 'package:self_finance/widgets/build_customers_list.dart';

class ContactsView extends ConsumerStatefulWidget {
  const ContactsView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ContactsViewState();
}

class _ContactsViewState extends ConsumerState<ContactsView> {
  final SearchController _searchController = SearchController();
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: const BodyTwoDefaultText(text: Constant.contact, bold: true),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.read(contactsSearchQueryProvider.notifier).clear();
            ref.refresh(contactsProvider.future).ignore();
            _searchController.clear();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SearchBar(
                  controller: _searchController,
                  onChanged: (String value) =>
                      ref.read(contactsProvider.notifier).doSearch(value),
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  hintStyle: const WidgetStatePropertyAll(
                    TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(20),
                    ),
                  ),
                  leading: const Icon(Icons.search),
                  elevation: const WidgetStatePropertyAll(0),
                  hintText: "phone no. or name",
                ),
                const SizedBox(height: 12),
                const Expanded(child: BuildCustomersListWidget()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
