import 'package:flutter/material.dart';
import '../../utils/styles/string.dart';

class ProfileEditForm extends StatefulWidget {
  final String initialUsername;
  final String initialEmail;
  final String initialBio;
  final Function(String, String, String) onSave;

  const ProfileEditForm({
    Key? key,
    required this.initialUsername,
    required this.initialEmail,
    required this.initialBio,
    required this.onSave,
  }) : super(key: key);

  @override
  _ProfileEditFormState createState() => _ProfileEditFormState();
}

class _ProfileEditFormState extends State<ProfileEditForm> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.initialUsername);
    _emailController = TextEditingController(text: widget.initialEmail);
    _bioController = TextEditingController(text: widget.initialBio);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(labelText: CustomString.username),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(labelText: CustomString.tonMail),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _bioController,
            decoration: InputDecoration(labelText: CustomString.taBio),
            maxLines: 3,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              widget.onSave(
                _usernameController.text,
                _emailController.text,
                _bioController.text,
              );
            },
            child: Text('Sauvegarder'),
          ),
        ],
      ),
    );
  }
}