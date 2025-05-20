import 'package:flutter/material.dart';

class AppPadding extends StatelessWidget {
  final double padddingValue;
  final Widget child;
  const AppPadding({super.key, required this.padddingValue, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padddingValue),
      child: child,
    );
  }
}
