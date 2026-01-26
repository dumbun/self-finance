import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/models/user_model.dart';
import 'package:self_finance/providers/user_provider.dart';
import 'package:self_finance/widgets/title_widget.dart';

class CurrencyWidget extends ConsumerWidget {
  const CurrencyWidget({
    super.key,
    this.color,
    required this.amount,
    this.titleText = false,
  });
  final Color? color;
  final String amount;
  final bool titleText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(asyncUserProvider)
        .when(
          data: (List<User> data) {
            return titleText
                ? TitleWidget(
                    text: "$amount ${data.first.userCurrency}",
                    color: color,
                  )
                : BodyOneDefaultText(
                    text: "$amount ${data.first.userCurrency}",
                    bold: true,
                    color: color,
                  );
          },
          error: (error, stackTrace) => BodyOneDefaultText(text: ""),
          loading: () => CircularProgressIndicator.adaptive(),
        );
  }
}
