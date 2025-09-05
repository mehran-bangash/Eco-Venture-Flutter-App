import 'package:flutter/material.dart';

class BottomNavParent extends StatefulWidget {
  const BottomNavParent({super.key});

  @override
  State<BottomNavParent> createState() => _BottomNavParentState();
}

class _BottomNavParentState extends State<BottomNavParent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Coming soon"),
      ),
    );
  }
}
