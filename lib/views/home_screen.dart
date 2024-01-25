import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/models/user_model.dart';
import 'package:self_finance/providers/user_provider.dart';
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
          _buildHeaderWidget(ref),
        ],
      ),
    );
  }

  Widget _buildHeaderWidget(WidgetRef ref) {
    return ref.watch(asyncUserProvider).when(
          data: (List<User> data) {
            return Center(
              child: TitleWidget(
                text: data.first.userName,
              ),
            );
          },
          error: (error, stackTrace) => const Text("Welcome"),
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
        );
  }
}
