import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:self_finance/backend/user_database.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/models/user_model.dart';
import 'package:self_finance/providers/user_provider.dart';
import 'package:self_finance/widgets/currency_type_input_widget.dart';
import 'package:self_finance/widgets/input_text_field.dart';
import 'package:self_finance/widgets/pin_input_widget.dart';
import 'package:self_finance/widgets/round_corner_button.dart';
import 'package:self_finance/widgets/snack_bar_widget.dart';

/// Streamlined setup screen shown immediately after login for any user
/// who has not yet configured their local App Lock (PIN) and Currency.
class AppLockSetupView extends ConsumerStatefulWidget {
  const AppLockSetupView({super.key});

  @override
  ConsumerState<AppLockSetupView> createState() => _AppLockSetupViewState();
}

class _AppLockSetupViewState extends ConsumerState<AppLockSetupView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _currencyController = TextEditingController();
  final TextEditingController _pinController1 = TextEditingController();
  final TextEditingController _pinController2 = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Default currency to Rupee
    _currencyController.text = '₹';

    // Pre-populate name from Supabase user profile if available
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      final metadata = currentUser?.userMetadata;
      final fullName = metadata?['full_name'] ?? metadata?['name'];
      if (fullName is String && fullName.trim().isNotEmpty) {
        _nameController.text = fullName.trim();
      } else if (currentUser?.email != null) {
        _nameController.text = currentUser!.email!.split('@').first;
      }
    } catch (_) {
      // In offline / uninitialized state
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currencyController.dispose();
    _pinController1.dispose();
    _pinController2.dispose();
    super.dispose();
  }

  Future<void> _handleCompleteSetup() async {
    if (_isLoading) return;

    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    final pin1 = _pinController1.text.trim();
    final pin2 = _pinController2.text.trim();

    if (pin1.length != 4) {
      SnackBarWidget.snackBarWidget(
        context: context,
        message: 'Please enter a 4-digit PIN',
      );
      return;
    }

    if (pin1 != pin2) {
      SnackBarWidget.snackBarWidget(
        context: context,
        message: 'PINs do not match. Please verify.',
      );
      return;
    }

    final currency = _currencyController.text.trim().isEmpty
        ? '₹'
        : _currencyController.text.trim();
    final name = _nameController.text.trim().isEmpty
        ? 'User'
        : _nameController.text.trim();

    setState(() => _isLoading = true);

    try {
      final success = await UserBackEnd.createNewUser(
        User(
          userName: name,
          userPin: pin1,
          profilePicture: '',
          userCurrency: currency,
        ),
      );

      if (success) {
        ref.invalidate(userProvider);
        if (mounted) {
          Routes.navigateToDashboard(context: context);
          SnackBarWidget.snackBarWidget(
            context: context,
            message: 'App lock and currency configured successfully!',
          );
        }
      } else {
        if (mounted) {
          SnackBarWidget.snackBarWidget(
            context: context,
            message: 'Failed to save setup. Please try again.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBarWidget.snackBarWidget(
          context: context,
          message: 'Error saving setup: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final Color cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icon Header
                  Center(
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: AppColors.getPrimaryColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_person_rounded,
                        size: 40,
                        color: AppColors.getPrimaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title & Subtitle
                  const Center(
                    child: BodyOneDefaultText(
                      text: 'Set App Lock & Currency',
                      bold: true,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: BodyTwoDefaultText(
                      text:
                          'Create a 4-digit PIN to secure your records and select your preferred currency.',
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Name Input Card
                  Card(
                    color: cardBg,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const BodyTwoDefaultText(
                            text: 'Your Name (Optional)',
                            bold: true,
                          ),
                          const SizedBox(height: 10),
                          InputTextField(
                            controller: _nameController,
                            hintText: Constant.pleaseEnterTheName,
                            keyboardType: TextInputType.name,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Currency Selection Card
                  Card(
                    color: cardBg,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const BodyTwoDefaultText(
                            text: 'Primary Currency',
                            bold: true,
                          ),
                          const SizedBox(height: 10),
                          CurrencyTypeInputWidget(
                            controller: _currencyController,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // PIN Creation Card
                  Card(
                    color: cardBg,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const BodyTwoDefaultText(
                            text: 'Create 4-Digit App Lock PIN',
                            bold: true,
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: PinInputWidget(
                              pinController: _pinController1,
                              obscureText: true,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const BodyTwoDefaultText(
                            text: 'Confirm 4-Digit PIN',
                            bold: true,
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: PinInputWidget(
                              pinController: _pinController2,
                              obscureText: true,
                              validator: (val) {
                                if (_pinController1.text !=
                                    _pinController2.text) {
                                  return '* PINs do not match';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Action Button
                  RoundedCornerButton(
                    onPressed: _isLoading ? null : _handleCompleteSetup,
                    text: _isLoading ? 'Saving...' : 'Finish Setup & Go to Dashboard',
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
