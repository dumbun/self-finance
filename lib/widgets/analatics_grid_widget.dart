import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/providers/analytics_provider.dart';
import 'package:self_finance/widgets/currency_widget.dart';

class AnalaticsGridWidget extends ConsumerWidget {
  const AnalaticsGridWidget({super.key});

  /// Adjust breakpoints to taste
  int _columnsForWidth(double width) {
    if (width >= 1100) return 4;
    if (width >= 700) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _columnsForWidth(constraints.maxWidth);

        return Padding(
          padding: EdgeInsets.all(16.sp),
          child: GridView.count(
            crossAxisCount: columns,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.15,
            shrinkWrap: true, // Important: allows grid to size itself
            physics:
                const NeverScrollableScrollPhysics(), // Disable internal scrolling
            children: const [
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
      title: 'Total Customers',
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
      title: 'Active Loans',
    );
  }
}

class _OutstandingAmountCard extends ConsumerWidget {
  const _OutstandingAmountCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double value = ref.watch(outstandingAmountProvider);
    return StatCardWidget(
      icon: Icons.account_balance_wallet,
      iconColor: AppColors.contentColorYellow,
      currency: true,
      value: Utility.doubleFormate(value),
      title: 'Outstanding Amount\nTo be collected',
    );
  }
}

class _InterestEarnedCard extends ConsumerWidget {
  const _InterestEarnedCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double value = ref.watch(interestEarnedProvider);
    return StatCardWidget(
      icon: Icons.trending_up,
      iconColor: AppColors.contentColorPurple,
      value: Utility.doubleFormate(value),
      title: 'Interest Earned\nFrom completed',
      currency: true,
    );
  }
}

class _TotalDisbursedCard extends ConsumerWidget {
  const _TotalDisbursedCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double value = ref.watch(totalDisbursedProvider);
    return StatCardWidget(
      icon: Icons.arrow_upward,
      iconColor: AppColors.getErrorColor,
      value: Utility.doubleFormate(value),
      currency: true,
      title: 'Total Disbursed\nAll time',
    );
  }
}

class _PaymentsReceivedCard extends ConsumerWidget {
  const _PaymentsReceivedCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double value = ref.watch(paymentsReceivedProvider);
    return StatCardWidget(
      icon: Icons.arrow_downward,
      iconColor: AppColors.getGreenColor,
      currency: true,
      value: Utility.doubleFormate(value),
      title: 'Payments Received\nTotal collected',
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.sp)),
      child: Container(
        padding: EdgeInsets.all(16.sp),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16.sp),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon with soft background
            Container(
              padding: EdgeInsets.all(12.sp),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12.sp),
              ),
              child: Icon(icon, color: iconColor, size: 18.sp),
            ),

            const Spacer(),

            // Value
            currency
                ? CurrencyWidget(amount: value)
                : BodyOneDefaultText(text: value, bold: true),

            SizedBox(height: 8.sp),

            // Title / description
            BodyTwoDefaultText(text: title),
          ],
        ),
      ),
    );
  }
}
