import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/styles/colors.dart';
import '../utils/styles/string.dart';
import '../utils/styles/text_styles.dart';
import '../utils/styles/icons.dart';
import '../view_models/notifications_view_model.dart';
import '../widgets/organisms/notifications_list.dart';

class NotificationsScreen extends StatelessWidget {
  final String currentUserUid;

  const NotificationsScreen({
    super.key,
    required this.currentUserUid,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NotificationsViewModel(currentUserUid: currentUserUid),
      child: Consumer<NotificationsViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            backgroundColor: CustomColor.customBlack,
            appBar: AppBar(
              toolbarHeight: 40,
              backgroundColor: CustomColor.customBlack,
              leading: IconButton(
                icon: CustomIcon.arrowBack,
                onPressed: () {
                  // First reset the unread count
                  viewModel.resetUnreadCount().then((_) {
                    // Then navigate back
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  });
                },
              ),
            ),
            body: Column(
              children: [
                const SizedBox(height: 15),
                Center(
                  child: Text(
                    CustomString.notificationsCapital,
                    style: CustomTextStyle.body1.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: NotificationsList(
                    notifications: viewModel.notifications,
                    isLoading: viewModel.isLoading,
                    unreadCountStream: viewModel.unreadCountStream,
                    currentUserId: viewModel.currentUserUid,
                    viewModel: viewModel,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
