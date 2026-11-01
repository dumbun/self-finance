import 'dart:core';
import 'dart:io';

import 'package:feedback/feedback.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:self_finance/backend/account_database_manager.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/core/sync/sync_engine.dart';
import 'package:self_finance/core/sync/sync_outbox_service.dart';
import 'package:self_finance/core/sync/sync_provider.dart';
import 'package:self_finance/core/auth/firebase_auth_service.dart';
import 'package:self_finance/core/utility/home_widget_service.dart';
import 'package:self_finance/core/utility/notification_service.dart';
import 'package:self_finance/core/utility/preferences_helper.dart';
import 'package:self_finance/providers/auth_provider.dart';
import 'package:self_finance/providers/database_provider.dart';
import 'package:self_finance/providers/user_provider.dart';
import 'package:self_finance/views/account_gate.dart';
import 'package:self_finance/widgets/dilogbox_widget.dart';
import 'package:signature/signature.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:self_finance/firebase_options.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class Utility {
  static Future<void> appInit() async {
    // Initialize Firebase during splash
    await _initFirebase();

    // Load .env if present
    try {
      await dotenv.load();
    } catch (_) {}
  }

  static bool get isFirebaseInitialized => Firebase.apps.isNotEmpty;

  /// Initializes Firebase using platform options if not already initialized.
  static Future<void> _initFirebase() async {
    if (Firebase.apps.isNotEmpty) return;
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('Firebase initialized successfully during splash.');
    } catch (e) {
      debugPrint('Firebase initialization failed during splash: $e');
    }
  }

  /// Initialises non-critical background services (high refresh rate and notifications)
  /// without blocking the startup frame pipeline.
  static Future<void> backgroundServicesInit() async {
    if (Platform.isAndroid) {
      try {
        await FlutterDisplayMode.setHighRefreshRate();
      } catch (_) {}
    }
    try {
      await NotificationService().initNotification();
    } catch (error) {
      debugPrint(error.toString());
    }
    try {
      await HomeWidgetService.start();
    } catch (_) {}
  }

  static Future<void> logout(BuildContext context, [WidgetRef? ref]) async {
    final int confirm = await AlertDilogs.alertDialogWithTwoAction(
      context,
      'Log out',
      'Sync all changes with the cloud and remove local data from this device?',
    );
    if (confirm != 1 || !context.mounted) return;

    final NavigatorState navigator =
        Navigator.of(context, rootNavigator: true);
    final String? userId =
        (Utility.isFirebaseInitialized
            ? fb.FirebaseAuth.instance.currentUser?.uid
            : null) ??
        AccountDatabaseManager.activeUserId ??
        BackEnd.activeAccountId;
    final ItDataDatabase? db = BackEnd.activeDatabase;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return const PopScope(
          canPop: false,
          child: AlertDialog.adaptive(
            content: Row(
              children: [
                CircularProgressIndicator.adaptive(),
                SizedBox(width: 16),
                Expanded(child: Text('Syncing changes and logging out...')),
              ],
            ),
          ),
        );
      },
    );

    try {
      // 1. Best-effort sync push — ensure pending mutations are queued and pushed
      if (userId != null && db != null && Utility.isFirebaseInitialized) {
        try {
          final needsBackfill = await SyncOutboxService.hasRecordsNeedingSync(
            db,
          );
          if (needsBackfill) {
            await SyncOutboxService.queueAllExistingRecords(db);
          }
        } catch (e) {
          debugPrint('Backfill check failed before logout: $e');
        }

        try {
          final Directory appDir = await getApplicationDocumentsDirectory();
          final SyncEngine engine = SyncEngine(
            db: db,
            userId: userId,
            appDirPath: appDir.path,
          );
          await engine.push();
          debugPrint('Logout push completed successfully.');
        } catch (e) {
          debugPrint('Logout push failed (continuing logout): $e');
        }
      }

      // 2. Delete all local database files, cached images, and sync preferences
      try {
        await AccountDatabaseManager.deleteAllLocalData(userId: userId);
      } catch (e) {
        debugPrint('Failed to delete local data: $e');
      }

      // 3. Sign out from Firebase Auth
      try {
        if (ref != null) {
          await ref.read(firebaseAuthServiceProvider).signOut();
        } else {
          await FirebaseAuthService().signOut();
        }
      } catch (e) {
        debugPrint('Sign-out failed: $e');
      }

      // 4. Clear user preferences (theme, biometrics, onboarding)
      try {
        await PreferencesHelper.resetAll();
      } catch (e) {
        debugPrint('Failed to reset preferences: $e');
      }

      // 5. Invalidate Riverpod providers to clear cached user/sync/database states
      if (ref != null) {
        try {
          ref.invalidate(userProvider);
          ref.invalidate(syncProvider);
          ref.invalidate(authStateProvider);
          ref.invalidate(currentUserProvider);
          ref.invalidate(isSignedInProvider);
          ref.invalidate(accountDatabaseProvider);
          ref.invalidate(itDataDatabaseProvider);
          ref.invalidate(userDatabaseProvider);
        } catch (e) {
          debugPrint('Error invalidating Riverpod providers: $e');
        }
      } else if (context.mounted) {
        try {
          final container = ProviderScope.containerOf(context, listen: false);
          container.invalidate(userProvider);
          container.invalidate(syncProvider);
          container.invalidate(authStateProvider);
          container.invalidate(currentUserProvider);
          container.invalidate(isSignedInProvider);
          container.invalidate(accountDatabaseProvider);
          container.invalidate(itDataDatabaseProvider);
          container.invalidate(userDatabaseProvider);
        } catch (_) {}
      }
    } finally {
      // 5. Navigate to the login gate, atomically removing all dialogs and routes
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AccountGate()),
        (route) => false,
      );
    }
  }

  static String formatDate({required DateTime date}) {
    try {
      return DateFormat("dd-MM-yyyy").format(date);
    } catch (e) {
      debugPrint("Error formatting date: $e");
      return "";
    }
  }

  /// Format numbers compactly for charts (e.g., 1000 -> 1K, 1000000 -> 1M)
  static String compactNumber(double value) {
    if (value >= 10000000) {
      return '${(value / 10000000).toStringAsFixed(1)}Cr';
    } else if (value >= 100000) {
      return '${(value / 100000).toStringAsFixed(1)}L';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }

  // send feedback email

  static void sendFeedbackEmail(BuildContext context) {
    BetterFeedback.of(context).show((feedback) async {
      // draft an email and send to developer
      final screenshotFilePath = await Utility.writeImageToStorage(
        feedback.screenshot,
      );

      final Email email = Email(
        body: feedback.text,
        subject: Constant.feedbackSubject,
        recipients: [Constant.applicationHandleEmail],
        attachmentPaths: [screenshotFilePath],
      );
      await FlutterEmailSender.send(email);
    });
  }

  // writefeedback image to the storage
  static Future<String> writeImageToStorage(
    Uint8List feedbackScreenshot,
  ) async {
    final Directory output = await getTemporaryDirectory();
    final String screenshotFilePath = '${output.path}/feedback.png';
    final File screenshotFile = File(screenshotFilePath);
    await screenshotFile.writeAsBytes(feedbackScreenshot);
    return screenshotFilePath;
  }

  // make call
  static void makeCall({required String phoneNumber}) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (!await launchUrl(launchUri)) {
      throw Exception('Could not launch $launchUri');
    }
  }

  // send sms
  static Future<bool> sendSms({
    required String phoneNumber,
    String? body,
  }) async {
    final String cleanNumber = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    final Uri launchUri;
    if (body != null && body.isNotEmpty) {
      launchUri = Uri(
        scheme: 'sms',
        path: cleanNumber,
        queryParameters: <String, String>{
          'body': body,
        },
      );
    } else {
      launchUri = Uri(scheme: 'sms', path: cleanNumber);
    }

    try {
      if (await canLaunchUrl(launchUri)) {
        return await launchUrl(launchUri);
      }
    } catch (e) {
      debugPrint('Could not launch SMS: $e');
    }
    return false;
  }

  // copy to clipboard with haptic feedback
  static Future<void> copyToClipboard({required String text}) async {
    await Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
  }

  static Future<void> launchInBrowserView(String url) async {
    final Uri toLaunch = Uri.parse(url);
    if (!await launchUrl(toLaunch, mode: LaunchMode.inAppBrowserView)) {
      throw Exception('Could not launch $url');
    }
  }

  static String numberFormate(int number) {
    return NumberFormat('#,##,##0').format(number);
  }

  static String doubleFormate(double number) {
    return NumberFormat('#,##,##0').format(number);
  }

  static Future<bool> isNumberPresent(String value) async {
    return await BackEnd.isCustomerNumberPresent(contactNumber: value);
  }

  static bool isValidPhoneNumber(String? value) {
    if (value == null) return false;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return false;
    final digits = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 7 || digits.length > 15) return false;
    return RegExp(r'^\+?[0-9\s\-().]{7,25}$').hasMatch(trimmed);
  }

  static double reduceDecimals(double value) {
    return double.parse(value.toStringAsFixed(2));
  }

  static double textToDouble(String value) {
    return double.parse(value);
  }

  static int textToInt(String value) {
    return int.parse(value);
  }

  static DateTime presentDate() {
    return DateTime.now();
  }

  static String? amountValidation({required String? value}) {
    if (value == null || value.isEmpty || value == "") {
      return 'Please enter a valid value';
    }
    if (value.contains(",") || value.contains(" ") || value.contains("-")) {
      return "please enter the correct value";
    } else {
      return null;
    }
  }

  static Future<String> saveSignaturesInStorage({
    required SignatureController signatureController,
    required String imageName,
  }) async {
    // [saveSignaturesInStorage] returns the path of the file in a future String
    // checks wether the signature pad is empty
    try {
      if (signatureController.isNotEmpty) {
        final Uint8List? bytes = await signatureController.toPngBytes(
          height: 300,
          width: 300,
        );
        if (bytes != null && signatureController.isNotEmpty) {
          final Directory applicationDocumentDirectory =
              await getApplicationDocumentsDirectory();
          final String path = applicationDocumentDirectory.path;
          // create directory on external storage
          await Directory('$path/Images/signatures').create(recursive: true);
          final String fullImageName =
              "signature_itemid_${imageName}_${DateTime.now().millisecondsSinceEpoch}_${const Uuid().v7().substring(0, 8)}.png";
          final String fullPath = '$path/Images/signatures/$fullImageName';
          final File file = File(fullPath);
          await file.writeAsBytes(bytes, flush: true);
          return p.join("Images", "signatures", fullImageName);
        }
      }
      return "";
    } catch (e) {
      debugPrint("Error saving signature: $e");
      rethrow;
    }
  }
}
