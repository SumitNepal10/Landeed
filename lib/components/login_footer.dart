import 'package:flutter/material.dart';
import 'package:landeed/components/app_button.dart';
import 'package:landeed/components/gap.dart';
import 'package:landeed/components/or_divider.dart';
import 'package:landeed/constant/colors.dart';
import 'package:landeed/utils/route_name.dart';

class LoginFooter extends StatelessWidget {
  const LoginFooter({super.key});

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
        Gap(isWidth: false, isHeight: true, height: height * 0.02),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Dont't have an account?",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, RoutesName.signupScreen);
              },
              child: Text(
                " Register",
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        )
      ],
    );
  }
}
