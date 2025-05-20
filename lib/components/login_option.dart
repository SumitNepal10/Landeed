import 'package:flutter/material.dart';

class LoginOption extends StatelessWidget {
  final String path;
  const LoginOption({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Image(
      fit: BoxFit.cover,
      image: AssetImage(path),
    ));
  }
}
