import 'dart:typed_data';
import 'package:cfq_dev/utils/fonts.dart';
import 'package:cfq_dev/utils/icons.dart';
import 'package:cfq_dev/utils/moods.dart';
import 'package:cfq_dev/utils/string.dart';
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
  final TextEditingController _locationController =
      TextEditingController(); // For precise address
  DateTime? _selectedDateTime;
  List<String>? _moods;
  bool _isLoading = false;

  // Select an image for the CFQ
  Future<void> _selectImage(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text(CustomString.creerUnCfq),
          children: [
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text(CustomString.prendreUnePhotoAveclAppareil),
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
              child: const Text(CustomString.choisirUnePhotoDeLaGalerie),
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
              child: const Text(CustomString.annuler),
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
              title: const Text(CustomString.selectionnerLesMoodsDeVotreCfq),
              content: SingleChildScrollView(
                child: Column(
                  children: CustomMood.moods.map((mood) {
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
                  child: const Text(CustomString.ok),
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

  // Posting the CFQ
  Future<void> _postCfq() async {
    if (_file == null) {
      showSnackBar(CustomString.veuillezSelectionnerUneImage, context);
      return;
    }

    if (_nameController.text.isEmpty || _descriptionController.text.isEmpty) {
      showSnackBar(CustomString.veuillezRemplirTousLesChamps, context);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String res = await FirestoreMethods().uploadCfq(
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
      _locationController.text, // "Où" field for CFQ
    );

    if (res == CustomString.success) {
      // Show SnackBar for successful publication
      showSnackBar(CustomString.publicationReussie, context);

      setState(() {
        _isLoading = false;
      });

      // Navigate back to the post screen (assuming you navigate to the add CFQ screen from the post screen)
      Navigator.of(context).pop();
    } else {
      // Handle error
      showSnackBar(res, context);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
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
                CustomString.caFoutQuoi,
                style: TextStyle(
                  fontWeight: CustomFont.fontWeightBold,
                  fontSize: CustomFont.fontSize20,
                ),
              ),
              leading: IconButton(
                icon: const Icon(CustomIcon.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              actions: [
                TextButton(
                  onPressed: _postCfq,
                  child: const Text(
                    CustomString.publier,
                    style: TextStyle(
                        color: CustomColor.primaryColor, fontWeight: CustomFont.fontWeightBold),
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
                        Stack(
                          children: [
                            Container(
                              width: 300,
                              height: 120,
                              decoration: BoxDecoration(
                                color: CustomColor.secondaryColor[800],
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
                                        CustomString.aucuneImage,
                                        style: TextStyle(
                                          color: CustomColor.white70,
                                          fontSize: CustomFont.fontSize10,
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
                                    color: CustomColor.purple,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    CustomIcon.addAPhoto,
                                    color: CustomColor.primaryColor,
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
                    const Text(CustomString.nomDuCfq,
                        style: TextStyle(color: CustomColor.primaryColor)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: CustomColor.secondaryColor[800],
                        hintText: CustomString.nomDuCfq,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                      ),
                      style: const TextStyle(fontSize: CustomFont.fontSize13),
                    ),
                    const SizedBox(height: 12),

                    // Date & moods Buttons
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(CustomString.ajouterUneDate,
                                  style: TextStyle(color: CustomColor.primaryColor)),
                              const SizedBox(height: 6),
                              ElevatedButton(
                                onPressed: () => _selectDateTime(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: CustomColor.purple,
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
                                      : CustomString.selectionner,
                                  style: const TextStyle(fontSize: CustomFont.fontSize14),
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
                              const Text(CustomString.moods,
                                  style: TextStyle(color: CustomColor.primaryColor)),
                              const SizedBox(height: 6),
                              ElevatedButton(
                                onPressed: () => _selectMoods(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: CustomColor.purple,
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
                                      : CustomString.selectionner,
                                  style: const TextStyle(fontSize: CustomFont.fontSize14),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Organisateurs and À qui Fields
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(CustomString.organisateurs,
                                  style: TextStyle(color: CustomColor.primaryColor)),
                              const SizedBox(height: 6),
                              TextField(
                                decoration: InputDecoration(
                                  hintText: CustomString.selectionner,
                                  filled: true,
                                  fillColor: CustomColor.secondaryColor[800],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                ),
                                style: const TextStyle(fontSize: CustomFont.fontSize13),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(CustomString.aQui,
                                  style: TextStyle(color: CustomColor.primaryColor)),
                              const SizedBox(height: 6),
                              TextField(
                                decoration: InputDecoration(
                                  hintText: CustomString.selectionner,
                                  filled: true,
                                  fillColor: CustomColor.secondaryColor[800],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                ),
                                style: const TextStyle(fontSize: CustomFont.fontSize13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Where Field (Où)
                    const Text(CustomString.ou, style: TextStyle(color: CustomColor.primaryColor)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        hintText: CustomString.ou,
                        filled: true,
                        fillColor: CustomColor.secondaryColor[800],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                      ),
                      style: const TextStyle(fontSize: CustomFont.fontSize13),
                    ),
                    const SizedBox(height: 12),

                    // Description Field
                    const Text(CustomString.description,
                        style: TextStyle(color: CustomColor.primaryColor)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: CustomColor.secondaryColor[800],
                        hintText:
                            CustomString.racontePasTaVieDisNousJusteOuTuSors,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                      ),
                      style: const TextStyle(fontSize: CustomFont.fontSize13),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
