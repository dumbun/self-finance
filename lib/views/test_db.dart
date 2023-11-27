import 'package:flutter/material.dart';
import 'package:self_finance/backend/user_db.dart';
import 'package:self_finance/models/user_model.dart';

class TestDb extends StatefulWidget {
  const TestDb({super.key});

  @override
  State<TestDb> createState() => _TestDbState();
}

class _TestDbState extends State<TestDb> {
  @override
  Widget build(BuildContext context) {
    User? user;
    fetchData() async {
      final result = await UserBackEnd.fetchUserData();
      UserBackEnd.fetchUserPIN();
      setState(() {
        user = result!;
      });
      if (user != null) {
        // print(user?.id);
        // print(user?.userName);
        // print(user?.profilePicture);
        // print(user?.userPin);
      }
    }

    return Scaffold(
      body: Center(
        child: ElevatedButton(
            onPressed: () {
              fetchData();
            },
            child: const Text("Test")),
      ),
    );
  }
}
