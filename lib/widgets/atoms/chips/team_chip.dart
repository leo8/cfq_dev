import 'package:flutter/material.dart';
import '../../../models/team.dart';
import '../../../utils/styles/colors.dart';
import '../../../utils/styles/icons.dart';

class TeamChip extends StatelessWidget {
  final Team team;
  final VoidCallback onDelete;

  const TeamChip({
    super.key,
    required this.team,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: CircleAvatar(
        backgroundImage: NetworkImage(team.imageUrl),
      ),
      label: Text(team.name),
      deleteIcon: const Icon(CustomIcon.close, size: 18),
      onDeleted: onDelete,
      backgroundColor: CustomColor.white.withOpacity(0.1),
      labelStyle: const TextStyle(color: CustomColor.white),
    );
  }
}
