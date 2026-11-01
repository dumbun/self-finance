import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/core/fonts/body_small_text.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/localization/localization_extension.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/models/user_history_model.dart';
import 'package:self_finance/providers/history_provider.dart';
import 'package:self_finance/widgets/currency_widget.dart';

class BuildHistoryListWidget extends ConsumerWidget {
  const BuildHistoryListWidget({super.key});

  static final _dateFmt = DateFormat.yMMMd();
  static final _timeFmt = DateFormat.jm();

  Widget _buildDate(DateTime dt) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        BodySmallText(
          bold: true,
          text: _dateFmt.format(dt),
          color: AppColors.getLigthGreyColor,
        ),
        BodySmallText(
          text: _timeFmt.format(dt),
          color: AppColors.getLigthGreyColor,
        ),
      ],
    );
  }

  Widget _buildIcon({required String type}) {
    final bool isDebit = type == Constant.debited;
    final Color color =
        isDebit ? AppColors.getErrorColor : AppColors.getGreenColor;
    final IconData icon =
        isDebit ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          icon,
          color: color,
          size: 22,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(historyProvider).when(
      data: (List<UserHistory> data) {
        if (data.isNotEmpty) {
          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: data.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              thickness: 0.5,
              indent: 68,
            ),
            itemBuilder: (BuildContext context, int index) {
              final UserHistory curr = data[index];
              final bool isDebit = curr.eventType == Constant.debited;
              final Color amountColor =
                  isDebit ? AppColors.getErrorColor : AppColors.getGreenColor;
              final String prefix = isDebit ? '-' : '+';

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                onTap: () => Routes.navigateToHistoryDetailedView(
                  context: context,
                  history: curr,
                ),
                leading: _buildIcon(type: curr.eventType),
                title: CurrencyWidget(
                  color: amountColor,
                  amount: '$prefix ${Utility.doubleFormate(curr.amount)}',
                ),
                subtitle: BodySmallText(
                  text: curr.customerName,
                  color: AppColors.getLigthGreyColor,
                  bold: true,
                ),
                trailing: _buildDate(curr.eventDate),
              );
            },
          );
        } else {
          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) =>
                SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.history_toggle_off_rounded,
                        size: 48,
                        color: AppColors.getLigthGreyColor,
                      ),
                      const SizedBox(height: 12),
                      BodyOneDefaultText(
                        bold: true,
                        text: context.l10n.noHistoryToView,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      },
      error: (Object error, StackTrace stackTrace) => LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) =>
            SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: BodySmallText(
                  text: "Error loading history: $error",
                  color: AppColors.getErrorColor,
                ),
              ),
            ),
          ),
        ),
      ),
      loading: () =>
          const Center(child: CircularProgressIndicator.adaptive()),
    );
  }
}
