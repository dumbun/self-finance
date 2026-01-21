import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:self_finance/providers/app_currency_provider.dart';

class CurrencyWidget extends ConsumerWidget {
  const CurrencyWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String currencyType = ref.watch(currencyProvider);
    return BodyTwoDefaultText(text: currencyType);
  }
}
