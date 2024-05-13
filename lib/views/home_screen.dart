import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/widgets/ads_banner_widget.dart';
import 'package:self_finance/widgets/home_screen_graph_widget.dart';
import 'package:self_finance/widgets/latest_transactions_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20.0.sp,
          right: 20.sp,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AdsBannerWidget(),
            const HomeScreenGraphWidget(),
            SizedBox(height: 22.sp),
            const LatestTransactionsWidget(),
          ],
        ),
      ),
    );
  }
}
