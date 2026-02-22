import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/providers/settings_provider.dart';

class NotificationSwitchWidget extends ConsumerWidget {
  const NotificationSwitchWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ref
          .watch(notificationsProvider)
          .when(
            data: (bool data) => SwitchListTile.adaptive(
              key: UniqueKey(),
              title: const BodyOneDefaultText(
                text: "Notifications",
                bold: true,
              ),
              value: data,
              onChanged: (bool value) =>
                  ref.read(notificationsProvider.notifier).toggle(),
            ),
            error: (error, stackTrace) =>
                const BodyTwoDefaultText(text: Constant.errorUserFetch),
            loading: () =>
                const Center(child: CircularProgressIndicator.adaptive()),
          ),
    );
  }
}
