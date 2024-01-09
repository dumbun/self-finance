import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/providers/user_provider.dart';
import 'package:self_finance/widgets/center_title_text_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.all(20.0.sp),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderWidget(ref),
        ],
      ),
    );
  }

  Widget _buildHeaderWidget(WidgetRef ref) {
    return ref.watch(asyncUserProvider).when(
          data: (data) {
            return CenterTitleTextWidget(
              user: data.first,
              showUserProfile: true,
            );
          },
          error: (error, stackTrace) => const Text("Welcome"),
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
        );
  }
}
