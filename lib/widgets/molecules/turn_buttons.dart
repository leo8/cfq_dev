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

  const TurnButtons({
    Key? key,
    required this.onAttendingPressed,
    required this.onSharePressed,
    required this.onSendPressed,
    required this.onFavoritePressed,
    required this.isFavorite,
    required this.attendingStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIconButton(CustomIcon.eventConversation, onSendPressed),
        const SizedBox(width: 6),
        _buildFavoriteButton(),
        const SizedBox(width: 9),
        _buildAttendingButton(context),
      ],
    );
  }

  Widget _buildIconButton(CustomIcon icon, VoidCallback onPressed) {
    return IconButton(
      icon: icon.copyWith(size: 24),
      onPressed: onPressed,
      color: CustomColor.customWhite,
      padding: const EdgeInsets.all(8),
    );
  }

  Widget _buildFavoriteButton() {
    return IconButton(
      icon: isFavorite
          ? CustomIcon.favorite.copyWith(color: CustomColor.red, size: 24)
          : CustomIcon.favorite.copyWith(size: 24),
      onPressed: onFavoritePressed,
      padding: const EdgeInsets.all(8),
    );
  }

  Widget _buildAttendingButton(BuildContext context) {
    IconData iconData;
    Color iconColor;

    switch (attendingStatus) {
      case 'attending':
        iconData = Icons.check;
        iconColor = CustomColor.green;
        break;
      case 'notSureAttending':
        iconData = Icons.help_outline;
        iconColor = Colors.yellow;
        break;
      case 'notAttending':
        iconData = Icons.close;
        iconColor = CustomColor.red;
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
          child: Icon(
            iconData,
            size: 30,
            color: iconColor,
          ),
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
            size: 30,
            color: CustomColor.customWhite,
          ),
        ),
      ),
    );
  }

  void _showAttendingOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.check, color: CustomColor.green),
                title: const Text('Je suis là'),
                onTap: () {
                  onAttendingPressed('attending');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.help_outline, color: Colors.yellow),
                title: const Text('Je sais pas'),
                onTap: () {
                  onAttendingPressed('notSureAttending');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.close, color: CustomColor.red),
                title: const Text('Je peux pas'),
                onTap: () {
                  onAttendingPressed('notAttending');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
