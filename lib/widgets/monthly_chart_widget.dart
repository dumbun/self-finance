import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/providers/monthly_chart_provider.dart';

class MonthlyChartWidget extends ConsumerWidget {
  const MonthlyChartWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartStateAsync = ref.watch(monthlyChartProvider);
    final theme = Theme.of(context);

    return chartStateAsync.when(
      data: (state) {
        if (state.data.isEmpty || _isAllZero(state)) {
          return _EmptyState(theme: theme);
        }

        return _ChartContent(state: state, theme: theme);
      },
      loading: () => _LoadingState(theme: theme),
      error: (err, stack) => _ErrorState(theme: theme, error: err),
    );
  }

  bool _isAllZero(dynamic state) {
    for (final m in state.data) {
      if (m.disbursed != 0.0 || m.received != 0.0) return false;
    }
    return true;
  }
}

// Separate widget to prevent rebuilds
class _ChartContent extends StatelessWidget {
  final dynamic state;
  final ThemeData theme;
  static const double fontScale = 1.25;

  const _ChartContent({required this.state, required this.theme});

  @override
  Widget build(BuildContext context) {
    final safeMax = (state.maxValue <= 0) ? 1.0 : state.maxValue;
    final horizontalInterval = safeMax / 4.0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14.sp),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _ChartHeader(state: state, theme: theme, fontScale: fontScale),
          SizedBox(height: 10.sp),
          _ChartLegend(state: state, theme: theme, fontScale: fontScale),
          SizedBox(height: 12.sp),
          _BarChartWidget(
            state: state,
            theme: theme,
            safeMax: safeMax,
            horizontalInterval: horizontalInterval,
            fontScale: fontScale,
          ),
          SizedBox(height: 8.sp),
          Text(
            'Values shown in compact format.',
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: (10.sp * fontScale),
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartHeader extends StatelessWidget {
  final dynamic state;
  final ThemeData theme;
  final double fontScale;

  const _ChartHeader({
    required this.state,
    required this.theme,
    required this.fontScale,
  });

  @override
  Widget build(BuildContext context) {
    final netFlow = state.totalReceived - state.totalDisbursed;
    final isPositive = netFlow >= 0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.sp, vertical: 4.sp),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
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
              Text(
                Utility.doubleFormate(netFlow),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: (16.sp * fontScale),
                  color: isPositive
                      ? AppColors.getGreenColor
                      : AppColors.contentColorRed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  final dynamic state;
  final ThemeData theme;
  final double fontScale;

  const _ChartLegend({
    required this.state,
    required this.theme,
    required this.fontScale,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.sp),
      child: Wrap(
        runSpacing: 8.sp,
        spacing: 12.sp,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _LegendItemSmall(
            color: AppColors.contentColorRed,
            label: 'Disbursed',
            value: Utility.doubleFormate(state.totalDisbursed),
            fontScale: fontScale,
            theme: theme,
          ),
          _LegendItemSmall(
            color: AppColors.getGreenColor,
            label: 'Received',
            value: Utility.doubleFormate(state.totalReceived),
            fontScale: fontScale,
            theme: theme,
          ),
        ],
      ),
    );
  }
}

class _BarChartWidget extends StatelessWidget {
  final dynamic state;
  final ThemeData theme;
  final double safeMax;
  final double horizontalInterval;
  final double fontScale;

  const _BarChartWidget({
    required this.state,
    required this.theme,
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
        tooltipBorder: BorderSide(color: theme.dividerColor, width: 0.8),
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          final monthIndex = group.x.toInt();
          if (monthIndex < 0 || monthIndex >= state.data.length) return null;

          final monthData = state.data[monthIndex];
          final labels = ['Disbursed', 'Received'];
          final values = [monthData.disbursed, monthData.received];
          final rodColor = rod.color ?? theme.colorScheme.primary;

          return BarTooltipItem(
            '${labels[rodIndex]}\n',
            TextStyle(
              color: theme.colorScheme.onSurface,
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
          getTitlesWidget: (value, meta) {
            final idx = value.toInt();
            if (idx < 0 || idx >= state.data.length) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: EdgeInsets.only(top: 6.sp),
              child: Text(
                state.data[idx].month,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: (12.sp * fontScale),
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
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
          getTitlesWidget: (value, meta) {
            return Text(
              Utility.compactNumber(value),
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: (12.sp * fontScale),
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            );
          },
        ),
      ),
    );
  }

  FlGridData _buildGridData() {
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: horizontalInterval,
      getDrawingHorizontalLine: (v) => FlLine(
        color: theme.dividerColor.withValues(alpha: 0.18),
        strokeWidth: 1,
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    final red = AppColors.contentColorRed;
    final green = AppColors.getGreenColor;

    return List.generate(
      state.data.length,
      (index) {
        final m = state.data[index];
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
                color: theme.dividerColor.withValues(alpha: 0.06),
              ),
            ),
            BarChartRodData(
              toY: m.received,
              width: 14.sp,
              borderRadius: BorderRadius.vertical(top: Radius.circular(4.sp)),
              color: green.withValues(alpha: 0.85),
            ),
          ],
        );
      },
      growable: false, // Performance optimization
    );
  }
}

// Empty, Loading, and Error states as const widgets
class _EmptyState extends StatelessWidget {
  final ThemeData theme;
  static const double fontScale = 1.25;

  const _EmptyState({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.sp),
      padding: EdgeInsets.all(20.sp),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14.sp),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 12.sp),
          Icon(
            Icons.bar_chart,
            size: 56.sp,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
          ),
          SizedBox(height: 12.sp),
          Text(
            'No monthly data yet',
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: (18.sp * fontScale),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6.sp),
          Text(
            'We couldn\'t find any transactions to show. Add some transactions to see monthly stats.',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: (13.sp * fontScale),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.sp),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  final ThemeData theme;

  const _LoadingState({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14.sp),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final ThemeData theme;
  final Object error;
  static const double fontScale = 1.25;

  const _ErrorState({required this.theme, required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.sp),
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.sp),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: theme.colorScheme.error,
            size: (20.sp * fontScale),
          ),
          SizedBox(width: 12.sp),
          Expanded(
            child: Text(
              'Something went wrong while loading the chart.',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: (13.sp * fontScale),
              ),
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
  final String value;
  final double fontScale;
  final ThemeData theme;

  const _LegendItemSmall({
    required this.color,
    required this.label,
    required this.value,
    required this.fontScale,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 6.sp),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8.sp),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10.sp,
            height: 10.sp,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2.sp),
            ),
          ),
          SizedBox(width: 8.sp),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: (12.sp * fontScale),
                ),
              ),
              SizedBox(height: 2.sp),
              Text(
                value,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: (13.sp * fontScale),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
