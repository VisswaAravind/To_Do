import 'package:flutter/material.dart';
import '../Home_Page/task_page.dart';
import 'auth.dart';
import 'login_page.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return TaskPage();
        } else {
          return LoginPage();
        }
      },
    );
  }
}
