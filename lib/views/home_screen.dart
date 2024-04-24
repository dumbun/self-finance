import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/widgets/home_screen_graph_widget.dart';
import 'package:self_finance/widgets/latest_transactions_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20.0.sp,
        right: 20.sp,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HomeScreenGraphWidget(),
            SizedBox(height: 18.sp),
            const LatestTransactionsWidget(),
          ],
        ),
      ),
    );
  }
}
