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
import 'package:self_finance/widgets/circular_image_widget.dart';
import 'package:self_finance/widgets/dilogbox_widget.dart';
import 'package:self_finance/widgets/image_widget.dart';
import 'package:self_finance/widgets/loading_popup_widget.dart';
import 'package:self_finance/widgets/snack_bar_widget.dart';

class BuildCustomerDetailsWidget extends ConsumerWidget {
  const BuildCustomerDetailsWidget({
    super.key,
    required this.customerID,
    this.showHero = false,
  });

  final int customerID;
  final bool showHero;

  Future<void> _handleCopy(
    BuildContext context,
    String text,
    String label,
  ) async {
    await Utility.copyToClipboard(text: text);
    if (context.mounted) {
      SnackBarWidget.snackBarWidget(
        context: context,
        message: "$label copied to clipboard",
      );
    }
  }

  Future<void> _handleDelete(BuildContext context, WidgetRef ref) async {
    final int confirmed = await AlertDilogs.alertDialogWithTwoAction(
      context,
      "Delete Contact?",
      Constant.contactDeleteMessage,
    );

    if (confirmed == 1 && context.mounted) {
      await runWithLoading(
        context,
        () => ref
            .read(customerProvider(customerID).notifier)
            .deleteCustomer(customerID),
      );

      if (context.mounted) {
        Routes.navigateToDashboard(context: context);
      }
    }
  }

  void _handleShare(WidgetRef ref, Customer customer) {
    ref
        .read(customerProvider(customerID).notifier)
        .shareCustomerDetails(customer);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color borderColor = isDark ? Colors.white12 : const Color(0xFFE2E8F0);

    return ref.watch(customerProvider(customerID)).when(
      data: (Customer? customer) {
        if (customer == null) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: BodyTwoDefaultText(
                text: Constant.errorFetchingContactMessage,
                error: true,
              ),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showHero) ...[
                const SizedBox(height: 12),
                Center(
                  child: CircularImageWidget(
                    imageData: customer.photo,
                    titile: customer.name,
                    customeSize: 100,
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: StrongHeadingOne(
                    text: customer.name,
                    bold: true,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Contact & Personal Information Card
              _buildSectionHeader(
                icon: Icons.person_outline_rounded,
                title: "Personal & Contact Info",
              ),
              const SizedBox(height: 8),
              Material(
                color: cardBg,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: borderColor),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      context: context,
                      icon: Icons.phone_rounded,
                      iconColor: AppColors.getPrimaryColor,
                      label: "Phone Number",
                      value: customer.number,
                      onTapValue: () =>
                          Utility.makeCall(phoneNumber: customer.number),
                      action: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.copy_rounded, size: 18),
                            tooltip: "Copy Number",
                            color: AppColors.getLigthGreyColor,
                            onPressed: () => _handleCopy(
                              context,
                              customer.number,
                              "Phone number",
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.call_rounded, size: 20),
                            tooltip: "Call",
                            color: AppColors.getPrimaryColor,
                            onPressed: () =>
                                Utility.makeCall(phoneNumber: customer.number),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, thickness: 1, color: borderColor),
                    _buildInfoRow(
                      context: context,
                      icon: Icons.family_restroom_rounded,
                      iconColor: const Color(0xFF8B5CF6),
                      label: Constant.guardianName,
                      value: customer.guardianName.isNotEmpty
                          ? customer.guardianName
                          : "Not provided",
                      action: customer.guardianName.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.copy_rounded, size: 18),
                              tooltip: "Copy Guardian",
                              color: AppColors.getLigthGreyColor,
                              onPressed: () => _handleCopy(
                                context,
                                customer.guardianName,
                                "Guardian name",
                              ),
                            )
                          : null,
                    ),
                    Divider(height: 1, thickness: 1, color: borderColor),
                    _buildInfoRow(
                      context: context,
                      icon: Icons.location_on_rounded,
                      iconColor: const Color(0xFFF59E0B),
                      label: Constant.customerAddress,
                      value: customer.address.isNotEmpty
                          ? customer.address
                          : "Not provided",
                      action: customer.address.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.copy_rounded, size: 18),
                              tooltip: "Copy Address",
                              color: AppColors.getLigthGreyColor,
                              onPressed: () => _handleCopy(
                                context,
                                customer.address,
                                "Address",
                              ),
                            )
                          : null,
                    ),
                    Divider(height: 1, thickness: 1, color: borderColor),
                    _buildInfoRow(
                      context: context,
                      icon: Icons.calendar_today_rounded,
                      iconColor: const Color(0xFF10B981),
                      label: "Customer Since",
                      value: Utility.formatDate(date: customer.createdDate),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // KYC & Proof Document Card
              _buildSectionHeader(
                icon: Icons.badge_outlined,
                title: "KYC & Identity Proof",
              ),
              const SizedBox(height: 8),
              _buildProofSection(context, ref, customer, cardBg, borderColor),
              const SizedBox(height: 20),

              // Management Actions Card
              _buildSectionHeader(
                icon: Icons.settings_outlined,
                title: "Contact Actions",
              ),
              const SizedBox(height: 8),
              Material(
                color: cardBg,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: borderColor),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.getPrimaryColor.withValues(
                            alpha: 0.12,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          color: AppColors.getPrimaryColor,
                          size: 20,
                        ),
                      ),
                      title: const BodyOneDefaultText(
                        text: "Edit Contact Details",
                        bold: true,
                      ),
                      subtitle: const BodySmallText(
                        text: "Update name, number, address, or photos",
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                      ),
                      onTap: () => Routes.navigateToContactEditingView(
                        context: context,
                        customer: customer,
                      ),
                    ),
                    Divider(height: 1, thickness: 1, color: borderColor),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.share_rounded,
                          color: Color(0xFF3B82F6),
                          size: 20,
                        ),
                      ),
                      title: const BodyOneDefaultText(
                        text: "Share Contact Info",
                        bold: true,
                      ),
                      subtitle: const BodySmallText(
                        text: "Share customer profile details",
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                      ),
                      onTap: () => _handleShare(ref, customer),
                    ),
                    Divider(height: 1, thickness: 1, color: borderColor),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.getErrorColor.withValues(
                            alpha: 0.12,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.getErrorColor,
                          size: 20,
                        ),
                      ),
                      title: const BodyOneDefaultText(
                        text: "Delete Customer",
                        bold: true,
                        color: AppColors.getErrorColor,
                      ),
                      subtitle: const BodySmallText(
                        text: "Permanently delete this customer and record",
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: AppColors.getErrorColor,
                      ),
                      onTap: () => _handleDelete(context, ref),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
      error: (error, _) => const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: BodyTwoDefaultText(
            text: Constant.errorFetchingContactMessage,
            error: true,
          ),
        ),
      ),
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: CircularProgressIndicator.adaptive(),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.getLigthGreyColor),
          const SizedBox(width: 8),
          Flexible(
            child: BodyTwoDefaultText(
              text: title,
              bold: true,
              color: AppColors.getLigthGreyColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    VoidCallback? onTapValue,
    Widget? action,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                BodySmallText(text: label, color: AppColors.getLigthGreyColor),
                const SizedBox(height: 2),
                GestureDetector(
                  onTap: onTapValue,
                  child: BodyOneDefaultText(
                    text: value,
                    bold: true,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
          ?action,
        ],
      ),
    );
  }

  Widget _buildProofSection(
    BuildContext context,
    WidgetRef ref,
    Customer customer,
    Color cardBg,
    Color borderColor,
  ) {
    final String? resolvedProofPath = ref.watch(customerProofPathProvider(customerID));

    if (resolvedProofPath != null) {
      return Material(
        color: cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.getGreenColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 14,
                          color: AppColors.getGreenColor,
                        ),
                        SizedBox(width: 6),
                        BodySmallText(
                          text: "Verified Document",
                          color: AppColors.getGreenColor,
                          bold: true,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      Routes.navigateToImageView(
                        context: context,
                        imagePath: resolvedProofPath,
                        titile: "Customer Proof",
                      );
                    },
                    icon: const Icon(Icons.fullscreen_rounded, size: 18),
                    label: const BodyTwoDefaultText(
                      text: "View Full",
                      color: AppColors.getPrimaryColor,
                      bold: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  Routes.navigateToImageView(
                    context: context,
                    imagePath: resolvedProofPath,
                    titile: "Customer Proof",
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 180,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ImageWidget(
                          imagePath: customer.proof,
                          title: "Customer Proof",
                          height: 180,
                          width: double.infinity,
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [Colors.black87, Colors.transparent],
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.zoom_in_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                SizedBox(width: 6),
                                Expanded(
                                  child: BodySmallText(
                                    text: "Tap to preview KYC document",
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Material(
      color: cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.getLigthGreyColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.document_scanner_outlined,
                size: 28,
                color: AppColors.getLigthGreyColor,
              ),
            ),
            const SizedBox(height: 10),
            const TitleWidget(text: "No Identity Proof Attached"),
            const SizedBox(height: 4),
            const BodySmallText(
              text:
                  "Attach an Aadhaar, PAN, voter card, or photo document for KYC verification.",
              textAlign: TextAlign.center,
              color: AppColors.getLigthGreyColor,
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () => Routes.navigateToContactEditingView(
                context: context,
                customer: customer,
              ),
              icon: const Icon(Icons.add_photo_alternate_rounded, size: 18),
              label: const BodyTwoDefaultText(
                text: "Attach Document",
                bold: true,
              ),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
