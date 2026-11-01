import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/providers/settings_provider.dart';

import 'package:self_finance/core/localization/localization_extension.dart';

class NotificationSwitchWidget extends ConsumerWidget {
  const NotificationSwitchWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ref
          .watch(notificationsProvider)
          .when(
            data: (bool data) => SwitchListTile.adaptive(
              title: BodyOneDefaultText(
                text: context.l10n.notifications,
                bold: true,
              ),
              value: data,
              onChanged: (bool value) =>
                  ref.read(notificationsProvider.notifier).toggle(),
            ),
            error: (error, stackTrace) =>
                BodyTwoDefaultText(text: context.l10n.errorUserFetch),
            loading: () =>
                const Center(child: CircularProgressIndicator.adaptive()),
          ),
    );
  }
}
