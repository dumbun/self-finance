import 'package:flutter/material.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/views/EMI%20Calculator/emi_calculator_view.dart';
import 'package:self_finance/widgets/restore_widget.dart';

class TermsAndConditons extends StatefulWidget {
  const TermsAndConditons({super.key});

  @override
  State<TermsAndConditons> createState() => _TermsAndConditonsState();
}

typedef TermsAndConditions = TermsAndConditons;

class _TermsAndConditonsState extends State<TermsAndConditons> {
  bool _termsAccepted = false;
  bool _privacyAccepted = false;
  int _selectedTab = 0; // 0: Onboarding / Terms, 1: EMI Calculator
  bool _showRestoreSection = false;

  bool get _canProceed => _termsAccepted && _privacyAccepted;

  void _acceptAll() {
    setState(() {
      final bool newValue = !_canProceed;
      _termsAccepted = newValue;
      _privacyAccepted = newValue;
    });
  }

  void _onProceed() {
    if (!_canProceed) return;
    Routes.navigateToPinCreatingView(context);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final Color cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.08);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Segment (Get Started vs EMI Calculator)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: _SegmentButton(
                        title: "Get Started",
                        icon: Icons.rocket_launch_outlined,
                        isSelected: _selectedTab == 0,
                        isDark: isDark,
                        onTap: () => setState(() => _selectedTab = 0),
                      ),
                    ),
                    Expanded(
                      child: _SegmentButton(
                        title: Constant.emiCalculatorTitle,
                        icon: Icons.calculate_outlined,
                        isSelected: _selectedTab == 1,
                        isDark: isDark,
                        onTap: () => setState(() => _selectedTab = 1),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tab Content
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: _selectedTab == 0
                    ? _buildOnboardingView(
                        isDark: isDark,
                        cardBg: cardBg,
                        borderColor: borderColor,
                      )
                    : const EMICalculatorView(
                        key: ValueKey('emi_calculator_tab'),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingView({
    required bool isDark,
    required Color cardBg,
    required Color borderColor,
  }) {
    return SingleChildScrollView(
      key: const ValueKey('onboarding_tab'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Welcome Header (Isolated with RepaintBoundary)
          _TermsHeroHeader(
            cardBg: cardBg,
            borderColor: borderColor,
            isDark: isDark,
          ),

          const SizedBox(height: 24),

          // Value Pillars / Features (Modularized widgets)
          _FeatureTile(
            icon: Icons.lock_outline_rounded,
            title: "100% Offline & Private",
            subtitle:
                "Your ledger is stored locally on this device. No servers, no tracking.",
            isDark: isDark,
            cardBg: cardBg,
            borderColor: borderColor,
          ),
          const SizedBox(height: 10),
          _FeatureTile(
            icon: Icons.auto_graph_rounded,
            title: "Automated Interest Tracking",
            subtitle:
                "Accurately compute monthly interest and overdue loans in real-time.",
            isDark: isDark,
            cardBg: cardBg,
            borderColor: borderColor,
          ),
          const SizedBox(height: 10),
          _FeatureTile(
            icon: Icons.receipt_long_outlined,
            title: "Digital Receipts & Signatures",
            subtitle:
                "Capture borrower signatures and export professional PDF statements.",
            isDark: isDark,
            cardBg: cardBg,
            borderColor: borderColor,
          ),

          const SizedBox(height: 24),

          // Terms Acceptance Card (Isolated with RepaintBoundary)
          RepaintBoundary(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header with "Accept All" quick toggle
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.gavel_rounded,
                              size: 18,
                              color: AppColors.getPrimaryColor,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Agreements & Policies",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: _acceptAll,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            _canProceed ? "Clear All" : "Select All",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.getPrimaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: borderColor),

                  // Item 1: Terms and Conditions
                  _AgreementRow(
                    value: _termsAccepted,
                    onChanged: (val) =>
                        setState(() => _termsAccepted = val ?? false),
                    title: "Terms & Conditions",
                    subtitle: "I have read and agree to the Terms of Service.",
                    url: Constant.tAndcUrl,
                    isDark: isDark,
                  ),

                  Divider(height: 1, color: borderColor),

                  // Item 2: Privacy Policy
                  _AgreementRow(
                    value: _privacyAccepted,
                    onChanged: (val) =>
                        setState(() => _privacyAccepted = val ?? false),
                    title: "Privacy Policy",
                    subtitle:
                        "I acknowledge how my local data and security are handled.",
                    url: Constant.pAndPUrl,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Primary Continue Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _canProceed ? _onProceed : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.getPrimaryColor,
                disabledBackgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.08),
                foregroundColor: Colors.white,
                disabledForegroundColor: AppColors.getLigthGreyColor,
                elevation: _canProceed ? 3 : 0,
                shadowColor: AppColors.getPrimaryColor.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Get Started",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                      color: _canProceed
                          ? Colors.white
                          : AppColors.getLigthGreyColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: _canProceed
                        ? Colors.white
                        : AppColors.getLigthGreyColor,
                  ),
                ],
              ),
            ),
          ),

          if (!_canProceed) ...[
            const SizedBox(height: 8),
            const Center(
              child: Text(
                "Please accept the Terms & Privacy Policy to continue",
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.getLigthGreyColor,
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Restore Backup Expandable Card with Smooth AnimatedSize
          Center(
            child: TextButton.icon(
              onPressed: () {
                setState(() => _showRestoreSection = !_showRestoreSection);
              },
              icon: Icon(
                _showRestoreSection
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.restore_rounded,
                size: 18,
                color: AppColors.getPrimaryColor,
              ),
              label: Text(
                _showRestoreSection
                    ? "Hide Restore Options"
                    : "Existing user? Restore from Backup",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getPrimaryColor,
                ),
              ),
            ),
          ),

          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOutCubic,
            child: _showRestoreSection
                ? const Column(
                    children: [
                      SizedBox(height: 8),
                      RestoreWithProgressWidget(),
                    ],
                  )
                : const SizedBox.shrink(),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _TermsHeroHeader extends StatelessWidget {
  final Color cardBg;
  final Color borderColor;
  final bool isDark;

  const _TermsHeroHeader({
    required this.cardBg,
    required this.borderColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.getPrimaryColor.withValues(
                      alpha: isDark ? 0.2 : 0.1,
                    ),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/icon/icon_only.png',
                height: 52,
                width: 52,
                cacheWidth: 104,
                cacheHeight: 104,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Welcome to Self Finance",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: isDark ? Colors.white : AppColors.getPrimaryTextColor,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Simple, secure, and offline personal loan manager.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.getLigthGreyColor,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;
  final Color cardBg;
  final Color borderColor;

  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
    required this.cardBg,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.getPrimaryColor.withValues(
                alpha: isDark ? 0.16 : 0.1,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppColors.getPrimaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color:
                        isDark ? Colors.white : AppColors.getPrimaryTextColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.getLigthGreyColor,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _SegmentButton({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.getPrimaryColor : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? (isDark ? Colors.white : AppColors.getPrimaryColor)
                  : AppColors.getLigthGreyColor,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? (isDark ? Colors.white : AppColors.getPrimaryTextColor)
                    : AppColors.getLigthGreyColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AgreementRow extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String title;
  final String subtitle;
  final String url;
  final bool isDark;

  const _AgreementRow({
    required this.value,
    required this.onChanged,
    required this.title,
    required this.subtitle,
    required this.url,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: AppColors.getPrimaryColor,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white
                              : AppColors.getPrimaryTextColor,
                        ),
                      ),
                      InkWell(
                        onTap: () => Utility.launchInBrowserView(url),
                        borderRadius: BorderRadius.circular(6),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Read",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.getPrimaryColor,
                                ),
                              ),
                              SizedBox(width: 3),
                              Icon(
                                Icons.open_in_new_rounded,
                                size: 12,
                                color: AppColors.getPrimaryColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.getLigthGreyColor,
                    ),
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
