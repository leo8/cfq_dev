import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cfq_dev/utils/colors.dart';
import 'package:cfq_dev/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:cfq_dev/providers/user_provider.dart';
import 'package:cfq_dev/models/user.dart' as model;
import 'package:cfq_dev/ressources/firestore_methods.dart';

class AddCfqScreen extends StatefulWidget {
  const AddCfqScreen({super.key});

  @override
  State<AddCfqScreen> createState() => _AddCfqScreenState();
}

class _AddCfqScreenState extends State<AddCfqScreen> {
  Uint8List? _file;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _organizersController = TextEditingController();

  _selectImage(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Créer un CFQ'),
          children: [
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text("Prendre une photo avec l'appareil"),
              onPressed: () async {
                Navigator.of(context).pop();
                Uint8List file = await pickImage(ImageSource.camera);
                setState(() {
                  _file = file;
                });
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text("Choisir une photo de la galerie"),
              onPressed: () async {
                Navigator.of(context).pop();
                Uint8List file = await pickImage(ImageSource.gallery);
                setState(() {
                  _file = file;
                });
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text("Annuler"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _organizersController.dispose();
  }

  void _postCfq() async {
    String res = await FirestoreMethods().uploadCfq(
      _nameController.text,
      _descriptionController.text,
      'Mood', // Replace with appropriate mood value or input
      Provider.of<UserProvider>(context, listen: false).getUser.uid,
      _organizersController.text.split(','), // Convert the organizers input to a list
      Provider.of<UserProvider>(context, listen: false).getUser.username,
      _file!,
      Provider.of<UserProvider>(context, listen: false).getUser.profilePictureUrl,
    );

    if (res == 'success') {
      showSnackBar('CFQ publié avec succès', context);
      Navigator.of(context).pop();
    } else {
      showSnackBar(res, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final model.User user = Provider.of<UserProvider>(context).getUser;

    return Scaffold(
      backgroundColor: mobileBackgroundColor,
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        centerTitle: true,
        title: const Text(
          'CFQ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close), // 'X' button
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: _postCfq,
            child: const Text(
              'Publier',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // Profile picture and image preview container
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(user.profilePictureUrl),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),

                  // Image Preview Container
                  Stack(
                    children: [
                      Container(
                        width: 300,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(10),
                          image: _file != null
                              ? DecorationImage(
                                  image: MemoryImage(_file!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _file == null
                            ? const Center(
                                child: Text(
                                  'Aucune image',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        top: 5,
                        right: 5,
                        child: GestureDetector(
                          onTap: () {
                            _selectImage(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.purple,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add_a_photo,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // CFQ Name Field
              const Text('Nom du CFQ', style: TextStyle(color: Colors.white)),
              const SizedBox(height: 6),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                ),
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),

              // Description Field
              const Text('Description', style: TextStyle(color: Colors.white)),
              const SizedBox(height: 6),
              TextField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[800],
                  hintText: "Raconte pas ta vie, dis nous juste où tu sors...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                ),
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),

              // Organizers Field
              const Text('Organisateurs (Séparés par une virgule)', style: TextStyle(color: Colors.white)),
              const SizedBox(height: 6),
              TextField(
                controller: _organizersController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                ),
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),

              // Mood Field
              const Text('Mood', style: TextStyle(color: Colors.white)),
              const SizedBox(height: 6),
              // Add your mood selection UI here

            ],
          ),
        ),
      ),
    );
  }
}
