import 'package:material_ui/material_ui.dart';
import 'package:self_finance/widgets/analatics_grid_widget.dart';
import 'package:self_finance/widgets/animated_dots_widget.dart';
import 'package:self_finance/widgets/invite_button_widget.dart';
import 'package:self_finance/widgets/monthly_chart_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<Widget> view = [
    MonthlyChartSection(),
    AnalaticsGridWidget(),
    SizedBox(height: 30),
    InviteButtonWidget(),
    SizedBox(height: 40),
    AnimatedDotPattern(height: 140),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: view.length,
      itemBuilder: (context, index) {
        return view[index];
      },
    );
  }
}
