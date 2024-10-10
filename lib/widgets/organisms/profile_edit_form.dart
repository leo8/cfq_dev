import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/styles/string.dart';
import '../atoms/avatars/profile_image_avatar.dart';
import '../molecules/username_location_field.dart';
import '../atoms/dates/custom_date_field.dart';
import '../atoms/buttons/custom_button.dart';
import 'package:http/http.dart' as http;
import '../../utils/logger.dart';

class ProfileEditForm extends StatefulWidget {
  final String initialUsername;
  final String initialLocation;
  final DateTime? initialBirthDate;
  final String initialProfilePictureUrl;
  final Future<void> Function(String, String, DateTime?, Uint8List?) onSave;

  const ProfileEditForm({
    super.key,
    required this.initialUsername,
    required this.initialLocation,
    this.initialBirthDate,
    required this.initialProfilePictureUrl,
    required this.onSave,
  });

  @override
  _ProfileEditFormState createState() => _ProfileEditFormState();
}

class _ProfileEditFormState extends State<ProfileEditForm> {
  late TextEditingController _usernameController;
  late TextEditingController _locationController;
  late TextEditingController _birthDateController;
  DateTime? _selectedDate;
  Uint8List? _selectedImage;
  bool _isLoading = false;
  bool _isImageLoading = true;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.initialUsername);
    _locationController = TextEditingController(text: widget.initialLocation);
    _birthDateController = TextEditingController(
      text: widget.initialBirthDate?.toLocal().toString().split(' ')[0] ?? '',
    );
    _selectedDate = widget.initialBirthDate;
    _loadInitialImage();
  }

  Future<void> _loadInitialImage() async {
    try {
      final image = await _getImageFromUrl(widget.initialProfilePictureUrl);
      setState(() {
        _selectedImage = image;
        _isImageLoading = false;
      });
    } catch (e) {
      AppLogger.error('Error loading initial image: $e');
      setState(() {
        _isImageLoading = false;
      });
    }
  }

  Future<Uint8List?> _getImageFromUrl(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
    } catch (e) {
      AppLogger.error('Error fetching image: $e');
    }
    return null;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _locationController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _selectImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final imageBytes = await image.readAsBytes();
        setState(() {
          _selectedImage = imageBytes;
        });
      }
    } catch (e) {
      AppLogger.error('Error selecting image: $e');
    }
  }

  Future<void> _handleSave() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onSave(
        _usernameController.text,
        _locationController.text,
        _selectedDate,
        _selectedImage,
      );
    } catch (e) {
      AppLogger.error('Error saving profile: $e');
      // You might want to show an error message to the user here
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildProfileImage(),
          const SizedBox(height: 16),
          UsernameLocationFields(
            usernameController: _usernameController,
            locationController: _locationController,
          ),
          const SizedBox(height: 16),
          const SizedBox(height: 16),
          CustomDateField(
            controller: _birthDateController,
            hintText: CustomString.taDateDeNaissance,
            selectedDate: _selectedDate,
            onDateChanged: (DateTime? newDate) {
              setState(() {
                _selectedDate = newDate;
              });
            },
          ),
          const SizedBox(height: 24),
          CustomButton(
            label: 'Sauvegarder',
            onTap: _handleSave,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return ProfileImageAvatar(
      image: _selectedImage,
      onImageSelected: _selectImage,
      isLoading: _isImageLoading,
    );
  }
}
