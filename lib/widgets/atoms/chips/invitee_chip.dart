import 'package:flutter/material.dart';
import '../../../models/user.dart' as model;

class InviteeChip extends StatelessWidget {
  final model.User invitee;
  final VoidCallback onDelete;

  const InviteeChip({
    super.key,
    required this.invitee,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: CircleAvatar(
        backgroundImage: NetworkImage(invitee.profilePictureUrl),
      ),
      label: Text(invitee.username),
      onDeleted: onDelete,
    );
  }
}
