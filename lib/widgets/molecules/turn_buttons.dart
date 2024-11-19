import 'package:flutter/material.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/icons.dart';

class TurnButtons extends StatelessWidget {
  final Function(String) onAttendingPressed;
  final VoidCallback onSharePressed;
  final VoidCallback onSendPressed;
  final VoidCallback onFavoritePressed;
  final bool isFavorite;
  final String attendingStatus;
  final Stream<String> attendingStatusStream;

  const TurnButtons({
    Key? key,
    required this.onAttendingPressed,
    required this.onSharePressed,
    required this.onSendPressed,
    required this.onFavoritePressed,
    required this.isFavorite,
    required this.attendingStatus,
    required this.attendingStatusStream,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: attendingStatusStream,
      builder: (context, snapshot) {
        final attendingStatus = snapshot.data ?? 'notAnswered';
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 6),
            _buildIconButton(CustomIcon.eventConversation, onSendPressed),
            const SizedBox(width: 2),
            _buildFavoriteButton(),
            const SizedBox(width: 4),
            _buildAttendingButton(context, attendingStatus),
          ],
        );
      },
    );
  }

  Widget _buildIconButton(CustomIcon icon, VoidCallback onPressed) {
    return IconButton(
      icon: icon.copyWith(size: 24),
      onPressed: onPressed,
      color: CustomColor.customWhite,
      padding: const EdgeInsets.all(1),
    );
  }

  Widget _buildFavoriteButton() {
    return IconButton(
      icon: isFavorite
          ? CustomIcon.saveFull
              .copyWith(color: CustomColor.customWhite, size: 24)
          : CustomIcon.saveEmpty.copyWith(size: 24),
      onPressed: onFavoritePressed,
      padding: const EdgeInsets.all(1),
    );
  }

  Widget _buildAttendingButton(BuildContext context, String attendingStatus) {
    CustomIcon icon;
    Color color;

    switch (attendingStatus) {
      case 'attending':
        icon = CustomIcon.attendingStatusYes;
        color = CustomColor.customWhite;
        break;
      case 'notSureAttending':
        icon = CustomIcon.attendingStatusMaybe;
        color = CustomColor.customWhite;
        break;
      case 'notAttending':
        icon = CustomIcon.attendingStatusNo;
        color = CustomColor.customWhite;
        break;
      default:
        return _buildDefaultAttendingButton(context);
    }

    return GestureDetector(
      onTap: () => _showAttendingOptions(context),
      child: Container(
        width: 60,
        height: 60,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: CustomColor.customBlack,
          boxShadow: [
            BoxShadow(
              color: CustomColor.customBlack.withOpacity(0.5),
              spreadRadius: 4,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: icon.copyWith(size: 40, color: color),
        ),
      ),
    );
  }

  Widget _buildDefaultAttendingButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAttendingOptions(context),
      child: Container(
        width: 60,
        height: 60,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: CustomColor.customBlack,
          boxShadow: [
            BoxShadow(
              color: CustomColor.customBlack.withOpacity(0.5),
              spreadRadius: 4,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: CustomIcon.attending.copyWith(
            size: 28,
            color: CustomColor.customWhite,
          ),
        ),
      ),
    );
  }

  void _showAttendingOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: false,
      builder: (BuildContext context) {
        return StreamBuilder<String>(
          stream: attendingStatusStream,
          initialData: attendingStatus,
          builder: (context, snapshot) {
            final currentStatus = snapshot.data ?? 'notAnswered';
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Container(
                  color: CustomColor.customBlack,
                  child: Wrap(
                    children: <Widget>[
                      const Divider(height: 20, color: CustomColor.transparent),
                      const Divider(),
                      _buildAttendingOptionTile(
                        context,
                        'Je suis là',
                        CustomIcon.attendingStatusYes.copyWith(size: 30),
                        CustomColor.customWhite,
                        'attending',
                        currentStatus,
                        (String status) {
                          onAttendingPressed(status);
                          setState(() {});
                        },
                      ),
                      const Divider(),
                      _buildAttendingOptionTile(
                        context,
                        'Je sais pas',
                        CustomIcon.attendingStatusMaybe.copyWith(size: 30),
                        CustomColor.customWhite,
                        'notSureAttending',
                        currentStatus,
                        (String status) {
                          onAttendingPressed(status);
                          setState(() {});
                        },
                      ),
                      const Divider(),
                      _buildAttendingOptionTile(
                        context,
                        'Je peux pas',
                        CustomIcon.attendingStatusNo.copyWith(size: 30),
                        CustomColor.customWhite,
                        'notAttending',
                        currentStatus,
                        (String status) {
                          onAttendingPressed(status);
                          setState(() {});
                        },
                      ),
                      const Divider(),
                      const SizedBox(height: 120),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildAttendingOptionTile(
    BuildContext context,
    String title,
    CustomIcon icon,
    Color color,
    String status,
    String currentStatus,
    Function(String) onStatusPressed,
  ) {
    return ListTile(
      minTileHeight: 60,
      leading: Container(
        width: 70,
        height: 70,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: CustomColor.customBlack,
          boxShadow: [
            BoxShadow(
              color: CustomColor.customBlack.withOpacity(0.5),
              spreadRadius: 4,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: icon.copyWith(
          size: 30,
          color: color,
        ),
      ),
      title: Text(title),
      trailing: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: CustomColor.customWhite,
            width: 2,
          ),
          color: currentStatus == status
              ? CustomColor.customWhite
              : CustomColor.transparent,
        ),
      ),
      onTap: () {
        onStatusPressed(currentStatus == status ? 'notAnswered' : status);
      },
    );
  }
}
