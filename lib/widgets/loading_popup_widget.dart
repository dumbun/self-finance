import 'package:flutter/material.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';

class LoadingPopup {
  static bool _isShowing = false;

  static void show(BuildContext context, {String? message}) {
    if (_isShowing) return;
    _isShowing = true;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => PopScope(
        canPop: false, // blocks back button
        child: Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 48),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator.adaptive(strokeWidth: 2.5),
                ),
                const SizedBox(width: 14),
                Flexible(
                  child: BodyTwoDefaultText(
                    text: message ?? 'Please wait...',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void hide(BuildContext context) {
    if (!_isShowing) return;
    _isShowing = false;
    Navigator.of(context, rootNavigator: true).pop();
  }
}

/// Wrap any async call with a loading popup.
/// Automatically hides even if the Future throws.
Future<T> runWithLoading<T>(
  BuildContext context,
  Future<T> Function() action, {
  String? message,
}) async {
  LoadingPopup.show(context, message: message);
  try {
    return await action();
  } finally {
    if (context.mounted) {
      LoadingPopup.hide(context);
    }
  }
}
