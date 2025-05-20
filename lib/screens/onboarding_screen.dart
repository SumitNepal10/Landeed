import 'package:flutter/material.dart';
import 'package:landeed/components/onboard_view.dart';
import 'package:landeed/utils/route_name.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  var controller = PageController();
  bool isLastPage = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, RoutesName.loginScreen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: PageView(
            controller: controller,
            onPageChanged: (index) {
              setState(() {
                isLastPage = index == 2;
              });
            },
            children: [
              OnboardView(
                  controller: controller,
                  title: "Find best place\nto stay in good price ",
                  subtitle:
                      "Lorem ipsum dolor sit amet, consectetur\nadipiscing elit, sed.",
                  path: "lib/assets/1.png",
                  isLastPage: isLastPage,
                  onFinish: isLastPage ? _navigateToLogin : null),
              OnboardView(
                  controller: controller,
                  title: "Fast sell your property\nin just one click ",
                  subtitle:
                      "Lorem ipsum dolor sit amet, consectetur\nadipiscing elit, sed.",
                  path: "lib/assets/2.png",
                  isLastPage: isLastPage,
                  onFinish: isLastPage ? _navigateToLogin : null),
              OnboardView(
                  controller: controller,
                  title: "Find perfect choice for\nyour future house ",
                  subtitle:
                      "Lorem ipsum dolor sit amet, consectetur\nadipiscing elit, sed.",
                  path: "lib/assets/3.png",
                  isLastPage: isLastPage,
                  onFinish: isLastPage ? _navigateToLogin : null),
            ],
          ),
        ),
      ),
    );
  }
}
