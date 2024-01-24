import 'package:flutter/material.dart';
import 'package:self_finance/fonts/body_text.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:self_finance/theme/colors.dart';

class AlertDilogs {
  static Future<int> alertDialogWithTwoAction(BuildContext context, String title, String content) async {
    int value = 0;
    await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog.adaptive(
        title: Text(title),
        content: BodyTwoDefaultText(text: content),
        actions: [
          TextButton.icon(
            onPressed: () {
              value = 1;
              Navigator.of(context).pop(context);
            },
            icon: const Icon(
              Icons.done,
              color: AppColors.getGreenColor,
            ),
            label: const BodyOneDefaultText(
              text: "Yes",
            ),
          ),
          TextButton.icon(
            onPressed: () {
              value = 2;
              Navigator.of(context).pop(context);
            },
            icon: const Icon(
              Icons.cancel_rounded,
              color: AppColors.getErrorColor,
            ),
            label: const BodyOneDefaultText(
              text: "No",
            ),
          ),
        ],
      ),
    );
    return value;
  }

  static alertDialogWithOneAction(BuildContext context, String title, String content) {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog.adaptive(
        title: Text(title),
        content: Text(content, style: const TextStyle(fontSize: 22)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'OK'),
            child: const Text(
              'OK',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
