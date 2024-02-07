import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/theme/colors.dart';

class RefreshWidget extends StatelessWidget {
  const RefreshWidget({required this.child, required this.onRefresh, super.key});
  final Widget child;
  final Future<void> Function() onRefresh;
  @override
  Widget build(BuildContext context) {
    return LiquidPullToRefresh(
      color: AppColors.getLigthGreyColor,
      showChildOpacityTransition: false,
      springAnimationDurationInMilliseconds: 1000,
      height: 40.sp,
      animSpeedFactor: 8.0,
      onRefresh: onRefresh,
      child: child,
    );
  }
}
