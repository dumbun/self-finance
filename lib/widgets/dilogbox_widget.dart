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
          TextButton(
            onPressed: () {
              value = 1;
              Navigator.of(context).pop(context);
            },
            child: const BodyOneDefaultText(
              text: "Yes",
              color: AppColors.getGreenColor,
            ),
          ),
          TextButton(
            onPressed: () {
              value = 2;
              Navigator.of(context).pop(context);
            },
            child: const BodyOneDefaultText(
              text: "No",
              color: AppColors.getErrorColor,
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
        title: BodyOneDefaultText(text: title),
        content: BodyOneDefaultText(text: content),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'OK'),
            child: const BodyOneDefaultText(text: 'OK'),
          ),
        ],
      ),
    );
  }
}
