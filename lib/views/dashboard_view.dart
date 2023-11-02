import 'package:flutter/material.dart';
import 'package:self_finance/constants/routes.dart';
import 'package:self_finance/models/user_model.dart';
import 'package:self_finance/widgets/round_corner_button.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key, required this.user});

  final User user;

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Dashoard"),
            Text(widget.user.userName),
            Text(widget.user.userPin),
            Text(widget.user.profilePicture.toString()),
            RoundedCornerButton(
              text: "add new entry",
              onPressed: () => Routes.navigateToAddNewEntry(context: context),
            )
          ],
        ),
      ),
    );
  }
}
