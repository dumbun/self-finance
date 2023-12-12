import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/providers/p.dart';
import 'package:self_finance/providers/user_backend_provider.dart';
import 'package:self_finance/widgets/center_title_text_widget.dart';
import 'package:self_finance/widgets/round_corner_button.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(up);
    final test = ref.watch(backendProvider.notifier);
    return Padding(
      padding: EdgeInsets.all(20.0.sp),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CenterTitleTextWidget(
            user: user,
            showUserProfile: true,
          ),
          RoundedCornerButton(
              text: "test",
              onPressed: () {
                test.printf();
              })
        ],
      ),
    );
  }
}
