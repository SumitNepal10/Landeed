import 'package:flutter/material.dart';
import 'package:landeed/components/app_padding.dart';
import 'package:landeed/components/gap.dart';
import 'package:landeed/components/header_title.dart';
import 'package:landeed/components/otp_card.dart';
import 'package:landeed/utils/route_name.dart';
import 'package:provider/provider.dart';
import 'package:landeed/services/auth_service.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final bool isPasswordReset;

  const OtpScreen({
    super.key,
    required this.email,
    this.isPasswordReset = false,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  bool isLoading = false;

  Future<void> verifyOTP(String otp) async {
    setState(() {
      isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      if (widget.isPasswordReset) {
        await authService.verifyPasswordResetOTP(
          email: widget.email,
          otp: otp,
        );
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            RoutesName.resetPasswordScreen,
            arguments: {
              'email': widget.email,
              'otp': otp,
            },
          );
        }
      } else {
        await authService.verifyEmailOTP(
          email: widget.email,
          otp: otp,
        );
        if (mounted) {
          Navigator.pushReplacementNamed(context, RoutesName.loginScreen);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> resendOTP() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      if (widget.isPasswordReset) {
        await authService.forgotPassword(widget.email);
      } else {
        await authService.resendEmailOTP(widget.email);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP resent successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 1;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
      ),
      body: SafeArea(
        child: AppPadding(
          padddingValue: 15,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Gap(isWidth: false, isHeight: true, height: height * 0.01),
                HeaderTitle(
                  title: "Enter the ",
                  bottomTitle: "Enter the 6 digit code that we just sent to",
                  isBottomTitle: true,
                  bottomTitle2: widget.email,
                  subtitle: "code",
                ),
                Gap(isWidth: false, isHeight: true, height: height * 0.09),
                OtpCard(
                  onCompleted: verifyOTP,
                  isLoading: isLoading,
                  onResend: resendOTP,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
