import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/models/user_model.dart';
import 'package:self_finance/providers/user_provider.dart';
import 'package:self_finance/core/fonts/title_widget.dart';

class CurrencyWidget extends ConsumerWidget {
  const CurrencyWidget({
    super.key,
    this.color,
    required this.amount,
    this.titleText = false,
    this.smallText = false,
  });
  final Color? color;
  final String amount;
  final bool titleText;
  final bool smallText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(userProvider)
        .when(
          data: (User? user) {
            if (user == null) {
              return titleText
                  ? TitleWidget(text: amount, color: color)
                  : smallText
                  ? BodyTwoDefaultText(text: amount, bold: true, color: color)
                  : BodyOneDefaultText(text: amount, bold: true, color: color);
            }
            return titleText
                ? TitleWidget(
                    text: "$amount ${user.userCurrency}",
                    color: color,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  )
                : smallText
                ? BodyTwoDefaultText(
                    text: "$amount ${user.userCurrency}",
                    bold: true,
                    color: color,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  )
                : BodyOneDefaultText(
                    text: "$amount ${user.userCurrency}",
                    bold: true,
                    color: color,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  );
          },
          error: (Object error, StackTrace stackTrace) =>
              const BodyOneDefaultText(text: ""),
          loading: () => const CircularProgressIndicator.adaptive(),
        );
  }
}
