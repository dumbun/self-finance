import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/theme/app_colors.dart';
import 'package:self_finance/widgets/indicators_widget.dart';

class TwoSlicePieChartWidget extends StatefulWidget {
  const TwoSlicePieChartWidget({
    super.key,
    required this.firstIndicatorText,
    required this.secoundIndicatorText,
    required this.firstIndicatorValue,
    required this.secoundIndicatorValue,
    this.showPercentage = true,
  });

  final String firstIndicatorText;
  final String secoundIndicatorText;
  final double firstIndicatorValue;
  final double secoundIndicatorValue;
  final bool? showPercentage;

  @override
  State<TwoSlicePieChartWidget> createState() => _TwoSlicePieChartWidgetState();
}

class _TwoSlicePieChartWidgetState extends State<TwoSlicePieChartWidget> {
  int touchedIndex = -1;
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: Row(
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(
                    show: true,
                  ),
                  sectionsSpace: 5.sp,
                  centerSpaceRadius: 25.sp,
                  sections: showingSections(),
                ),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Indicator(
                color: AppColors.getPrimaryColor,
                text: widget.firstIndicatorText,
                isSquare: true,
              ),
              SizedBox(height: 4.sp),
              Indicator(
                color: AppColors.getLigthGreyColor,
                text: widget.secoundIndicatorText,
                isSquare: true,
              ),
              SizedBox(height: 6.sp),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(2, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 16.0.sp : 14.0.sp;
      final radius = isTouched ? 30.0.sp : 28.0.sp;
      // const shadows = [Shadow(color: Colors.black, blurRadius: 2.0)];
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: AppColors.getPrimaryColor,
            value: widget.firstIndicatorValue,
            title: widget.showPercentage! ? '${widget.firstIndicatorValue}%' : "",
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.getBackgroundColor,
              // shadows: shadows,
            ),
          );
        case 1:
          return PieChartSectionData(
            color: AppColors.getLigthGreyColor,
            value: widget.secoundIndicatorValue,
            title: widget.showPercentage! ? '${widget.secoundIndicatorValue}%' : "",
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.getPrimaryTextColor,
              // shadows: shadows,
            ),
          );

        default:
          throw Error();
      }
    });
  }
}
