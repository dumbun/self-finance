import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/fonts/body_text.dart';
import 'package:self_finance/providers/home_screen_graph_value_provider.dart';
import 'package:self_finance/widgets/two_slice_pie_chart_widget.dart';

class HomeScreenGraphWidget extends ConsumerWidget {
  const HomeScreenGraphWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(homeScreenGraphValuesProvider).when(
          data: (Map<String, double> data) {
            return data.isNotEmpty
                ? TwoSlicePieChartWidget(
                    firstIndicatorText: Constant.totalAmountInvested,
                    secoundIndicatorText: Constant.intrestAmount,
                    firstIndicatorValue: data[Constant.firstIndicatorPercentage] ?? 0,
                    secoundIndicatorValue: data[Constant.secoundIndicatorPercentage] ?? 0,
                  )
                : const BodyOneDefaultText(
                    text: Constant.emptyTransactionsString,
                  );
          },
          error: (error, stackTrace) => const BodyOneDefaultText(
            text: Constant.errorFetchingContactMessage,
          ),
          loading: () => const Center(
            child: CircularProgressIndicator.adaptive(),
          ),
        );
  }
}
