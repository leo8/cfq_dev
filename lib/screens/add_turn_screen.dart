import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cfq_dev/utils/colors.dart';
import 'package:cfq_dev/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:cfq_dev/providers/user_provider.dart';
import 'package:cfq_dev/models/user.dart' as model;

class AddTurnScreen extends StatefulWidget {
  const AddTurnScreen({super.key});

  @override
  State<AddTurnScreen> createState() => _AddTurnScreenState();
}

class _AddTurnScreenState extends State<AddTurnScreen> {
  Uint8List? _file;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _organizersController = TextEditingController();

  _selectImage(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Créer un Turn'),
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

  @override
  Widget build(BuildContext context) {
    final model.User user = Provider.of<UserProvider>(context).getUser;

    return Scaffold(
      backgroundColor: mobileBackgroundColor,
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        centerTitle: true,
        title: const Text(
          'TURN',
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
            onPressed: () {
              // Handle post turn functionality
            },
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
              const SizedBox(height: 8), // Reduced height

              // Profile picture and image preview container
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 30, // Slightly smaller avatar
                        backgroundImage: NetworkImage(user.profilePictureUrl), // User's profile picture
                      ),
                    ],
                  ),
                  const SizedBox(width: 20), // Reduced width

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
                      // Add Image Button in the top right corner
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
              const SizedBox(height: 12), // Reduced height

              // Event Name Field
              const Text('Nom de l\'Event', style: TextStyle(color: Colors.white)),
              const SizedBox(height: 6), // Reduced height
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10), // Reduced padding
                ),
                style: const TextStyle(fontSize: 13), // Smaller font size
              ),
              const SizedBox(height: 12), // Reduced height

              // Start Date & Time Field
              const Text('Start Date & Time', style: TextStyle(color: Colors.white)),
              const SizedBox(height: 6), // Reduced height
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8), // Reduced vertical padding
                      ),
                      child: const Text('Add end time', style: TextStyle(fontSize: 12)), // Smaller text
                    ),
                  ),
                  const SizedBox(width: 8), // Reduced width
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8), // Reduced vertical padding
                      ),
                      child: const Text('Repeat event', style: TextStyle(fontSize: 12)), // Smaller text
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12), // Reduced height

              // Organizers Field
              const Text('Organisateurs (Séparés par une virgule)', style: TextStyle(color: Colors.white)),
              const SizedBox(height: 6), // Reduced height
              TextField(
                controller: _organizersController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10), // Reduced padding
                ),
                style: const TextStyle(fontSize: 13), // Smaller font size
              ),
              const SizedBox(height: 12), // Reduced height

              // Invitees and Location
              const Text('À qui ? (Liste(s) ou manuel)', style: TextStyle(color: Colors.white)),
              const SizedBox(height: 6), // Reduced height
              TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10), // Reduced padding
                ),
                style: const TextStyle(fontSize: 13), // Smaller font size
              ),
              const SizedBox(height: 12), // Reduced height
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Où ?',
                        filled: true,
                        fillColor: Colors.grey[800],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10), // Reduced padding
                      ),
                      style: const TextStyle(fontSize: 13), // Smaller font size
                    ),
                  ),
                  const SizedBox(width: 8), // Reduced width
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Adresse',
                        filled: true,
                        fillColor: Colors.grey[800],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10), // Reduced padding
                      ),
                      style: const TextStyle(fontSize: 13), // Smaller font size
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12), // Reduced height

              // Description Field (Increased size)
              const Text('Description', style: TextStyle(color: Colors.white)),
              const SizedBox(height: 6), // Reduced height
              TextField(
                controller: _descriptionController,
                maxLines: 5, // Increased the number of lines
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[800],
                  hintText: "Raconte pas ta vie, dis nous juste où tu sors...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10), // Reduced padding
                ),
                style: const TextStyle(fontSize: 13), // Smaller font size
              ),
            ],
          ),
        ),
      ),
    );
  }
}
