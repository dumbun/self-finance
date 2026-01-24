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

    const double fontScale = 1.25;

    return chartStateAsync.when(
      data: (state) {
        if (state.data.isEmpty || _isAllZero(state)) {
          return _buildEmptyState(theme, fontScale);
        }

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
                color: theme.shadowColor.withAlpha(_alpha(0.06)),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme, state, fontScale),
              SizedBox(height: 10.sp),
              _buildLegend(theme, state, fontScale),
              SizedBox(height: 12.sp),
              _buildBarChart(
                theme,
                state,
                safeMax,
                horizontalInterval,
                fontScale,
              ),
              SizedBox(height: 8.sp),
              Text(
                'Values shown in compact format.',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: (10.sp * fontScale),
                  color: theme.colorScheme.onSurface.withAlpha(_alpha(0.6)),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => _buildLoading(theme, fontScale),
      error: (err, stack) => _buildError(theme, err, fontScale),
    );
  }

  Widget _buildHeader(ThemeData theme, dynamic state, double fontScale) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.sp, vertical: 4.sp),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BodyOneDefaultText(text: 'Monthly Overview', bold: true),
                SizedBox(height: 4.sp),
                BodyTwoDefaultText(text: 'Last 6 months performance'),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              BodyTwoDefaultText(text: 'Net Flow'),
              SizedBox(height: 4.sp),
              Text(
                Utility.doubleFormate(
                  state.totalReceived - state.totalDisbursed,
                ),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: (16.sp * fontScale),
                  color: (state.totalReceived - state.totalDisbursed) >= 0
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

  Widget _buildLegend(ThemeData theme, dynamic state, double fontScale) {
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
          ),
          _LegendItemSmall(
            color: AppColors.getGreenColor,
            label: 'Received',
            value: Utility.doubleFormate(state.totalReceived),
            fontScale: fontScale,
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(
    ThemeData theme,
    dynamic state,
    double safeMax,
    double horizontalInterval,
    double fontScale,
  ) {
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
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                tooltipPadding: EdgeInsets.all(8.sp),
                tooltipBorder: BorderSide(
                  color: theme.dividerColor,
                  width: 0.8,
                ),
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final monthIndex = group.x.toInt();
                  if (monthIndex < 0 || monthIndex >= state.data.length) {
                    return null;
                  }

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
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30.sp,
                  getTitlesWidget: (value, meta) {
                    final idx = value.toInt();
                    if (idx >= 0 && idx < state.data.length) {
                      final month = state.data[idx].month ?? '';
                      return Padding(
                        padding: EdgeInsets.only(top: 6.sp),
                        child: Text(
                          month,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: (12.sp * fontScale),
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface.withAlpha(
                              _alpha(0.8),
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
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
                        color: theme.colorScheme.onSurface.withAlpha(
                          _alpha(0.7),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: horizontalInterval,
              getDrawingHorizontalLine: (v) => FlLine(
                color: theme.dividerColor.withAlpha(_alpha(0.18)),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: List.generate(state.data.length, (index) {
              final m = state.data[index];

              final red = AppColors.contentColorRed;
              final green = AppColors.getGreenColor;

              return BarChartGroupData(
                x: index,
                barsSpace: 8.sp,
                barRods: [
                  BarChartRodData(
                    toY: m.disbursed,
                    width: 14.sp,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(4.sp),
                    ),
                    color: _withAlpha(red, 0.85),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: safeMax * 1.2,
                      color: theme.dividerColor.withOpacity(0.06),
                    ),
                  ),
                  BarChartRodData(
                    toY: m.received,
                    width: 14.sp,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(4.sp),
                    ),
                    color: _withAlpha(green, 0.85),
                  ),
                ],
              );
            }),
          ),
          duration: const Duration(milliseconds: 700),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, double fontScale) {
    return Container(
      margin: EdgeInsets.all(16.sp),
      padding: EdgeInsets.all(20.sp),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14.sp),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withAlpha(_alpha(0.04)),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(height: 12.sp),
          Icon(
            Icons.bar_chart,
            size: 56.sp,
            color: theme.colorScheme.onSurface.withAlpha(_alpha(0.25)),
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

  Widget _buildLoading(ThemeData theme, double fontScale) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14.sp),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withAlpha(_alpha(0.06)),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildError(ThemeData theme, Object error, double fontScale) {
    return Container(
      margin: EdgeInsets.all(16.sp),
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.sp),
        border: Border.all(color: theme.colorScheme.error.withOpacity(0.08)),
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

  int _alpha(double opacity) => (opacity * 255).round();

  Color _withAlpha(Color c, double opacity) =>
      c.withAlpha((opacity * 255).round());

  bool _isAllZero(dynamic state) {
    try {
      for (final m in state.data) {
        final d = (m.disbursed ?? 0.0) as double;
        final r = (m.received ?? 0.0) as double;
        if (d != 0.0 || r != 0.0) return false;
      }
    } catch (_) {
      return true;
    }
    return true;
  }
}

class _LegendItemSmall extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  final double fontScale;

  const _LegendItemSmall({
    required this.color,
    required this.label,
    required this.value,
    this.fontScale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 6.sp),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(8.sp),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.02 * 255).round()),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
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
        ),
      ],
    );
  }
}
