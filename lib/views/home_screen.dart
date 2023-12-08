import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/providers/user_backend_provider.dart';
import 'package:self_finance/widgets/center_title_text_widget.dart';
import 'package:self_finance/widgets/title_widget.dart';

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
          _buildTitle(),
        ],
      ),
    );
  }

  Consumer _buildTitle() {
    return Consumer(
      builder: (context, ref, child) {
        return ref.watch(userDataProvider).when(
              data: (data) {
                return Column(
                  children: <Widget>[
                    CenterTitleTextWidget(
                      user: data[0],
                      showUserProfile: true,
                    ),
                  ],
                );
              },
              error: (_, __) {
                return const Center(child: TitleWidget(text: "Welcome"));
              },
              loading: () => const CircularProgressIndicator(),
            );
      },
    );
  }
}
