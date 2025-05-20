import 'package:flutter/material.dart';
import 'package:landeed/components/app_button.dart';
import 'package:landeed/components/gap.dart';
import 'package:landeed/constant/colors.dart';
import 'package:landeed/utils/route_name.dart';
import 'package:pinput/pinput.dart';

class OtpCard extends StatefulWidget {
  final Function(String) onCompleted;
  final bool isLoading;
  final VoidCallback? onResend;

  const OtpCard({
    super.key,
    required this.onCompleted,
    this.isLoading = false,
    this.onResend,
  });

  @override
  State<OtpCard> createState() => _OtpCardState();
}

class _OtpCardState extends State<OtpCard> {
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const focusedBorderColor = AppColors.primaryColor;
    const fillColor = Color.fromRGBO(243, 246, 249, 0);
    const borderColor = AppColors.primaryColor;
    final height = MediaQuery.of(context).size.height * 1;
    final width = MediaQuery.of(context).size.width * 1;

    final defaultPinTheme = PinTheme(
      width: height / 4,
      height: width / 4,
      textStyle: const TextStyle(
        fontSize: 22,
        color: AppColors.primaryColor,
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: borderColor),
          color: AppColors.inputBackground),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: focusedBorderColor),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: fillColor,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: focusedBorderColor),
      ),
    );

    return Form(
      key: formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Directionality(
            textDirection: TextDirection.ltr,
            child: Pinput(
              length: 6,
              controller: pinController,
              focusNode: focusNode,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: focusedPinTheme,
              submittedPinTheme: submittedPinTheme,
              enabled: !widget.isLoading,
              validator: (s) {
                return s?.length == 6 ? null : 'Please enter 6 digits';
              },
              pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
              showCursor: true,
              onCompleted: widget.onCompleted,
            ),
          ),
          Gap(isWidth: false, isHeight: true, height: height * 0.04),
          AppButton(
            onPress: widget.isLoading
                ? () {}
                : () {
                    if (pinController.text.length == 6) {
                      widget.onCompleted(pinController.text);
                    }
                  },
            title: widget.isLoading ? 'Verifying...' : 'Verify',
            textColor: AppColors.whiteColor,
          ),
          Gap(isWidth: false, isHeight: true, height: height * 0.3),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Didn't receive the OTP? ",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              InkWell(
                onTap: widget.onResend,
                child: Text(
                  "Resend OTP",
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
