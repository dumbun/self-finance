import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/localization/localization_extension.dart';
import 'package:self_finance/providers/contacts_provider.dart';
import 'package:self_finance/widgets/build_customers_list.dart';

class ContactsView extends HookConsumerWidget {
  const ContactsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SearchController searchController = useMemoized(SearchController.new);

    useEffect(() {
      return searchController.dispose;
    }, [searchController]);

    Future<void> refreshData() async {
      searchController.clear();

      ref.read(contactsSearchQueryProvider.notifier).clear();
      ref.invalidate(contactsProvider);
    }

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: BodyTwoDefaultText(text: context.l10n.contacts, bold: true),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: refreshData,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: <Widget>[
                SearchBar(
                  controller: searchController,
                  onChanged: (String value) {
                    ref.read(contactsProvider.notifier).doSearch(value);
                  },
                  padding: const WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 12),
                  ),
                  hintStyle: const WidgetStatePropertyAll(
                    TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  shape: const WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                  ),
                  leading: const Icon(Icons.search),
                  elevation: const WidgetStatePropertyAll(0),
                  hintText: context.l10n.searchCustomerOrPhone,
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
