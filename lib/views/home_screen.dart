import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/core/fonts/body_small_text.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/localization/localization_extension.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/providers/analytics_provider.dart';
import 'package:self_finance/providers/transactions_provider.dart';
import 'package:self_finance/providers/user_provider.dart';
import 'package:self_finance/widgets/analatics_grid_widget.dart';
import 'package:self_finance/widgets/circular_image_widget.dart';
import 'package:self_finance/widgets/currency_widget.dart';
import 'package:self_finance/widgets/invite_button_widget.dart';
import 'package:self_finance/widgets/monthly_chart_widget.dart';
import 'package:self_finance/widgets/status_chip_widget.dart';

class HomeScreen extends ConsumerWidget {
  final ValueChanged<int>? onNavigateToTab;

  const HomeScreen({
    super.key,
    this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(analyticsProvider);
        ref.invalidate(transactionsProvider);
        ref.invalidate(userProvider);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          // ── 1. Executive Greeting & Date Bar ──
          _ExecutiveGreetingBar(),
          const SizedBox(height: 16),

          // ── 2. Hero Portfolio Balance Card ──
          const _PortfolioHeroCard(),
          const SizedBox(height: 20),

          // ── 3. Quick Actions Command Hub ──
          _QuickActionsHub(onNavigateToTab: onNavigateToTab),
          const SizedBox(height: 22),

          // ── 4. Cashflow Trends & Performance Chart ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BodyTwoDefaultText(
                text: l10n.cashflowAnalytics,
                bold: true,
              ),
              const Icon(
                Icons.insights_rounded,
                size: 18,
                color: AppColors.getPrimaryColor,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Card(
            elevation: 1.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(
                color: theme.dividerColor.withValues(alpha: 0.08),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: MonthlyChartSection(),
            ),
          ),
          const SizedBox(height: 22),

          // ── 5. Financial Breakdown Metrics Grid ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BodyTwoDefaultText(
                text: l10n.businessBreakdown,
                bold: true,
              ),
              const Icon(
                Icons.bar_chart_rounded,
                size: 18,
                color: AppColors.getPrimaryColor,
              ),
            ],
          ),
          const SizedBox(height: 10),
          const AnalaticsGridWidget(padding: EdgeInsets.zero),
          const SizedBox(height: 22),

          // ── 6. Recent Activity Stream ──
          _RecentActivitySection(onNavigateToTab: onNavigateToTab),
          const SizedBox(height: 24),

          // ── 7. Clean Minimal Invite / App Info Card ──
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.dividerColor.withValues(alpha: 0.08),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: InviteButtonWidget(),
            ),
          ),

          // Ample bottom padding for FAB & Bottom Navigation Bar
          const SizedBox(height: 70),
        ],
      ),
    );
  }
}

// =============================================================================
// 1. EXECUTIVE GREETING BAR
// =============================================================================

class _ExecutiveGreetingBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final user = userAsync.value;
    final userName = user?.userName.trim() ?? '';

    final now = DateTime.now();
    final hour = now.hour;
    final String greeting;
    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 17) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }

    final dateStr = DateFormat('EEE, d MMM').format(now);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    greeting,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.getLigthGreyColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text('👋', style: TextStyle(fontSize: 14)),
                ],
              ),
              const SizedBox(height: 2),
              BodyOneDefaultText(
                text: userName.isNotEmpty ? userName : 'Welcome back',
                bold: true,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.getPrimaryColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.getPrimaryColor.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 13,
                color: AppColors.getPrimaryColor,
              ),
              const SizedBox(width: 6),
              Text(
                dateStr,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getPrimaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// 2. HERO PORTFOLIO BALANCE CARD
// =============================================================================

class _PortfolioHeroCard extends ConsumerWidget {
  const _PortfolioHeroCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final outstanding = ref.watch(outstandingAmountProvider);
    final disbursed = ref.watch(totalDisbursedProvider);
    final collected = ref.watch(paymentsReceivedProvider);
    final activeCount = ref.watch(activeLoansProvider);
    final totalCust = ref.watch(totalCustomersProvider);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            AppColors.getPrimaryColor,
            AppColors.getPrimaryColor.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.getPrimaryColor.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top tag
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.activePortfolioBalance,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.9),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$activeCount ${l10n.active}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Large outstanding amount
            CurrencyWidget(
              amount: Utility.doubleFormate(outstanding),
              titleText: true,
              color: Colors.white,
            ),
            const SizedBox(height: 18),

            // Thin divider
            Container(
              height: 1,
              color: Colors.white.withValues(alpha: 0.18),
            ),
            const SizedBox(height: 16),

            // Disbursed vs Collected mini tiles
            Row(
              children: [
                Expanded(
                  child: _HeroSubMetric(
                    label: l10n.totalDisbursed,
                    amount: Utility.doubleFormate(disbursed),
                    icon: Icons.arrow_upward_rounded,
                    accentColor: const Color(0xFFFF8A80),
                  ),
                ),
                Container(
                  width: 1,
                  height: 38,
                  color: Colors.white.withValues(alpha: 0.18),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: _HeroSubMetric(
                      label: l10n.paymentsReceived,
                      amount: Utility.doubleFormate(collected),
                      icon: Icons.arrow_downward_rounded,
                      accentColor: const Color(0xFFB9F6CA),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Customer count indicator chip
            Row(
              children: [
                const Icon(
                  Icons.people_alt_rounded,
                  size: 14,
                  color: Colors.white70,
                ),
                const SizedBox(width: 6),
                Text(
                  '$totalCust ${l10n.totalCustomers}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroSubMetric extends StatelessWidget {
  final String label;
  final String amount;
  final IconData icon;
  final Color accentColor;

  const _HeroSubMetric({
    required this.label,
    required this.amount,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.22),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 12, color: accentColor),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.8),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        CurrencyWidget(
          amount: amount,
          smallText: true,
          color: Colors.white,
        ),
      ],
    );
  }
}

// =============================================================================
// 3. QUICK ACTIONS COMMAND HUB
// =============================================================================

class _QuickActionsHub extends StatelessWidget {
  final ValueChanged<int>? onNavigateToTab;

  const _QuickActionsHub({this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BodyTwoDefaultText(
          text: l10n.quickActions,
          bold: true,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                label: l10n.newLoanAction,
                icon: Icons.add_circle_outline_rounded,
                color: AppColors.getPrimaryColor,
                onTap: () => Routes.navigateToAddNewEntry(context: context),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickActionButton(
                label: l10n.borrowersAction,
                icon: Icons.people_outline_rounded,
                color: const Color(0xFF0288D1),
                onTap: () => Routes.navigateToContactsView(context),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickActionButton(
                label: l10n.ledgerAction,
                icon: Icons.receipt_long_rounded,
                color: const Color(0xFFF57C00),
                onTap: () => onNavigateToTab?.call(1),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickActionButton(
                label: l10n.calculator,
                icon: Icons.calculate_outlined,
                color: const Color(0xFF43A047),
                onTap: () => onNavigateToTab?.call(2),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.08),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// 6. RECENT ACTIVITY SECTION
// =============================================================================

class _RecentActivitySection extends ConsumerWidget {
  final ValueChanged<int>? onNavigateToTab;

  const _RecentActivitySection({this.onNavigateToTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final paginationState = ref.watch(transactionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BodyTwoDefaultText(
              text: l10n.recentActivity,
              bold: true,
            ),
            TextButton(
              onPressed: () => onNavigateToTab?.call(1),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.viewAll,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getPrimaryColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: AppColors.getPrimaryColor,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        paginationState.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator.adaptive(),
            ),
          ),
          error: (_, _) => const SizedBox.shrink(),
          data: (state) {
            final transactions = state.transactions.take(3).toList();
            if (transactions.isEmpty) {
              return Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.08),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 36,
                        color: AppColors.getLigthGreyColor.withValues(alpha: 0.6),
                      ),
                      const SizedBox(height: 8),
                      BodySmallText(
                        text: l10n.noRecentActivity,
                        color: AppColors.getLigthGreyColor,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.getPrimaryColor,
                          side: const BorderSide(color: AppColors.getPrimaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () =>
                            Routes.navigateToAddNewEntry(context: context),
                        icon: const Icon(Icons.add, size: 16),
                        label: Text(l10n.newLoanAction),
                      ),
                    ],
                  ),
                ),
              );
            }

            final DateFormat formatter = DateFormat('dd MMM yyyy');

            return Column(
              children: transactions.map((t) {
                final bool isActive = t.remainingAmount > 0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: theme.dividerColor.withValues(alpha: 0.08),
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        Routes.navigateToTransactionDetailsView(
                          context: context,
                          transacrtionId: t.id,
                          customerId: t.customerId,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            CircularImageWidget(
                              imageData: t.customerPhoto,
                              titile: t.customerName,
                              customeSize: 42,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  BodyTwoDefaultText(
                                    text: t.customerName,
                                    bold: true,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  BodySmallText(
                                    text: formatter.format(t.transactionDate),
                                    color: AppColors.getLigthGreyColor,
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                CurrencyWidget(
                                  amount: Utility.doubleFormate(t.amount),
                                  smallText: true,
                                ),
                                const SizedBox(height: 4),
                                StatusChipWidget(
                                  status: isActive ? 'Active' : 'Paid',
                                  smallText: true,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
