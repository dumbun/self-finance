import 'package:flutter/material.dart';
import 'package:self_finance/widgets/analatics_grid_widget.dart';
import 'package:self_finance/widgets/monthly_chart_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        children: <Widget>[MonthlyChartSection(), AnalaticsGridWidget()],
      ),
    );
  }
}
