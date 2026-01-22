import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/core/theme/app_colors.dart';

///[RefreshWidget] drop down refresh indicator to refresh
///[child] for the child widget
///[onRefresh] is a Future void Function() for doing future void function
class RefreshWidget extends StatelessWidget {
  const RefreshWidget({
    super.key,
    required this.onRefresh,
    required this.child,
  });
  final Future<void> Function() onRefresh;
  final Widget child;
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
