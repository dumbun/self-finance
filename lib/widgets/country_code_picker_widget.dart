import 'package:material_ui/material_ui.dart';
import 'package:self_finance/core/fonts/body_small_text.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/models/country_model.dart';

class CountryCodePickerWidget extends StatelessWidget {
  const CountryCodePickerWidget({
    super.key,
    required this.selectedCountry,
    required this.onChanged,
    this.enabled = true,
  });

  final Country selectedCountry;
  final ValueChanged<Country> onChanged;
  final bool enabled;

  void _showCountryPicker(BuildContext context) {
    if (!enabled) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CountryPickerSheet(
        selectedCountry: selectedCountry,
        onSelected: (country) {
          onChanged(country);
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = AppColors.getLigthGreyColor.withValues(alpha: 0.35);

    return InkWell(
      onTap: enabled ? () => _showCountryPicker(context) : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedCountry.flag,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 6),
            BodyTwoDefaultText(
              text: selectedCountry.dialCode,
              bold: true,
            ),
            const SizedBox(width: 2),
            const Icon(
              Icons.arrow_drop_down,
              size: 20,
              color: AppColors.getLigthGreyColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _CountryPickerSheet extends StatefulWidget {
  const _CountryPickerSheet({
    required this.selectedCountry,
    required this.onSelected,
  });

  final Country selectedCountry;
  final ValueChanged<Country> onSelected;

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<Country> _filteredCountries = Country.allCountries;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCountries = Country.allCountries;
      } else {
        _filteredCountries = Country.allCountries.where((c) {
          return c.name.toLowerCase().contains(query) ||
              c.dialCode.toLowerCase().contains(query) ||
              c.code.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Material(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.75,
            child: Column(
              children: [
                // Drag handle
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.getLigthGreyColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 10),

                // Title and close button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const BodyOneDefaultText(
                        text: "Select Country",
                        bold: true,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),

                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _searchController.clear,
                            )
                          : null,
                      hintText: "Search country name or code...",
                      filled: true,
                      fillColor: theme.cardColor,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: AppColors.getLigthGreyColor.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                  ),
                ),

                // Country list
                Expanded(
                  child: _filteredCountries.isEmpty
                      ? const Center(
                          child: BodySmallText(
                            text: "No countries match your search",
                            color: AppColors.getLigthGreyColor,
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredCountries.length,
                          itemBuilder: (context, index) {
                            final country = _filteredCountries[index];
                            final isSelected =
                                country.dialCode == widget.selectedCountry.dialCode &&
                                country.code == widget.selectedCountry.code;

                            return ListTile(
                              leading: Text(
                                country.flag,
                                style: const TextStyle(fontSize: 24),
                              ),
                              title: BodyTwoDefaultText(
                                text: country.name,
                                bold: isSelected,
                              ),
                              subtitle: BodySmallText(
                                text: country.code,
                                color: AppColors.getLigthGreyColor,
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  BodyTwoDefaultText(
                                    text: country.dialCode,
                                    bold: true,
                                    color: isSelected
                                        ? AppColors.getPrimaryColor
                                        : null,
                                  ),
                                  if (isSelected) ...[
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.check_circle,
                                      color: AppColors.getPrimaryColor,
                                      size: 18,
                                    ),
                                  ],
                                ],
                              ),
                            onTap: () => widget.onSelected(country),
                          );
                        },
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
