import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/localization/localization_extension.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/providers/app_lock_setup_provider.dart';
import 'package:self_finance/widgets/currency_type_input_widget.dart';
import 'package:self_finance/widgets/input_text_field.dart';
import 'package:self_finance/widgets/pin_input_widget.dart';
import 'package:self_finance/widgets/round_corner_button.dart';
import 'package:self_finance/widgets/snack_bar_widget.dart';

/// Streamlined setup screen shown immediately after login for any user
/// who has not yet configured their local App Lock (PIN) and Currency.
///
/// Follows MVVM architecture: this View only contains presentation logic,
/// while state and business validations are handled by [appLockSetupProvider].
class AppLockSetupView extends ConsumerStatefulWidget {
  const AppLockSetupView({super.key});

  @override
  ConsumerState<AppLockSetupView> createState() => _AppLockSetupViewState();
}

class _AppLockSetupViewState extends ConsumerState<AppLockSetupView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _currencyController;
  final TextEditingController _pinController1 = TextEditingController();
  final TextEditingController _pinController2 = TextEditingController();

  @override
  void initState() {
    super.initState();
    final initialState = ref.read(appLockSetupProvider);
    _nameController = TextEditingController(text: initialState.initialName);
    _currencyController = TextEditingController(
      text: initialState.defaultCurrency,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currencyController.dispose();
    _pinController1.dispose();
    _pinController2.dispose();
    super.dispose();
  }

  void _onSetupSubmitted() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    ref
        .read(appLockSetupProvider.notifier)
        .completeSetup(
          name: _nameController.text,
          currency: _currencyController.text,
          pin: _pinController1.text,
          confirmPin: _pinController2.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    // Listen to state changes to handle navigation and snackbars
    ref.listen<AppLockSetupState>(appLockSetupProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        SnackBarWidget.snackBarWidget(
          context: context,
          message: next.errorMessage!,
        );
      }

      if (next.isSuccess && !(previous?.isSuccess ?? false)) {
        Routes.navigateToDashboard(context: context);
        SnackBarWidget.snackBarWidget(
          context: context,
          message: context.l10n.appLockConfiguredSuccessfully,
        );
      }

      if (_nameController.text.isEmpty && next.initialName.isNotEmpty) {
        _nameController.text = next.initialName;
      }
    });

    final setupState = ref.watch(appLockSetupProvider);
    final bool isLoading = setupState.isLoading;

    return Scaffold(
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
                        color: AppColors.getPrimaryColor.withValues(
                          alpha: 0.12,
                        ),
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
                  Center(
                    child: BodyOneDefaultText(
                      text: context.l10n.setAppLockAndCurrency,
                      bold: true,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: BodyTwoDefaultText(
                      text: context.l10n.appLockSetupSubtitle,
                      color: AppColors.getLigthGreyColor,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Name Input Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BodyTwoDefaultText(
                            text: context.l10n.yourNameOptional,
                            bold: true,
                          ),
                          const SizedBox(height: 10),
                          InputTextField(
                            controller: _nameController,
                            hintText: context.l10n.pleaseEnterTheName,
                            keyboardType: TextInputType.name,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Currency Selection Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BodyTwoDefaultText(
                            text: context.l10n.primaryCurrency,
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
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BodyTwoDefaultText(
                            text: context.l10n.createAppLockPin,
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
                          BodyTwoDefaultText(
                            text: context.l10n.confirmPin,
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
                                  return context.l10n.pinsDoNotMatch;
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
                    onPressed: isLoading ? null : _onSetupSubmitted,
                    text: isLoading
                        ? context.l10n.loading
                        : context.l10n.finishSetupGoToDashboard,
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
