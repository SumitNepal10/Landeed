import 'package:flutter/material.dart';
import 'package:landeed/components/app_button.dart';
import 'package:landeed/components/app_padding.dart';
import 'package:landeed/constant/colors.dart';
import 'package:landeed/utils/route_name.dart';

class Screen extends StatelessWidget {
  final Widget child;
  final bool isBackButton, isActions, isBottomTab;
  final List<Widget>? appBarActions;
  const Screen(
      {super.key,
      this.isActions = false,
      this.isBottomTab = false,
      this.appBarActions,
      required this.child,
      required this.isBackButton});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isBackButton
          ? AppBar(
              elevation: 0,
              actions: appBarActions ?? (isActions
                  ? [
                      AppButton(
                        onPress: () {
                          Navigator.pushNamed(
                              context, RoutesName.userAccountScreen);
                        },
                        title: "Next",
                        width: 100,
                        isMarginLeft: true,
                        bgColor: AppColors.primaryColor,
                        textColor: AppColors.whiteColor,
                      )
                    ]
                  : null),
            )
          : null,
      body: SafeArea(
        child: AppPadding(
            padddingValue: 15,
            child: SingleChildScrollView(
              child: child,
            )),
      ),
    );
  }
}
