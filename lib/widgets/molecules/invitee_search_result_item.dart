import 'package:flutter/material.dart';
import '../../models/user.dart' as model;

class InviteeSearchResultItem extends StatelessWidget {
  final model.User user;
  final VoidCallback onAdd;

  const InviteeSearchResultItem({
    super.key,
    required this.user,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(user.profilePictureUrl),
      ),
      title: Text(user.username),
      trailing: IconButton(
        icon: const Icon(Icons.add),
        onPressed: onAdd,
      ),
    );
  }
}
