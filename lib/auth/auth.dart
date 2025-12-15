import 'package:local_auth/local_auth.dart';
import 'package:self_finance/constants/constants.dart';

class LocalAuthenticator {
  static LocalAuthentication get _newMethod => LocalAuthentication();

  static Future<bool> authenticate() async {
    try {
      bool canCheckBiometrics = await _newMethod.canCheckBiometrics;
      if (!canCheckBiometrics) {
        // Biometrics is not available on this device
        return false;
      }

      List<BiometricType> availableBiometrics = await _newMethod
          .getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        // No biometrics are available on this device
        return false;
      }

      bool isAuthenticated = await _newMethod.authenticate(
        localizedReason: Constant.localizedReason, // Displayed to the user
        sensitiveTransaction: true,
      );

      return isAuthenticated;
    } catch (e) {
      // Handle exceptions
      return false;
    }
  }
}
