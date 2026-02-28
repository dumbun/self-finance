import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
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
    final String? currency = ref.watch(
      userProvider.select((a) => a.asData?.value?.userCurrency),
    );

    final text = currency == null ? amount : '$amount $currency';

    if (titleText) {
      return TitleWidget(
        text: text,
        color: color,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      );
    }

    if (smallText) {
      return BodyTwoDefaultText(
        text: text,
        bold: true,
        color: color,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      );
    }

    return BodyOneDefaultText(
      text: text,
      bold: true,
      color: color,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }
}
