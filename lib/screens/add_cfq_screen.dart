import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cfq_dev/templates/standard_form_template.dart';
import 'package:cfq_dev/utils/utils.dart';
import 'package:cfq_dev/enums/moods.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cfq_dev/providers/user_provider.dart';
import 'package:cfq_dev/providers/firestore_methods.dart';

import '../utils/styles/colors.dart';
import '../utils/styles/fonts.dart';
import '../utils/styles/string.dart';
import '../widgets/organisms/cfq_form.dart';

class AddCfqScreen extends StatefulWidget {
  const AddCfqScreen({super.key});

  @override
  State<AddCfqScreen> createState() => _AddCfqScreenState();
}

class _AddCfqScreenState extends State<AddCfqScreen> {
  // Controllers to handle input text
  Uint8List? _file;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  DateTime? _selectedDateTime;
  List<String>? _moods;
  bool _isLoading = false;

  @override
  void dispose() {
    // Dispose of controllers when the widget is destroyed to avoid memory leaks
    super.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
  }

  // Function to select an image from the gallery
  Future<void> _selectImage(BuildContext context) async {
    Uint8List? file = await pickImage(ImageSource.gallery);
    setState(() {
      _file = file;
    });
  }

  // Function to select a date and time for the event
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

  // Function to open a dialog for selecting moods
  void _selectMoods(BuildContext context) {
    showDialog<List<String>>(
      context: context,
      builder: (BuildContext dialogContext) {
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

  // Function to upload the CFQ data to Firestore
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

    // Upload CFQ to Firestore using FirestoreMethods
    String res = await FirestoreMethods().uploadCfq(
      _nameController.text,
      _descriptionController.text,
      _moods ?? [],
      Provider.of<UserProvider>(context, listen: false).getUser.uid,
      [], // Empty organizers for now
      Provider.of<UserProvider>(context, listen: false).getUser.username,
      _file!,
      Provider.of<UserProvider>(context, listen: false)
          .getUser
          .profilePictureUrl,
      _locationController.text,
    );

    setState(() {
      _isLoading = false;
    });

    // Show success or error message
    if (res == CustomString.success) {
      showSnackBar(CustomString.publicationReussie, context);
      Navigator.of(context).pop();
    } else {
      showSnackBar(res, context);
    }
  }

  @override
  Widget build(BuildContext context) {

    return StandardFormTemplate(
      appBarTitle: const Text(
        CustomString.caFoutQuoi,
        style: TextStyle(
          fontWeight: CustomFont.fontWeightBold,
          fontSize: CustomFont.fontSize20,
        ),
      ),
      appBarActions: [
        TextButton(
          onPressed: _postCfq,
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
      // CFQForm widget handles the form input fields for creating CFQ
      body: CFQForm(
        image: _file,
        onSelectImage: () => _selectImage(context),
        nameController: _nameController,
        descriptionController: _descriptionController,
        locationController: _locationController,
        onSelectDateTime: () => _selectDateTime(context),
        onSelectMoods: () => _selectMoods(context),
        dateTimeDisplay: _selectedDateTime != null
            ? '${_selectedDateTime!.day}/${_selectedDateTime!.month}/${_selectedDateTime!.year}'
            : CustomString.selectionner,
        moodsDisplay: _moods != null && _moods!.isNotEmpty
            ? _moods!.join(', ')
            : CustomString.selectionner,
        isLoading: _isLoading,
        onSubmit: _postCfq,
      ),
    );
  }
}
