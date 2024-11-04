import 'package:flutter/material.dart';
import '../../models/notification.dart' as model;
import '../molecules/notification_card.dart';
import '../../utils/styles/text_styles.dart';

class NotificationsList extends StatelessWidget {
  final List<model.Notification> notifications;
  final bool isLoading;

  const NotificationsList({
    super.key,
    required this.notifications,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (notifications.isEmpty) {
      return Center(
        child: Text(
          'Pas encore de notifications',
          style: CustomTextStyle.body1,
        ),
      );
    }

    return ListView.separated(
      itemCount: notifications.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        return NotificationCard(
          notification: notifications[index],
          onTap: () {
            // TODO: Navigate to event details
          },
        );
      },
    );
  }
}
