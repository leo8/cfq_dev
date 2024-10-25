import 'package:flutter/material.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/icons.dart';
import '../../utils/styles/text_styles.dart';
import '../atoms/buttons/custom_icon_button.dart';

class ThreadHeader extends StatelessWidget {
  final VoidCallback onSearchTap;
  final VoidCallback onNotificationTap;
  final VoidCallback onMessageTap;
  final Stream<int> unreadConversationsCountStream;

  const ThreadHeader({
    super.key,
    required this.onSearchTap,
    required this.onNotificationTap,
    required this.onMessageTap,
    required this.unreadConversationsCountStream,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CustomIconButton(
          icon: CustomIcon.search,
          color: CustomColor.customWhite,
          onTap: onSearchTap,
        ),
        const Spacer(),
        CustomIconButton(
          icon: CustomIcon.notifications,
          color: CustomColor.customWhite,
          onTap: onNotificationTap,
        ),
        const SizedBox(width: 10),
        Stack(
          children: [
            CustomIconButton(
              icon: CustomIcon.inbox,
              color: CustomColor.customWhite,
              onTap: onMessageTap,
            ),
            StreamBuilder<int>(
              stream: unreadConversationsCountStream,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data! > 0) {
                  return Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 23,
                        minHeight: 9,
                      ),
                      child: Text(
                        snapshot.data! > 99 ? '99+' : snapshot.data!.toString(),
                        style: CustomTextStyle.body2.copyWith(
                          fontWeight: FontWeight.bold,
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
      ],
    );
  }
}
