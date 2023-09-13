import 'package:flutter/material.dart';
import 'package:self_finance/models/user_model.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key, required this.user});

  final User user;

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
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
          ],
        ),
      ),
    );
  }
}
