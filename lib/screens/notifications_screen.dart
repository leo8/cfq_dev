import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/styles/colors.dart';
import '../utils/styles/string.dart';
import '../utils/styles/text_styles.dart';
import '../utils/styles/icons.dart';
import '../view_models/notifications_view_model.dart';
import '../widgets/organisms/notifications_list.dart';
import '../utils/loading_overlay.dart';

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
              surfaceTintColor: CustomColor.customBlack,
              leading: IconButton(
                icon: CustomIcon.arrowBack,
                onPressed: viewModel.isLoading
                    ? () {}
                    : () async {
                        // First show loading state
                        await viewModel.setLoadingState(true);

                        // Reset the unread count
                        await viewModel.resetUnreadCount();

                        // Hide loading state and pop if context is still mounted
                        if (context.mounted) {
                          await viewModel.setLoadingState(false);
                          Navigator.of(context).pop();
                        }
                      },
              ),
            ),
            body: Column(
              children: [
                Center(
                  child: Text(
                    CustomString.notificationsCapital,
                    style: CustomTextStyle.body1.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: LoadingOverlay(
                    isLoading: viewModel.isLoading,
                    child: NotificationsList(
                      notifications: viewModel.notifications,
                      isLoading: viewModel.isLoading,
                      unreadCountStream: viewModel.unreadCountStream,
                      currentUserId: viewModel.currentUserUid,
                      viewModel: viewModel,
                    ),
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
