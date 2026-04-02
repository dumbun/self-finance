import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/fonts/title_widget.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/models/user_model.dart';
import 'package:self_finance/providers/user_provider.dart';
import 'package:self_finance/widgets/app_version_widget.dart';
import 'package:self_finance/widgets/backup_button_widget.dart';
import 'package:self_finance/widgets/biometric_switch_widget.dart';
import 'package:self_finance/widgets/csv_export_widget.dart';
import 'package:self_finance/widgets/dilogbox_widget.dart';
import 'package:self_finance/widgets/notification_switch_widget.dart';
import 'package:self_finance/widgets/pin_update_buttom_sheet_widget.dart';
import 'package:self_finance/widgets/privacy_policy_button_widget.dart';
import 'package:self_finance/widgets/section_header_widget.dart';
import 'package:self_finance/widgets/terms_and_condition_widget.dart';
import 'package:self_finance/widgets/theme_switch_widget.dart';
import 'package:self_finance/widgets/user_image_update_widget.dart';
import 'package:self_finance/widgets/user_name_update_buttom_sheet_widget.dart';

///[AccountSettingsView]
/// Account settings screen that allows users to update profile details,
/// security settings, preferences, and export/backup data.
class AccountSettingsView extends ConsumerWidget {
  const AccountSettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: const BodyTwoDefaultText(
          bold: true,
          text: Constant.accountSettings,
        ),
      ),
      body: SafeArea(
        child: ref
            .watch(userProvider)
            .when(
              data: (User? user) => _AccountSettingsBody(user: user, ref: ref),
              loading: () => const _SettingsLoadingSkeleton(),
              error: (error, _) => _SettingsErrorView(
                onRetry: () => ref.refresh(userProvider.future).ignore(),
              ),
            ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

class _AccountSettingsBody extends StatelessWidget {
  const _AccountSettingsBody({required this.user, required this.ref});

  final User? user;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final User? data = user;

    if (data == null || data.id == null) {
      return const Center(
        child: BodyTwoDefaultText(text: Constant.errorUserFetch),
      );
    }

    final int userId = data.id!;
    const SizedBox gap = SizedBox(height: 12);
    return RefreshIndicator(
      onRefresh: () async => ref.refresh(userProvider.future).ignore(),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          // ── Profile ──────────────────────────────────────────────────────
          const SectionHeaderWidget(label: 'Profile'),
          gap,
          UserImageUpdateWidget(userImageString: data.profilePicture),
          gap,
          _NameTile(context: context, userId: userId, userName: data.userName),
          gap,

          // ── Security ─────────────────────────────────────────────────────
          const SectionHeaderWidget(label: 'Security'),
          gap,
          _PinTile(context: context, userId: userId, userPin: data.userPin),
          gap,
          _CurrencyTile(
            context: context,
            userId: userId,
            currency: data.userCurrency,
            ref: ref,
          ),
          gap,

          // ── Preferences ──────────────────────────────────────────────────
          const SectionHeaderWidget(label: 'Preferences'),
          gap,
          const ThemeSwitchWidget(),
          gap,
          const NotificationSwitchWidget(),
          gap,
          const BiometricSwitchWidget(),
          gap,

          // ── Data & Backup ────────────────────────────────────────────────
          const SectionHeaderWidget(label: 'Data & Backup'),
          gap,
          const BackupButtonWidget(),
          gap,
          _SettingsTile(
            title: 'Export to CSV',
            semanticsLabel: 'Export transactions to CSV file',
            icon: const Icon(
              Icons.file_download_outlined,
              color: AppColors.getPrimaryColor,
            ),
            onTap: () => CsvExportWidget.show(context),
          ),
          gap,

          // ── Legal ────────────────────────────────────────────────────────
          const SectionHeaderWidget(label: 'Legal'),
          gap,
          const TermsAndConditionWidget(),
          gap,
          const PrivacyPolicyButtonWidget(),
          gap,

          // ── Account ──────────────────────────────────────────────────────
          const SectionHeaderWidget(label: 'Account'),
          gap,
          _SettingsTile(
            title: Constant.logout,
            semanticsLabel: 'Log out and close the app',
            icon: const Icon(Icons.logout, color: AppColors.getErrorColor),
            onTap: () => Utility.closeApp(context: context),
          ),
          gap,

          // ── About ────────────────────────────────────────────────────────
          const AppVersionWidget(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable tiles
// ---------------------------------------------------------------------------

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.title,
    required this.icon,
    required this.onTap,
    this.semanticsLabel,
  });

  final String title;
  final String? semanticsLabel;
  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel ?? title,
      button: true,
      child: Card(
        child: ListTile(
          onTap: onTap,
          trailing: icon,
          title: BodyOneDefaultText(text: title, bold: true),
        ),
      ),
    );
  }
}

class _NameTile extends StatelessWidget {
  const _NameTile({
    required this.context,
    required this.userId,
    required this.userName,
  });

  final BuildContext context;
  final int userId;
  final String userName;

  @override
  Widget build(BuildContext context) {
    return _SettingsTile(
      title: userName,
      semanticsLabel: 'Edit display name: $userName',
      icon: const Icon(Icons.edit, color: AppColors.getPrimaryColor),
      onTap: () => showBottomSheet(
        showDragHandle: true,
        enableDrag: true,
        context: context,
        builder: (_) =>
            UserNameUpdateButtomSheetWidget(userId: userId, userName: userName),
      ),
    );
  }
}

class _PinTile extends StatelessWidget {
  const _PinTile({
    required this.context,
    required this.userId,
    required this.userPin,
  });

  final BuildContext context;
  final int userId;
  final String userPin;

  @override
  Widget build(BuildContext context) {
    return _SettingsTile(
      title: 'Change App Pin',
      semanticsLabel: 'Change your 4-digit app PIN',
      icon: const Icon(Icons.lock, color: AppColors.getPrimaryColor),
      onTap: () => showBottomSheet(
        showDragHandle: true,
        context: context,
        builder: (_) =>
            PinUpdatebuttomSheetWidget(id: userId, userPin: userPin),
      ),
    );
  }
}

class _CurrencyTile extends StatelessWidget {
  const _CurrencyTile({
    required this.context,
    required this.userId,
    required this.currency,
    required this.ref,
  });

  final BuildContext context;
  final int userId;
  final String currency;
  final WidgetRef ref;

  Future<void> _onTap(BuildContext context) async {
    final int result = await AlertDilogs.alertDialogWithTwoAction(
      context,
      Constant.alert,
      Constant.currencyChangeAlert,
    );

    // Guard against unmounted context after async gap.
    if (result != 1 || !context.mounted) return;

    showCurrencyPicker(
      theme: CurrencyPickerThemeData(bottomSheetHeight: 720),
      useRootNavigator: true,
      context: context,
      showFlag: true,
      showSearchField: true,
      showCurrencyName: true,
      showCurrencyCode: true,
      onSelect: (Currency selected) {
        ref
            .read(userProvider.notifier)
            .changeCurrency(id: userId, newCurrency: selected.symbol);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _SettingsTile(
      title: 'Change App Currency',
      semanticsLabel: 'Current currency: $currency. Tap to change.',
      icon: TitleWidget(
        bold: true,
        color: AppColors.getPrimaryColor,
        text: currency,
      ),
      onTap: () => _onTap(context),
    );
  }
}

// ---------------------------------------------------------------------------
// Loading skeleton
// ---------------------------------------------------------------------------

class _SettingsLoadingSkeleton extends StatelessWidget {
  const _SettingsLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      itemCount: 8,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, index) => _ShimmerTile(width: index.isEven ? 200 : 260),
    );
  }
}

class _ShimmerTile extends StatelessWidget {
  const _ShimmerTile({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    final Color base = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Card(
      child: ListTile(
        title: Container(
          height: 14,
          width: width,
          decoration: BoxDecoration(
            color: base,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        trailing: Container(
          height: 24,
          width: 24,
          decoration: BoxDecoration(color: base, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error view
// ---------------------------------------------------------------------------

class _SettingsErrorView extends StatelessWidget {
  const _SettingsErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 12),
          const BodyOneDefaultText(text: Constant.errorUserFetch, bold: true),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
