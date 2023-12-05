import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/models/user_model.dart';
import 'package:self_finance/widgets/center_title_text_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({required this.user, super.key});
  final User user;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.all(20.0.sp),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CenterTitleTextWidget(
            user: user,
            showUserProfile: true,
          ),
        ],
      ),
    );
  }
}
