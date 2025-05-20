import 'package:flutter/material.dart';
import 'package:partice_project/components/account_form.dart';
import 'package:partice_project/components/gap.dart';
import 'package:partice_project/components/header_title.dart';
import 'package:partice_project/components/shared/screen.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';

class UserAccountScreen extends StatefulWidget {
  const UserAccountScreen({super.key});

  @override
  State<UserAccountScreen> createState() => _UserAccountScreenState();
}

class _UserAccountScreenState extends State<UserAccountScreen> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 1;
    return Screen(
      isBackButton: true,
      appBarActions: [
        IconButton(
          icon: Stack(
            children: [
              const Icon(Icons.notifications),
              Consumer<NotificationProvider>(
                builder: (context, notificationProvider, child) {
                  final unreadCount = notificationProvider.unreadCount;
                  if (unreadCount > 0) {
                    return Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          onPressed: () {
            Navigator.pushNamed(context, RoutesName.notificationsScreen);
          },
        ),
      ],
      isBottomTab: false,
      child: Column(
        children: [
          const HeaderTitle(
            title: "Fill your",
            title1: "information below",
            bottomTitle: "You can edit this later on your account setting.",
            subtitle: "",
            isUnderTitle: true,
          ),
          Gap(
            isWidth: false,
            isHeight: true,
            height: height * 0.03,
          ),
          const AccountForm()
        ],
      ),
    );
  }
}
