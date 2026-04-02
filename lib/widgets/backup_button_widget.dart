import 'package:flutter/material.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/widgets/backup_with_progress_widget.dart';

class BackupButtonWidget extends StatelessWidget {
  const BackupButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    Future<void> doBackUp() async {
      return await showAdaptiveDialog<void>(
        barrierDismissible: false,
        useRootNavigator: true,
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton.filled(
                  style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                      AppColors.borderColor,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.getErrorColor),
                ),
                const BackupWithProgressWidget(),
              ],
            ),
          );
        },
      );
    }

    return Card(
      child: ListTile(
        title: const BodyOneDefaultText(text: "Backup", bold: true),
        trailing: const Icon(
          Icons.backup_rounded,
          color: AppColors.contentColorBlue,
        ),
        onTap: doBackUp,
      ),
    );
  }
}
