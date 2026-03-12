import 'package:in_app_review/in_app_review.dart';

class ReviewHelper {
  static final InAppReview _inAppReview = InAppReview.instance;

  // Use this for automatic popups (e.g., after a task is done)
  static Future<void> requestAppReview() async {
    if (await _inAppReview.isAvailable()) {
      await _inAppReview.requestReview();
    }
  }

  // Use this for "Rate Us" buttons in your Settings menu
  static Future<void> openStore() async {
    // Replace with your actual Apple App ID
    await _inAppReview.openStoreListing(appStoreId: '1234567890');
    //! need to change it after app published on app store
  }
}
