import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/providers/customers_provider.dart';
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
          _buildHeaderWidget(),
          SizedBox(height: 20.sp),
          Consumer(
            builder: (context, ref, child) {
              return ref.watch(asyncCustomersProvider).when(
                  data: (data) {
                    print(jsonEncode(data));
                    return Text(data.length.toString());
                  },
                  error: (_, __) => Text("error"),
                  loading: () => CircularProgressIndicator());
            },
          ),
        ],
      ),
    );
  }

  Consumer _buildHeaderWidget() {
    return Consumer(
      builder: (context, ref, child) {
        return ref.watch(asyncUserProvider).when(
              data: (data) {
                return CenterTitleTextWidget(
                  user: data[0],
                  showUserProfile: true,
                );
              },
              error: (error, stackTrace) => const Text("Welcome"),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
            );
      },
    );
  }
}
