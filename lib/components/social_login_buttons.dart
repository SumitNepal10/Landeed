import 'package:flutter/material.dart';
import 'package:partice_project/components/app_button.dart';
import 'package:partice_project/components/gap.dart';
import 'package:partice_project/components/or_divider.dart';

class SocialLoginButtons extends StatelessWidget {
  const SocialLoginButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 1;
    return Column(
      children: [
        Gap(isWidth: false, isHeight: true, height: height * 0.019),
        const OrDivider(),
        Gap(isWidth: false, isHeight: true, height: height * 0.015),
        Row(
          children: [
            AppButton(
              onPress: () {},
              iconBtn: true,
              child: const Center(
                child: Image(
                  width: 35,
                  height: 35,
                  fit: BoxFit.contain,
                  image: AssetImage("lib/assets/icons/google.png"),
                ),
              ),
            ),
            const Gap(isWidth: true, isHeight: false, width: 10),
            AppButton(
              onPress: () {},
              iconBtn: true,
              child: const Center(
                child: Image(
                  width: 35,
                  height: 35,
                  fit: BoxFit.contain,
                  image: AssetImage("lib/assets/icons/facebook.png"),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
} 