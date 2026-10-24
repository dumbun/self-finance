import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/core/fonts/body_small_text.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/fonts/strong_heading_one_text.dart';
import 'package:self_finance/core/fonts/title_widget.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/providers/customer_provider.dart';
import 'package:self_finance/widgets/build_customer_details_widget.dart';
import 'package:self_finance/widgets/circular_image_widget.dart';
import 'package:self_finance/widgets/currency_widget.dart';
import 'package:self_finance/widgets/customer_transactions_widget.dart';
import 'package:self_finance/widgets/dilogbox_widget.dart';
import 'package:self_finance/widgets/fab.dart';
import 'package:self_finance/widgets/loading_popup_widget.dart';
import 'package:self_finance/widgets/snack_bar_widget.dart';

class ContactDetailsView extends ConsumerStatefulWidget {
  const ContactDetailsView({super.key, required this.customerID});
  final int customerID;

  @override
  ConsumerState<ContactDetailsView> createState() => _ContactDetailsViewState();
}

class _ContactDetailsViewState extends ConsumerState<ContactDetailsView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleShare(Customer customer) {
    ref
        .read(customerProvider(widget.customerID).notifier)
        .shareCustomerDetails(customer);
  }

  Future<void> _handleDelete(BuildContext context, Customer customer) async {
    final int confirmed = await AlertDilogs.alertDialogWithTwoAction(
      context,
      "Delete Contact?",
      Constant.contactDeleteMessage,
    );

    if (confirmed == 1 && context.mounted) {
      await runWithLoading(
        context,
        () => ref
            .read(customerProvider(widget.customerID).notifier)
            .deleteCustomer(widget.customerID),
      );

      if (context.mounted) {
        Routes.navigateToDashboard(context: context);
      }
    }
  }

  void _handleSms(String number) async {
    final bool launched = await Utility.sendSms(phoneNumber: number);
    if (!launched && mounted) {
      SnackBarWidget.snackBarWidget(
        context: context,
        message: "Unable to open SMS composer",
      );
    }
  }

  void _handleViewProof() {
    final String? proofPath = ref.read(
      customerProofPathProvider(widget.customerID),
    );

    if (proofPath != null) {
      Routes.navigateToImageView(
        context: context,
        imagePath: proofPath,
        titile: "Customer Proof",
      );
    } else {
      SnackBarWidget.snackBarWidget(
        context: context,
        message: "No proof document attached for this customer",
      );
    }
  }

  void _handleViewAvatar(Customer customer) {
    final String? photoPath = ref.read(
      customerPhotoPathProvider(widget.customerID),
    );

    if (photoPath != null) {
      Routes.navigateToImageView(
        context: context,
        imagePath: photoPath,
        titile: customer.name,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Fab(
        icon: Icons.add_rounded,
        heroTag: Constant.saveButtonTag,
        onPressed: () => Routes.navigateToAddNewTransactionToCustomerView(
          context: context,
          customerID: widget.customerID,
        ),
      ),
      body: ref
          .watch(customerProvider(widget.customerID))
          .when(
            data: (Customer? customer) {
              if (customer == null) {
                return _buildNotFoundState(context);
              }

              final int totalTransactionsCount = ref.watch(
                customerFinancialSummaryProvider(
                  widget.customerID,
                ).select((s) => s.totalTransactionsCount),
              );

              return NestedScrollView(
                headerSliverBuilder:
                    (BuildContext ctx, bool innerBoxIsScrolled) {
                      return [
                        // Modern App Bar
                        SliverAppBar(
                          pinned: true,
                          elevation: 0,

                          surfaceTintColor: Colors.transparent,
                          leading: Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Center(
                              child: Material(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  onTap: () => Navigator.of(context).pop(),
                                  child: const SizedBox(
                                    height: 38,
                                    width: 38,
                                    child: Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          title: BodyOneDefaultText(
                            text: customer.name,
                            bold: true,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          actions: [
                            IconButton(
                              icon: const Icon(
                                Icons.phone_rounded,
                                color: AppColors.getPrimaryColor,
                                size: 20,
                              ),
                              tooltip: "Call Customer",
                              onPressed: () => Utility.makeCall(
                                phoneNumber: customer.number,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 20),
                              tooltip: "Edit Customer",
                              onPressed: () =>
                                  Routes.navigateToContactEditingView(
                                    context: context,
                                    customer: customer,
                                  ),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.more_vert_rounded,
                                size: 20,
                              ),
                              onSelected: (String val) {
                                if (val == 'share') {
                                  _handleShare(customer);
                                } else if (val == 'edit') {
                                  Routes.navigateToContactEditingView(
                                    context: context,
                                    customer: customer,
                                  );
                                } else if (val == 'delete') {
                                  _handleDelete(context, customer);
                                }
                              },
                              itemBuilder: (BuildContext _) => [
                                const PopupMenuItem(
                                  value: 'share',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.share_rounded,
                                        color: Color(0xFF3B82F6),
                                        size: 18,
                                      ),
                                      SizedBox(width: 12),
                                      BodyTwoDefaultText(text: "Share Details"),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.edit_rounded,
                                        color: AppColors.getPrimaryColor,
                                        size: 18,
                                      ),
                                      SizedBox(width: 12),
                                      BodyTwoDefaultText(text: "Edit Contact"),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete_outline_rounded,
                                        color: AppColors.getErrorColor,
                                        size: 18,
                                      ),
                                      SizedBox(width: 12),
                                      BodyTwoDefaultText(
                                        text: "Delete Contact",
                                        color: AppColors.getErrorColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 4),
                          ],
                        ),

                        // Hero Profile Card + Financial Summary
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                            child: Column(
                              children: [
                                _buildHeroProfileCard(
                                  context: context,
                                  customer: customer,
                                ),
                                const SizedBox(height: 12),
                                _CustomerFinancialSummaryWidget(
                                  customerID: widget.customerID,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Pinned Tab Bar
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _SliverTabBarDelegate(
                            TabBar(
                              controller: _tabController,
                              dividerColor: Colors.transparent,
                              indicatorSize: TabBarIndicatorSize.tab,
                              indicator: BoxDecoration(
                                color: AppColors.getPrimaryColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              labelColor: Colors.white,

                              tabs: [
                                Tab(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.receipt_long_rounded,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Transactions ($totalTransactionsCount)",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Tab(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.badge_outlined, size: 18),
                                      SizedBox(width: 8),
                                      Text(
                                        "KYC & Details",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ];
                    },
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    CustomerTransactionsWidget(customerId: widget.customerID),
                    BuildCustomerDetailsWidget(customerID: widget.customerID),
                  ],
                ),
              );
            },
            error: (error, _) => Scaffold(
              appBar: AppBar(title: const Text("Error")),
              body: const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: BodyTwoDefaultText(
                    text: Constant.errorFetchingContactMessage,
                    error: true,
                  ),
                ),
              ),
            ),
            loading: () => const Scaffold(
              body: Center(child: CircularProgressIndicator.adaptive()),
            ),
          ),
    );
  }

  Widget _buildHeroProfileCard({
    required BuildContext context,
    required Customer customer,
  }) {
    return Material(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Top Row: Avatar + Customer Overview
            Row(
              children: [
                GestureDetector(
                  onTap: () => _handleViewAvatar(customer),
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.getPrimaryColor,
                            width: 2,
                          ),
                        ),
                        child: CircularImageWidget(
                          imageData: customer.photo,
                          titile: customer.name,
                          customeSize: 68,
                        ),
                      ),
                      if (customer.photo.isNotEmpty)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.getPrimaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.zoom_in_rounded,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: StrongHeadingOne(
                              text: customer.name,
                              bold: true,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.getPrimaryColor.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: BodySmallText(
                              text: "ID #${customer.id}",
                              bold: true,
                              color: AppColors.getPrimaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (customer.guardianName.isNotEmpty)
                        Row(
                          children: [
                            const Icon(
                              Icons.family_restroom_rounded,
                              size: 14,
                              color: AppColors.getLigthGreyColor,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: BodyTwoDefaultText(
                                text: customer.guardianName,
                                color: AppColors.getLigthGreyColor,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: AppColors.getLigthGreyColor,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: BodySmallText(
                              text: customer.address.isNotEmpty
                                  ? customer.address
                                  : "No address provided",
                              color: AppColors.getLigthGreyColor,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 12),

            // Quick Action Pills
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionPill(
                  icon: Icons.phone_rounded,
                  label: "Call",
                  color: AppColors.getPrimaryColor,
                  onTap: () => Utility.makeCall(phoneNumber: customer.number),
                ),
                _buildActionPill(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: "SMS",
                  color: const Color(0xFF10B981),
                  onTap: () => _handleSms(customer.number),
                ),
                _buildActionPill(
                  icon: Icons.badge_outlined,
                  label: "KYC Proof",
                  color: const Color(0xFF8B5CF6),
                  onTap: _handleViewProof,
                ),
                _buildActionPill(
                  icon: Icons.add_card_rounded,
                  label: "New Loan",
                  color: const Color(0xFFF59E0B),
                  onTap: () => Routes.navigateToAddNewTransactionToCustomerView(
                    context: context,
                    customerID: widget.customerID,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionPill({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 6),
              BodySmallText(text: label, bold: true, color: color),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotFoundState(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.person_off_rounded,
                size: 56,
                color: AppColors.getErrorColor,
              ),
              const SizedBox(height: 16),
              const TitleWidget(text: "Customer Not Found"),
              const SizedBox(height: 8),
              const BodySmallText(
                text:
                    "The requested customer profile could not be found or has been removed.",
                textAlign: TextAlign.center,
                color: AppColors.getLigthGreyColor,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Go Back"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dedicated, memoized financial metrics widget that only rebuilds when financial stats change
class _CustomerFinancialSummaryWidget extends ConsumerWidget {
  const _CustomerFinancialSummaryWidget({required this.customerID});

  final int customerID;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CustomerFinancialSummary summary = ref.watch(
      customerFinancialSummaryProvider(customerID),
    );

    return Material(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            // Stat 1: Active Loans
            Expanded(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.getGreenColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const BodySmallText(
                        text: "Active",
                        color: AppColors.getLigthGreyColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  TitleWidget(
                    text: "${summary.activeCount} Loans",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36, width: 1),

            // Stat 2: Active Principal
            Expanded(
              child: Column(
                children: [
                  const BodySmallText(
                    text: "Active Balance",
                    color: AppColors.getLigthGreyColor,
                  ),
                  const SizedBox(height: 4),
                  CurrencyWidget(
                    amount: Utility.doubleFormate(summary.activeBalance),
                    smallText: true,
                    color: summary.activeBalance > 0
                        ? AppColors.getGreenColor
                        : AppColors.getLigthGreyColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36, width: 1),

            // Stat 3: Total Borrowed
            Expanded(
              child: Column(
                children: [
                  const BodySmallText(
                    text: "Total Borrowed",
                    color: AppColors.getLigthGreyColor,
                  ),
                  const SizedBox(height: 4),
                  CurrencyWidget(
                    amount: Utility.doubleFormate(summary.totalBorrowed),
                    smallText: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height + 16;

  @override
  double get maxExtent => _tabBar.preferredSize.height + 16;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(3),
        child: _tabBar,
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return oldDelegate._tabBar != _tabBar;
  }
}
