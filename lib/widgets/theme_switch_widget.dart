import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/providers/settings_provider.dart';
import 'package:self_finance/core/localization/localization_extension.dart';

class ThemeSwitchWidget extends ConsumerWidget {
  const ThemeSwitchWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ref
          .watch(themeProvider)
          .when(
            data: (bool data) {
              return SwitchListTile.adaptive(
                value: data,
                onChanged: (value) async =>
                    await ref.read(themeProvider.notifier).toggle(),
                title: BodyOneDefaultText(
                  text: context.l10n.darkMode,
                  bold: true,
                ),
              );
            },
            error: (error, stackTrace) =>
                BodyTwoDefaultText(text: context.l10n.errorUserFetch),
            loading: () =>
                const Center(child: CircularProgressIndicator.adaptive()),
          ),
    );
  }
}
