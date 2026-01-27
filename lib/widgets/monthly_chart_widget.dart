import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/core/fonts/body_small_text.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/models/chart_model.dart';
import 'package:self_finance/providers/monthly_chart_provider.dart';
import 'package:self_finance/widgets/currency_widget.dart';
import 'package:self_finance/widgets/title_widget.dart';

class MonthlyChartWidget extends ConsumerWidget {
  const MonthlyChartWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartStateAsync = ref.watch(monthlyChartProvider);

    return chartStateAsync.when(
      data: (MonthlyChartState state) {
        if (state.data.isEmpty || _isAllZero(state)) {
          return _EmptyState();
        }

        return _ChartContent(state: state);
      },
      loading: () => _LoadingState(),
      error: (Object err, StackTrace stack) => _ErrorState(error: err),
    );
  }

  bool _isAllZero(MonthlyChartState state) {
    for (final m in state.data) {
      if (m.disbursed != 0.0 || m.received != 0.0) return false;
    }
    return true;
  }
}

// Separate widget to prevent rebuilds
class _ChartContent extends StatelessWidget {
  final MonthlyChartState state;

  static const double fontScale = 1.25;

  const _ChartContent({required this.state});

  @override
  Widget build(BuildContext context) {
    final double safeMax = (state.maxValue <= 0) ? 1.0 : state.maxValue;
    final double horizontalInterval = safeMax / 4.0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
      padding: EdgeInsets.all(12.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _ChartHeader(state: state),
          SizedBox(height: 10.sp),
          _ChartLegend(state: state),
          SizedBox(height: 12.sp),
          _BarChartWidget(
            state: state,

            safeMax: safeMax,
            horizontalInterval: horizontalInterval,
            fontScale: fontScale,
          ),
          SizedBox(height: 8.sp),
          const BodySmallText(text: 'Values shown in compact format.'),
        ],
      ),
    );
  }
}

class _ChartHeader extends StatelessWidget {
  final MonthlyChartState state;

  const _ChartHeader({required this.state});

  @override
  Widget build(BuildContext context) {
    final double netFlow = state.totalReceived - state.totalDisbursed;
    final bool isPositive = netFlow >= 0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.sp, vertical: 4.sp),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const BodyOneDefaultText(text: 'Monthly Overview', bold: true),
                SizedBox(height: 4.sp),
                const BodyTwoDefaultText(text: 'Last 6 months performance'),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              const BodyTwoDefaultText(text: 'Net Flow'),
              SizedBox(height: 4.sp),
              CurrencyWidget(
                amount: Utility.doubleFormate(netFlow),
                color: isPositive
                    ? AppColors.getGreenColor
                    : AppColors.contentColorRed,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  final MonthlyChartState state;

  const _ChartLegend({required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.sp),
      child: Wrap(
        runSpacing: 8.sp,
        spacing: 12.sp,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          _LegendItemSmall(
            color: AppColors.contentColorRed,
            label: 'Disbursed',
            value: state.totalDisbursed,
          ),
          _LegendItemSmall(
            color: AppColors.getGreenColor,
            label: 'Received',
            value: state.totalReceived,
          ),
        ],
      ),
    );
  }
}

class _BarChartWidget extends StatelessWidget {
  final MonthlyChartState state;
  final double safeMax;
  final double horizontalInterval;
  final double fontScale;

  const _BarChartWidget({
    required this.state,
    required this.safeMax,
    required this.horizontalInterval,
    required this.fontScale,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Padding(
        padding: EdgeInsets.fromLTRB(6.sp, 0, 6.sp, 6.sp),
        child: BarChart(
          BarChartData(
            maxY: safeMax * 1.2,
            minY: 0,
            alignment: BarChartAlignment.spaceBetween,
            groupsSpace: 12.sp,
            barTouchData: _buildBarTouchData(),
            titlesData: _buildTitlesData(),
            gridData: _buildGridData(),
            borderData: FlBorderData(show: false),
            barGroups: _buildBarGroups(),
          ),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOut,
        ),
      ),
    );
  }

  BarTouchData _buildBarTouchData() {
    return BarTouchData(
      enabled: true,
      touchTooltipData: BarTouchTooltipData(
        tooltipPadding: EdgeInsets.all(8.sp),
        tooltipBorder: BorderSide(width: 0.8.sp),
        getTooltipItem:
            (
              BarChartGroupData group,
              int groupIndex,
              BarChartRodData rod,
              int rodIndex,
            ) {
              final int monthIndex = group.x.toInt();
              if (monthIndex < 0 || monthIndex >= state.data.length) {
                return null;
              }

              final ChartData monthData = state.data[monthIndex];
              final List<String> labels = ['Disbursed', 'Received'];
              final List<double> values = [
                monthData.disbursed,
                monthData.received,
              ];
              final Color rodColor = rod.color ?? AppColors.borderColor;

              return BarTooltipItem(
                '${labels[rodIndex]}\n',
                TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: (12.sp * fontScale),
                ),
                children: [
                  TextSpan(
                    text: Utility.doubleFormate(values[rodIndex]),
                    style: TextStyle(
                      color: rodColor,
                      fontWeight: FontWeight.bold,
                      fontSize: (14.sp * fontScale),
                    ),
                  ),
                ],
              );
            },
      ),
    );
  }

  FlTitlesData _buildTitlesData() {
    return FlTitlesData(
      show: true,
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30.sp,
          getTitlesWidget: (double value, TitleMeta meta) {
            final int idx = value.toInt();
            if (idx < 0 || idx >= state.data.length) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: EdgeInsets.only(top: 6.sp),
              child: BodyTwoDefaultText(
                text: state.data[idx].month,
                bold: true,
              ),
            );
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 36.sp,
          interval: horizontalInterval,
          getTitlesWidget: (double value, TitleMeta meta) {
            return BodySmallText(text: Utility.compactNumber(value));
          },
        ),
      ),
    );
  }

  FlGridData _buildGridData() {
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      drawHorizontalLine: true,
      horizontalInterval: horizontalInterval,
      getDrawingHorizontalLine: (double v) => FlLine(
        color: AppColors.getLigthGreyColor.withValues(alpha: 0.18),
        strokeWidth: 1,
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    final Color red = AppColors.contentColorRed;
    final Color green = AppColors.getGreenColor;

    return List.generate(state.data.length, (int index) {
      final ChartData m = state.data[index];
      return BarChartGroupData(
        x: index,
        barsSpace: 8.sp,
        barRods: [
          BarChartRodData(
            toY: m.disbursed,
            width: 14.sp,
            borderRadius: BorderRadius.vertical(top: Radius.circular(4.sp)),
            color: red.withValues(alpha: 0.85),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: safeMax * 1.2,
              color: AppColors.getLigthGreyColor.withValues(alpha: 0.06),
            ),
          ),
          BarChartRodData(
            toY: m.received,
            width: 14.sp,
            borderRadius: BorderRadius.vertical(top: Radius.circular(4.sp)),
            color: green.withValues(alpha: 0.85),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: safeMax * 1.2,
              color: AppColors.getLigthGreyColor.withValues(alpha: 0.06),
            ),
          ),
        ],
      );
    });
  }
}

// Empty, Loading, and Error states as const widgets
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.sp),
      padding: EdgeInsets.all(20.sp),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(height: 12.sp),
          Icon(
            Icons.bar_chart,
            size: 56.sp,
            color: AppColors.getLigthGreyColor,
          ),
          SizedBox(height: 12.sp),
          const TitleWidget(text: 'No monthly data yet', bold: true),
          SizedBox(height: 6.sp),
          const BodyTwoDefaultText(
            text:
                'We couldn\'t find any transactions to show. Add some transactions to see monthly stats.',
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.sp),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14.sp)),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final Object error;
  static const double fontScale = 1.25;

  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.sp),
      padding: EdgeInsets.all(12.sp),

      child: Row(
        children: [
          Icon(Icons.error_outline, size: (20.sp * fontScale)),
          SizedBox(width: 12.sp),
          Expanded(
            child: const BodyTwoDefaultText(
              text: 'Something went wrong while loading the chart.',
              error: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItemSmall extends StatelessWidget {
  final Color color;
  final String label;
  final double value;

  const _LegendItemSmall({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 6.sp),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16.sp,
            height: 16.sp,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2.sp),
            ),
          ),
          SizedBox(width: 10.sp),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              BodySmallText(text: label),
              SizedBox(height: 2.sp),
              CurrencyWidget(amount: Utility.doubleFormate(value)),
            ],
          ),
        ],
      ),
    );
  }
}
