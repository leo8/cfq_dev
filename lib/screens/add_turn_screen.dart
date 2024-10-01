import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cfq_dev/templates/standard_form_template.dart';
import 'package:cfq_dev/utils/utils.dart';
import 'package:cfq_dev/enums/moods.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cfq_dev/providers/user_provider.dart';
import 'package:cfq_dev/models/user.dart' as model;
import 'package:cfq_dev/providers/firestore_methods.dart';

import '../utils/styles/colors.dart';
import '../utils/styles/fonts.dart';
import '../utils/styles/string.dart';
import '../widgets/organisms/turn_form.dart';

/// Screen for creating a new TURN event.
class AddTurnScreen extends StatefulWidget {
  const AddTurnScreen({super.key});

  @override
  State<AddTurnScreen> createState() => _AddTurnScreenState();
}

class _AddTurnScreenState extends State<AddTurnScreen> {
  Uint8List? _file; // Holds the selected image file
  final TextEditingController _nameController =
      TextEditingController(); // TURN name controller
  final TextEditingController _descriptionController =
      TextEditingController(); // TURN description controller
  final TextEditingController _locationController =
      TextEditingController(); // TURN location controller
  final TextEditingController _addressController =
      TextEditingController(); // TURN address controller
  DateTime? _selectedDateTime; // Stores the selected event date and time
  List<String>? _moods; // Stores selected moods
  bool _isLoading = false; // Tracks if the form is submitting

  @override
  void dispose() {
    // Dispose of controllers when the widget is removed from the widget tree
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  /// Function to allow the user to select an image from the gallery.
  Future<void> _selectImage(BuildContext context) async {
    Uint8List? file = await pickImage(ImageSource.gallery);
    setState(() {
      _file = file;
    });
  }

  /// Function to allow the user to pick a date and time for the event.
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

  /// Function to allow the user to select moods for the event.
  void _selectMoods(BuildContext context) {
    showDialog<List<String>>(
      context: context,
      builder: (BuildContext dialogContext) {
        List<String> tempSelectedMoods = List<String>.from(_moods ?? []);
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text(CustomString.selectionnerLesMoodsDeVotreTurn),
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
        setState(() {
          _moods = selectedMoods;
        });
      }
    });
  }

  /// Function to handle TURN posting by uploading the data to Firestore.
  Future<void> _postTurn() async {
    // Ensure all required fields are filled
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
      _locationController.text,
      _addressController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (res == CustomString.success) {
      showSnackBar(CustomString.publicationReussie, context);
      Navigator.of(context).pop();
    } else {
      showSnackBar(res, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final model.User user = Provider.of<UserProvider>(context).getUser;

    return StandardFormTemplate(
      appBarTitle: const Text(
        CustomString.caTurn,
        style: TextStyle(
          fontWeight: CustomFont.fontWeightBold,
          fontSize: CustomFont.fontSize20,
        ),
      ),
      appBarActions: [
        TextButton(
          onPressed: _postTurn,
          child: const Text(
            CustomString.publier,
            style: TextStyle(
              color: CustomColor.white,
              fontWeight: CustomFont.fontWeightBold,
            ),
          ),
        ),
      ],
      onBackPressed: () {
        Navigator.of(context).pop();
      },
      body: TurnForm(
        image: _file,
        onSelectImage: () => _selectImage(context),
        nameController: _nameController,
        descriptionController: _descriptionController,
        locationController: _locationController,
        addressController: _addressController,
        onSelectDateTime: () => _selectDateTime(context),
        onSelectMoods: () => _selectMoods(context),
        dateTimeDisplay: _selectedDateTime != null
            ? '${_selectedDateTime!.day}/${_selectedDateTime!.month}/${_selectedDateTime!.year}'
            : CustomString.selectionner,
        moodsDisplay: _moods != null && _moods!.isNotEmpty
            ? _moods!.join(', ')
            : CustomString.selectionner,
        isLoading: _isLoading,
        onSubmit: _postTurn,
      ),
    );
  }
}
