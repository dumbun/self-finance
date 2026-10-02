import 'package:local_auth/local_auth.dart';
import 'package:self_finance/core/constants/constants.dart';

class LocalAuthenticator {
  static final LocalAuthentication _auth = LocalAuthentication();

  static Future<bool> authenticate() async {
    try {
      final bool canCheckBiometrics = await _auth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        // Biometrics is not available on this device
        return false;
      }

      final List<BiometricType> availableBiometrics =
          await _auth.getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        // No biometrics are available on this device
        return false;
      }

      final bool isAuthenticated = await _auth.authenticate(
        localizedReason: Constant.localizedReason, // Displayed to the user
      );

      return isAuthenticated;
    } catch (e) {
      // Handle exceptions
      return false;
    }
  }
}
