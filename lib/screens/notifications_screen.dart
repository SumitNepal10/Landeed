import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../models/property_notification.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    await Provider.of<NotificationProvider>(context, listen: false).getNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () {
              Provider.of<NotificationProvider>(context, listen: false).markAllAsRead();
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          if (notificationProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (notificationProvider.notifications.isEmpty) {
            return const Center(
              child: Text('No notifications'),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadNotifications,
            child: ListView.builder(
              itemCount: notificationProvider.notifications.length,
              itemBuilder: (context, index) {
                final notification = notificationProvider.notifications[index];
                return _NotificationTile(notification: notification);
              },
            ),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final PropertyNotification notification;

  const _NotificationTile({
    Key? key,
    required this.notification,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        // TODO: Implement delete notification
      },
      child: ListTile(
        leading: _getNotificationIcon(),
        title: Text(notification.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.message),
            const SizedBox(height: 4),
            Text(
              timeago.format(notification.createdAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: notification.isRead
            ? null
            : Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
        onTap: () {
          if (!notification.isRead) {
            Provider.of<NotificationProvider>(context, listen: false)
                .markAsRead(notification.id);
          }
          // TODO: Navigate to property details if needed
        },
      ),
    );
  }

  Widget _getNotificationIcon() {
    IconData iconData;
    Color iconColor;

    switch (notification.type) {
      case 'rejection':
        iconData = Icons.cancel;
        iconColor = Colors.red;
        break;
      case 'approval':
        iconData = Icons.check_circle;
        iconColor = Colors.green;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = Colors.blue;
    }

    return CircleAvatar(
      backgroundColor: iconColor.withOpacity(0.1),
      child: Icon(iconData, color: iconColor),
    );
  }
} 