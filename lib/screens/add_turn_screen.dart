import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cfq_dev/utils/colors.dart';
import 'package:cfq_dev/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:cfq_dev/providers/user_provider.dart';
import 'package:cfq_dev/models/user.dart' as model;
import 'package:cfq_dev/ressources/firestore_methods.dart';
import 'package:cfq_dev/utils/global_variables.dart';

class AddTurnScreen extends StatefulWidget {
  const AddTurnScreen({super.key});

  @override
  State<AddTurnScreen> createState() => _AddTurnScreenState();
}

class _AddTurnScreenState extends State<AddTurnScreen> {
  Uint8List? _file;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController =
      TextEditingController(); // For "Où"
  final TextEditingController _addressController =
      TextEditingController(); // For "Adresse"
  DateTime? _selectedDateTime;
  List<String>? _moods;
  bool _isLoading = false;

  // Select an image for the Turn
  Future<void> _selectImage(BuildContext context) async {
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

  // Select date and time
  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedDateTime != null
            ? TimeOfDay.fromDateTime(_selectedDateTime!)
            : TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  // Select moods
  void _selectMoods(BuildContext context) {
    showDialog<List<String>>(
      context: context,
      builder: (BuildContext dialogContext) {
        // Temporary variable to store selected moods during selection
        List<String> tempSelectedMoods = List<String>.from(_moods ?? []);

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Sélectionnez le(s) mood(s) de votre turn'),
              content: SingleChildScrollView(
                child: Column(
                  children: availableMoods.map((mood) {
                    return CheckboxListTile(
                      title: Text(mood),
                      value: tempSelectedMoods.contains(mood),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            tempSelectedMoods.add(mood);
                          } else {
                            tempSelectedMoods.remove(mood);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // Close the dialog and pass back the selected moods
                    Navigator.of(dialogContext).pop(tempSelectedMoods);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    ).then((selectedMoods) {
      if (selectedMoods != null) {
        // Update the parent state with the selected moods
        setState(() {
          _moods = selectedMoods;
        });
      }
    });
  }

  // Posting the Turn
  Future<void> _postTurn() async {
    if (_file == null) {
      showSnackBar('Veuillez sélectionner une image', context);
      return;
    }

    if (_nameController.text.isEmpty || _descriptionController.text.isEmpty) {
      showSnackBar('Veuillez remplir tous les champs', context);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String res = await FirestoreMethods().uploadTurn(
      _nameController.text,
      _descriptionController.text,
      _moods ?? [],
      Provider.of<UserProvider>(context, listen: false).getUser.uid,
      [], // Organizers remain empty for now
      Provider.of<UserProvider>(context, listen: false).getUser.username,
      _file!,
      Provider.of<UserProvider>(context, listen: false)
          .getUser
          .profilePictureUrl,
      _locationController.text, // "Où" field
      _addressController.text, // "Adresse" field
    );

    if (res == 'success') {
      // Show SnackBar for successful publication
      showSnackBar('Publication réussie !', context);

      setState(() {
        _isLoading = false;
      });

      // Navigate back to the post screen (assuming you navigate to the add turn screen from the post screen)
      Navigator.of(context).pop();
    } else {
      // Handle error
      showSnackBar(res, context);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _addressController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model.User user = Provider.of<UserProvider>(context).getUser;

    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(
              color: CustomColor.primaryColor,
            ),
          )
        : Scaffold(
            backgroundColor: CustomColor.mobileBackgroundColor,
            appBar: AppBar(
              backgroundColor: CustomColor.mobileBackgroundColor,
              centerTitle: true,
              title: const Text(
                'Ça Turn',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              actions: [
                TextButton(
                  onPressed: _postTurn,
                  child: const Text(
                    'Publier',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
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
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(user.profilePictureUrl),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Stack(
                            children: [
                              Container(
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
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Turn Name Field
                    const Text('Nom du Turn',
                        style: TextStyle(color: Colors.white)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[800],
                        hintText: 'Nom du Turn',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 12),

                    // Date & moodsButtons (side by side)
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text('Ajouter une date',
                                  style: TextStyle(color: Colors.white)),
                              const SizedBox(height: 6),
                              ElevatedButton(
                                onPressed: () => _selectDateTime(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                                child: Text(
                                  _selectedDateTime != null
                                      ? '${_selectedDateTime!.day}/${_selectedDateTime!.month}/${_selectedDateTime!.year}'
                                      : 'Sélectionner',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text('Mood',
                                  style: TextStyle(color: Colors.white)),
                              const SizedBox(height: 6),
                              ElevatedButton(
                                onPressed: () => _selectMoods(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                                child: Text(
                                  _moods != null && _moods!.isNotEmpty
                                      ? _moods!.join(', ')
                                      : 'Sélectionner',
                                  style: const TextStyle(fontSize: 14),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Organisateurs and À qui Fields (side by side)
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text('Organisateurs',
                                  style: TextStyle(color: Colors.white)),
                              const SizedBox(height: 6),
                              TextField(
                                decoration: InputDecoration(
                                  hintText: 'Sélectionner',
                                  filled: true,
                                  fillColor: Colors.grey[800],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                ),
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text('À qui ?',
                                  style: TextStyle(color: Colors.white)),
                              const SizedBox(height: 6),
                              TextField(
                                decoration: InputDecoration(
                                  hintText: 'Sélectionner',
                                  filled: true,
                                  fillColor: Colors.grey[800],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                ),
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Where and Address fields (on the same row)
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _locationController,
                            decoration: InputDecoration(
                              hintText: 'Où ?',
                              filled: true,
                              fillColor: Colors.grey[800],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                            ),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _addressController,
                            decoration: InputDecoration(
                              hintText: 'Adresse',
                              filled: true,
                              fillColor: Colors.grey[800],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                            ),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Description Field
                    const Text('Description',
                        style: TextStyle(color: Colors.white)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[800],
                        hintText:
                            "Raconte pas ta vie, dis nous juste où tu sors...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
