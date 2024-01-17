import 'package:flutter/material.dart';

class AlertDilogs {
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
