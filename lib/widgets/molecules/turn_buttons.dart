import 'package:flutter/material.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/icons.dart';

class TurnButtons extends StatelessWidget {
  final VoidCallback onAttendingPressed;
  final VoidCallback onSharePressed;
  final VoidCallback onSendPressed;
  final VoidCallback onFavoritePressed;
  final bool isFavorite;

  const TurnButtons({
    Key? key,
    required this.onAttendingPressed,
    required this.onSharePressed,
    required this.onSendPressed,
    required this.onFavoritePressed,
    required this.isFavorite,
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
        _buildAttendingButton(),
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

  Widget _buildAttendingButton() {
    return GestureDetector(
      onTap: onAttendingPressed,
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
}
