import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/core/fonts/body_small_text.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/localization/localization_extension.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/customer/models/customer_portal_models.dart';
import 'package:self_finance/customer/providers/customer_portal_provider.dart';
import 'package:self_finance/customer/views/customer_loan_detail_view.dart';
import 'package:self_finance/customer/views/customer_login_view.dart';
import 'package:self_finance/customer/widgets/customer_item_thumbnail_widget.dart';
import 'package:self_finance/widgets/circular_image_widget.dart';
import 'package:self_finance/widgets/currency_widget.dart';
import 'package:self_finance/widgets/status_chip_widget.dart';

class CustomerDashboardView extends ConsumerStatefulWidget {
  const CustomerDashboardView({super.key});

  @override
  ConsumerState<CustomerDashboardView> createState() =>
      _CustomerDashboardViewState();
}

class _CustomerDashboardViewState
    extends ConsumerState<CustomerDashboardView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleSignOut() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.logoutCustomer),
        content: const Text('Are you sure you want to log out of your customer portal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.getErrorColor,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(context.l10n.logoutCustomer),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await ref.read(customerPortalAuthProvider.notifier).signOut();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => const CustomerLoginView(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dataAsync = ref.watch(customerPortalDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: BodyOneDefaultText(
          text: l10n.customerDashboard,
          bold: true,
        ),
        actions: [
          IconButton(
            tooltip: l10n.logoutCustomer,
            icon: const Icon(Icons.logout_rounded),
            onPressed: _handleSignOut,
          ),
        ],
      ),
      body: SafeArea(
        child: dataAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator.adaptive(),
          ),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cloud_off_rounded,
                    size: 48,
                    color: AppColors.getErrorColor,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    error.toString().replaceFirst('Exception: ', ''),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => ref.refresh(customerPortalDataProvider),
                    child: Text(l10n.pleaseTryAgain),
                  ),
                ],
              ),
            ),
          ),
          data: (portalData) {
            if (portalData == null) {
              return Center(
                child: Text(l10n.noLoansFound),
              );
            }

            final customer = portalData.customer;
            final summary = portalData.summary;
            final allLoans = portalData.loans;
            final activeLoans =
                allLoans.where((l) => l.remainingAmount > 0).toList();
            final payments = portalData.payments;

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(customerPortalDataProvider);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Header Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircularImageWidget(
                              imageData: customer.photoPath,
                              titile: customer.name,
                              customeSize: 52,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  BodyOneDefaultText(
                                    text: customer.name,
                                    bold: true,
                                  ),
                                  const SizedBox(height: 4),
                                  BodySmallText(
                                    text: customer.contactNumber,
                                    color: AppColors.getLigthGreyColor,
                                  ),
                                  if (customer.guardianName.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    BodySmallText(
                                      text: 'c/o ${customer.guardianName}',
                                      color: AppColors.getLigthGreyColor,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Financial Summary Card
                    Card(
                      elevation: 2,
                      color: AppColors.getPrimaryColor.withValues(alpha: 0.08),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color:
                              AppColors.getPrimaryColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _SummaryTile(
                                  label: l10n.remainingBalance,
                                  amount: Utility.doubleFormate(summary.totalRemaining),
                                  highlight: true,
                                ),
                                _SummaryTile(
                                  label: l10n.totalBorrowed,
                                  amount: Utility.doubleFormate(summary.totalBorrowed),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _SummaryTile(
                                  label: l10n.totalPaid,
                                  amount: Utility.doubleFormate(summary.totalPaid),
                                  color: AppColors.getGreenColor,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    BodySmallText(
                                      text: l10n.active,
                                      color: AppColors.getLigthGreyColor,
                                    ),
                                    const SizedBox(height: 4),
                                    BodyTwoDefaultText(
                                      text: '${activeLoans.length} Loans',
                                      bold: true,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tabs
                    TabBar(
                      controller: _tabController,
                      labelColor: AppColors.getPrimaryColor,
                      indicatorColor: AppColors.getPrimaryColor,
                      tabs: [
                        Tab(text: '${l10n.active} (${activeLoans.length})'),
                        Tab(text: '${l10n.myLoans} (${allLoans.length})'),
                        Tab(text: '${l10n.paymentHistory} (${payments.length})'),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Tab Views container
                    SizedBox(
                      height: 500,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // 1. Active Loans
                          _LoansList(
                            loans: activeLoans,
                            payments: payments,
                            emptyMessage: 'No active loans currently.',
                          ),

                          // 2. All Loans
                          _LoansList(
                            loans: allLoans,
                            payments: payments,
                            emptyMessage: l10n.noLoansFound,
                          ),

                          // 3. Payment History
                          _PaymentsList(
                            payments: payments,
                            emptyMessage: l10n.noPaymentsFound,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String amount;
  final bool highlight;
  final Color? color;

  const _SummaryTile({
    required this.label,
    required this.amount,
    this.highlight = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BodySmallText(
          text: label,
          color: AppColors.getLigthGreyColor,
        ),
        const SizedBox(height: 4),
        CurrencyWidget(
          amount: amount,
          titleText: highlight,
          smallText: !highlight,
          color: color ?? (highlight ? AppColors.getPrimaryColor : null),
        ),
      ],
    );
  }
}

class _LoansList extends StatelessWidget {
  final List<CustomerPortalLoan> loans;
  final List<CustomerPortalPayment> payments;
  final String emptyMessage;

  const _LoansList({
    required this.loans,
    required this.payments,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (loans.isEmpty) {
      return Center(
        child: BodyTwoDefaultText(
          text: emptyMessage,
          color: AppColors.getLigthGreyColor,
        ),
      );
    }

    final DateFormat formatter = DateFormat('dd MMM yyyy');

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: loans.length,
      itemBuilder: (context, index) {
        final loan = loans[index];
        final bool isActive = loan.remainingAmount > 0;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => CustomerLoanDetailView(
                    loan: loan,
                    payments: payments,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Collateral thumbnail
                  CustomerItemThumbnailWidget(
                    imagePath: loan.itemPhotoPath,
                    title: loan.itemName,
                  ),
                  const SizedBox(width: 14),

                  // Loan info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: BodyTwoDefaultText(
                                text: loan.itemName,
                                bold: true,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            StatusChipWidget(
                              status: isActive ? 'Active' : 'Paid',
                              smallText: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                BodySmallText(
                                  text: 'Loan: ${formatter.format(loan.transactionDate)}',
                                  color: AppColors.getLigthGreyColor,
                                ),
                                const SizedBox(height: 2),
                                BodySmallText(
                                  text: 'Rate: ${loan.interestRate}%',
                                  color: AppColors.getLigthGreyColor,
                                ),
                              ],
                            ),
                            CurrencyWidget(
                              amount: Utility.doubleFormate(
                                isActive ? loan.remainingAmount : loan.amount,
                              ),
                              smallText: true,
                              color: isActive
                                  ? AppColors.getPrimaryColor
                                  : AppColors.getGreenColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.getLigthGreyColor,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PaymentsList extends StatelessWidget {
  final List<CustomerPortalPayment> payments;
  final String emptyMessage;

  const _PaymentsList({
    required this.payments,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (payments.isEmpty) {
      return Center(
        child: BodyTwoDefaultText(
          text: emptyMessage,
          color: AppColors.getLigthGreyColor,
        ),
      );
    }

    final DateFormat formatter = DateFormat('dd MMM yyyy, hh:mm a');

    return ListView.separated(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: payments.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final p = payments[index];
        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.getGreenColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_outline_rounded,
                        color: AppColors.getGreenColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BodyTwoDefaultText(
                          text: p.paymentType,
                          bold: true,
                        ),
                        const SizedBox(height: 2),
                        BodySmallText(
                          text: formatter.format(p.paymentDate),
                          color: AppColors.getLigthGreyColor,
                        ),
                      ],
                    ),
                  ],
                ),
                CurrencyWidget(
                  amount: Utility.doubleFormate(p.amountPaid),
                  color: AppColors.getGreenColor,
                  smallText: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
