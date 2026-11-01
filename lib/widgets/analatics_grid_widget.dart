import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/core/localization/localization_extension.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/fonts/body_small_text.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/providers/analytics_provider.dart';
import 'package:self_finance/widgets/currency_widget.dart';

class AnalaticsGridWidget extends ConsumerWidget {
  final EdgeInsetsGeometry padding;

  const AnalaticsGridWidget({
    super.key,
    this.padding = const EdgeInsets.all(16),
  });

  /// Adjust breakpoints to taste
  int _columnsForWidth(double width) {
    if (width >= 1100) return 4;
    if (width >= 700) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int columns = _columnsForWidth(constraints.maxWidth);

        return Padding(
          padding: padding,
          child: GridView.count(
            key: const ValueKey<String>(Constant.gridWidgetKey),
            crossAxisCount: columns,
            mainAxisSpacing: 13,
            crossAxisSpacing: 13,
            childAspectRatio: 1.15,
            shrinkWrap: true, // Important: allows grid to size itself
            physics:
                const NeverScrollableScrollPhysics(), // Disable internal scrolling
            children: const <Widget>[
              _TotalCustomersCard(),
              _ActiveLoansCard(),
              _OutstandingAmountCard(),
              _InterestEarnedCard(),
              _TotalDisbursedCard(),
              _PaymentsReceivedCard(),
            ],
          ),
        );
      },
    );
  }
}

/// ---------------------
/// Individual Cards (each wired to a single provider selector)
/// ---------------------
class _TotalCustomersCard extends ConsumerWidget {
  const _TotalCustomersCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int value = ref.watch(totalCustomersProvider);
    return StatCardWidget(
      icon: Icons.people,
      iconColor: AppColors.getPrimaryColor,
      value: Utility.numberFormate(value),
      title: context.l10n.totalCustomers,
    );
  }
}

class _ActiveLoansCard extends ConsumerWidget {
  const _ActiveLoansCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int value = ref.watch(activeLoansProvider);
    return StatCardWidget(
      icon: Icons.credit_card,
      iconColor: AppColors.getGreenColor,
      value: Utility.numberFormate(value),
      title: context.l10n.activeLoans,
    );
  }
}

class _OutstandingAmountCard extends ConsumerWidget {
  const _OutstandingAmountCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double value = ref.watch(outstandingAmountProvider);
    final l10n = context.l10n;
    return StatCardWidget(
      icon: Icons.account_balance_wallet,
      iconColor: AppColors.contentColorYellow,
      currency: true,
      value: Utility.doubleFormate(value),
      title: '${l10n.outstandingAmount}\n${l10n.outstandingAmountSub}',
    );
  }
}

class _InterestEarnedCard extends ConsumerWidget {
  const _InterestEarnedCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double value = ref.watch(interestEarnedProvider);
    final l10n = context.l10n;
    return StatCardWidget(
      icon: Icons.trending_up,
      iconColor: AppColors.contentColorPurple,
      value: Utility.doubleFormate(value),
      title: '${l10n.interestEarned}\n${l10n.interestEarnedSub}',
      currency: true,
    );
  }
}

class _TotalDisbursedCard extends ConsumerWidget {
  const _TotalDisbursedCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double value = ref.watch(totalDisbursedProvider);
    final l10n = context.l10n;
    return StatCardWidget(
      icon: Icons.arrow_upward,
      iconColor: AppColors.getErrorColor,
      value: Utility.doubleFormate(value),
      currency: true,
      title: '${l10n.totalDisbursed}\n${l10n.allTime}',
    );
  }
}

class _PaymentsReceivedCard extends ConsumerWidget {
  const _PaymentsReceivedCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double value = ref.watch(paymentsReceivedProvider);
    final l10n = context.l10n;
    return StatCardWidget(
      icon: Icons.arrow_downward,
      iconColor: AppColors.getGreenColor,
      currency: true,
      value: Utility.doubleFormate(value),
      title: '${l10n.paymentsReceived}\n${l10n.totalCollected}',
    );
  }
}

/// ---------------------
/// Stat card widget (self-contained & theme-aware)
/// ---------------------
class StatCardWidget extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String title;
  final bool currency;
  const StatCardWidget({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.title,
    this.currency = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.08),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const Spacer(),

            // Value
            currency
                ? CurrencyWidget(amount: value)
                : BodyOneDefaultText(text: value, bold: true),

            const SizedBox(height: 8),

            // Title / description
            Expanded(
              child: BodySmallText(
                text: title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
