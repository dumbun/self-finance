import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/backend/user_database.dart';
import 'package:self_finance/models/user_model.dart';
import 'package:self_finance/providers/auth_provider.dart';
import 'package:self_finance/providers/user_provider.dart';

/// State representation for the user PIN creation and setup view.
class AppLockSetupState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final String initialName;
  final String defaultCurrency;

  const AppLockSetupState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.initialName = '',
    this.defaultCurrency = '₹',
  });

  AppLockSetupState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    bool clearError = false,
    String? initialName,
    String? defaultCurrency,
  }) {
    return AppLockSetupState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      initialName: initialName ?? this.initialName,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppLockSetupState &&
          runtimeType == other.runtimeType &&
          isLoading == other.isLoading &&
          isSuccess == other.isSuccess &&
          errorMessage == other.errorMessage &&
          initialName == other.initialName &&
          defaultCurrency == other.defaultCurrency;

  @override
  int get hashCode => Object.hash(
        isLoading,
        isSuccess,
        errorMessage,
        initialName,
        defaultCurrency,
      );
}

/// Notifier encapsulating all business logic for App Lock & Currency setup.
class AppLockSetupNotifier extends Notifier<AppLockSetupState> {
  @override
  AppLockSetupState build() {
    final user = ref.watch(currentUserProvider);
    final metadata = user?.userMetadata;
    final fullName = metadata?['full_name'] ?? metadata?['name'];

    String suggestedName = '';
    if (fullName is String && fullName.trim().isNotEmpty) {
      suggestedName = fullName.trim();
    } else if (user?.email != null && user!.email!.isNotEmpty) {
      suggestedName = user.email!.split('@').first;
    }

    return AppLockSetupState(
      initialName: suggestedName,
    );
  }

  /// Validates inputs, creates the local user profile, and invalidates user state.
  Future<bool> completeSetup({
    required String name,
    required String currency,
    required String pin,
    required String confirmPin,
  }) async {
    if (state.isLoading) return false;

    final trimmedPin = pin.trim();
    final trimmedConfirmPin = confirmPin.trim();

    if (trimmedPin.length != 4) {
      state = state.copyWith(
        errorMessage: 'Please enter a 4-digit PIN',
      );
      return false;
    }

    if (trimmedPin != trimmedConfirmPin) {
      state = state.copyWith(
        errorMessage: 'PINs do not match. Please verify.',
      );
      return false;
    }

    final sanitizedCurrency =
        currency.trim().isEmpty ? '₹' : currency.trim();
    final sanitizedName = name.trim().isEmpty ? 'User' : name.trim();

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final success = await UserBackEnd.createNewUser(
        User(
          userName: sanitizedName,
          userPin: trimmedPin,
          profilePicture: '',
          userCurrency: sanitizedCurrency,
        ),
      );

      if (success) {
        ref.invalidate(userProvider);
        state = state.copyWith(isLoading: false, isSuccess: true);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to save setup. Please try again.',
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error creating user profile in completeSetup: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error saving setup: $e',
      );
      return false;
    }
  }

  /// Clears any visible error message.
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final appLockSetupProvider =
    NotifierProvider.autoDispose<AppLockSetupNotifier, AppLockSetupState>(
  AppLockSetupNotifier.new,
);
