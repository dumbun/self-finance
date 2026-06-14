import 'package:flutter/material.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/utility/invite_link_utility.dart';
import 'package:self_finance/widgets/analatics_grid_widget.dart';
import 'package:self_finance/widgets/animated_dots_widget.dart';
import 'package:self_finance/widgets/app_icon_widget.dart';
import 'package:self_finance/widgets/invite_button_widget.dart';
import 'package:self_finance/widgets/monthly_chart_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<Widget> widgets = [
    MonthlyChartSection(),
    AnalaticsGridWidget(),
    SizedBox(height: 30),
    Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppIconWidget(height: 42, width: 42),
        SizedBox(width: 12),
        BodyOneDefaultText(text: "Self Finance", bold: true),
      ],
    ),
    SizedBox(height: 20),
    Center(child: BodyTwoDefaultText(text: "If you like our app please")),
    TextButton(
      onPressed: Invite.shareAppLink,
      child: BodyTwoDefaultText(text: "Invite your friends", bold: true),
    ),
    SizedBox(height: 40),
    AnimatedDotPattern(height: 120),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        MonthlyChartSection(),
        AnalaticsGridWidget(),
        SizedBox(height: 30),
        InviteButtonWidget(),
        SizedBox(height: 40),
        AnimatedDotPattern(height: 140),
      ],
    );
  }
}
