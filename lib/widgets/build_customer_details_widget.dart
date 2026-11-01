import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/core/fonts/body_small_text.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/fonts/title_widget.dart';
import 'package:self_finance/core/localization/localization_extension.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/providers/customer_provider.dart';
import 'package:self_finance/widgets/dilogbox_widget.dart';
import 'package:self_finance/widgets/image_widget.dart';
import 'package:self_finance/widgets/loading_popup_widget.dart';
import 'package:self_finance/widgets/snack_bar_widget.dart';

class BuildCustomerDetailsWidget extends ConsumerWidget {
  const BuildCustomerDetailsWidget({
    super.key,
    required this.customerID,
    this.physics,
  });

  final String customerID;
  final ScrollPhysics? physics;

  Future<void> _handleCopy(
    BuildContext context,
    String text,
    String label,
  ) async {
    final l10n = context.l10n;
    await Utility.copyToClipboard(text: text);
    if (context.mounted) {
      SnackBarWidget.snackBarWidget(
        context: context,
        message: l10n.copiedToClipboard(label),
      );
    }
  }

  Future<void> _handleDelete(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final int confirmed = await AlertDilogs.alertDialogWithTwoAction(
      context,
      l10n.deleteContactQuestion,
      l10n.contactDeleteMessage,
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
    final l10n = context.l10n;
    return ref.watch(customerProvider(customerID)).when(
      data: (Customer? customer) {
        if (customer == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: BodyTwoDefaultText(
                text: l10n.errorFetchingContacts,
                error: true,
              ),
            ),
          );
        }

        return SingleChildScrollView(
          physics: physics ?? const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Contact & Personal Information Card
              _buildSectionHeader(
                icon: Icons.person_outline_rounded,
                title: l10n.personalAndContactInfo,
              ),
              const SizedBox(height: 8),
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    _buildInfoRow(
                      context: context,
                      icon: Icons.phone_rounded,
                      iconColor: AppColors.getPrimaryColor,
                      label: l10n.phoneNumber,
                      value: customer.number,
                      onTapValue: () =>
                          Utility.makeCall(phoneNumber: customer.number),
                      action: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.copy_rounded, size: 18),
                            tooltip: l10n.copiedToClipboard(l10n.phoneNumber),
                            color: AppColors.getLigthGreyColor,
                            onPressed: () => _handleCopy(
                              context,
                              customer.number,
                              l10n.phoneNumber,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.call_rounded, size: 20),
                            tooltip: l10n.call,
                            color: AppColors.getPrimaryColor,
                            onPressed: () =>
                                Utility.makeCall(phoneNumber: customer.number),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.getLigthGreyColor.withValues(alpha: 0.15),
                    ),
                    _buildInfoRow(
                      context: context,
                      icon: Icons.family_restroom_rounded,
                      iconColor: const Color(0xFF8B5CF6),
                      label: l10n.guardianName,
                      value: customer.guardianName.isNotEmpty
                          ? customer.guardianName
                          : l10n.notProvided,
                      action: customer.guardianName.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.copy_rounded, size: 18),
                              tooltip: l10n.copiedToClipboard(l10n.guardianName),
                              color: AppColors.getLigthGreyColor,
                              onPressed: () => _handleCopy(
                                context,
                                customer.guardianName,
                                l10n.guardianName,
                              ),
                            )
                          : null,
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.getLigthGreyColor.withValues(alpha: 0.15),
                    ),
                    _buildInfoRow(
                      context: context,
                      icon: Icons.location_on_rounded,
                      iconColor: const Color(0xFFF59E0B),
                      label: l10n.customerAddress,
                      value: customer.address.isNotEmpty
                          ? customer.address
                          : l10n.notProvided,
                      action: customer.address.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.copy_rounded, size: 18),
                              tooltip: l10n.copiedToClipboard(l10n.customerAddress),
                              color: AppColors.getLigthGreyColor,
                              onPressed: () => _handleCopy(
                                context,
                                customer.address,
                                l10n.customerAddress,
                              ),
                            )
                          : null,
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.getLigthGreyColor.withValues(alpha: 0.15),
                    ),
                    _buildInfoRow(
                      context: context,
                      icon: Icons.calendar_today_rounded,
                      iconColor: const Color(0xFF10B981),
                      label: l10n.customerSince,
                      value: Utility.formatDate(date: customer.createdDate),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // KYC & Proof Document Card
              _buildSectionHeader(
                icon: Icons.badge_outlined,
                title: l10n.kycAndIdentityProof,
              ),
              const SizedBox(height: 8),
              _buildProofSection(context, ref, customer),
              const SizedBox(height: 20),

              // Management Actions Card
              _buildSectionHeader(
                icon: Icons.settings_outlined,
                title: l10n.contactActions,
              ),
              const SizedBox(height: 8),
              Card(
                clipBehavior: Clip.antiAlias,
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
                      title: BodyOneDefaultText(
                        text: l10n.editContactDetails,
                        bold: true,
                      ),
                      subtitle: BodySmallText(
                        text: l10n.updateContactSubtitle,
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
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.getLigthGreyColor.withValues(alpha: 0.15),
                    ),
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
                      title: BodyOneDefaultText(
                        text: l10n.shareContactInfo,
                        bold: true,
                      ),
                      subtitle: BodySmallText(
                        text: l10n.shareContactSubtitle,
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                      ),
                      onTap: () => _handleShare(ref, customer),
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.getLigthGreyColor.withValues(alpha: 0.15),
                    ),
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
                      title: BodyOneDefaultText(
                        text: l10n.deleteCustomer,
                        bold: true,
                        color: AppColors.getErrorColor,
                      ),
                      subtitle: BodySmallText(
                        text: l10n.deleteCustomerSubtitle,
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
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: BodyTwoDefaultText(
            text: l10n.errorFetchingContacts,
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
  ) {
    final String? resolvedProofPath = ref.watch(customerProofPathProvider(customerID));

    final l10n = context.l10n;

    if (resolvedProofPath != null) {
      return Card(
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 14,
                          color: AppColors.getGreenColor,
                        ),
                        const SizedBox(width: 6),
                        BodySmallText(
                          text: l10n.verifiedDocument,
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
                        titile: l10n.customerProof,
                      );
                    },
                    icon: const Icon(Icons.fullscreen_rounded, size: 18),
                    label: BodyTwoDefaultText(
                      text: l10n.viewFull,
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
                    titile: l10n.customerProof,
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
                          title: l10n.customerProof,
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
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.zoom_in_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: BodySmallText(
                                    text: l10n.tapToPreviewKyc,
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

    return Card(
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
            TitleWidget(text: l10n.noIdentityProofAttached),
            const SizedBox(height: 4),
            BodySmallText(
              text: l10n.attachKycSubtitle,
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
              label: BodyTwoDefaultText(
                text: l10n.attachDocument,
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
