import 'package:flutter/material.dart';
import '../../models/notification.dart' as model;
import '../molecules/notification_card.dart';
import '../../utils/styles/text_styles.dart';
import '../../utils/styles/colors.dart';

class NotificationsList extends StatelessWidget {
  final List<model.Notification> notifications;
  final bool isLoading;
  final Stream<int> unreadCountStream;

  const NotificationsList({
    super.key,
    required this.notifications,
    required this.isLoading,
    required this.unreadCountStream,
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

    return StreamBuilder<int>(
      stream: unreadCountStream,
      builder: (context, snapshot) {
        final unreadCount = snapshot.data ?? 0;

        return ListView.separated(
          itemCount: notifications.length,
          separatorBuilder: (context, index) => const SizedBox(height: 1),
          itemBuilder: (context, index) {
            return Container(
              color: index < unreadCount
                  ? CustomColor.customDarkGrey
                  : Colors.transparent,
              child: NotificationCard(
                notification: notifications[index],
                onTap: () {
                  // TODO: Navigate to event details
                },
              ),
            );
          },
        );
      },
    );
  }
}
