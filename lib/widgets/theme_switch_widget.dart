import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/providers/settings_provider.dart';

class ThemeSwitchWidget extends ConsumerWidget {
  const ThemeSwitchWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      key: UniqueKey(),
      child: ref
          .watch(themeProvider)
          .when(
            data: (bool data) {
              return SwitchListTile.adaptive(
                value: data,
                onChanged: (value) async =>
                    await ref.read(themeProvider.notifier).toggle(),
                title: const BodyOneDefaultText(text: "Dark mode", bold: true),
              );
            },
            error: (error, stackTrace) =>
                const BodyTwoDefaultText(text: Constant.errorUserFetch),
            loading: () =>
                const Center(child: CircularProgressIndicator.adaptive()),
          ),
    );
  }
}
