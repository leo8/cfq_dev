import 'dart:typed_data';
import 'package:cfq_dev/widgets/atoms/texts/bordered_icon_text_field.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/styles/string.dart';
import '../../utils/styles/text_styles.dart';
import '../../utils/styles/icons.dart';
import '../atoms/avatars/profile_image_avatar.dart';
import '../atoms/dates/custom_date_field.dart';
import '../atoms/buttons/custom_button.dart';
import 'package:http/http.dart' as http;
import '../../utils/logger.dart';
import '../../utils/utils.dart';
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';

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
      text: widget.initialBirthDate?.toLocal().toString().split(' ')[0] ??
          CustomString.emptyString,
    );
    _selectedDate = widget.initialBirthDate;
    _loadInitialImage();
  }

  Future<Uint8List?> _getImageFromUrl(String url) async {
    if (url.isEmpty) return null;

    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        final response = await http.get(Uri.parse(url)).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException('Request timed out');
          },
        );

        if (response.statusCode == 200) {
          return response.bodyBytes;
        }
        throw Exception('Failed to load image');
      } catch (e) {
        retryCount++;
        if (retryCount == maxRetries) {
          AppLogger.error('Error loading image after $maxRetries attempts: $e');
          return null;
        }
        // Wait before retrying
        await Future.delayed(Duration(seconds: retryCount));
      }
    }
    return null;
  }

  Future<void> _loadInitialImage() async {
    if (!mounted) return;

    try {
      setState(() => _isImageLoading = true);
      final image = await _getImageFromUrl(widget.initialProfilePictureUrl);
      if (!mounted) return;

      setState(() {
        _selectedImage = image;
        _isImageLoading = false;
      });
    } catch (e) {
      AppLogger.error('Error loading initial image: $e');
      if (!mounted) return;
      setState(() => _isImageLoading = false);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _locationController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _selectImage() async {
    final ImageSource? source = await showImageSourceDialog(context);
    if (source != null) {
      try {
        final Uint8List? imageBytes = await pickImage(source);
        if (imageBytes != null) {
          setState(() {
            _selectedImage = imageBytes;
          });
        }
      } catch (e) {
        AppLogger.error('Error selecting image: $e');
      }
    }
  }

  bool isValidUsernameLength(String username) {
    return username.length >= 3 && username.length <= 10;
  }

  Future<void> _handleSave() async {
    if (_isLoading) return;

    // Validate username length
    if (!isValidUsernameLength(_usernameController.text)) {
      Fluttertoast.showToast(
          msg: CustomString.invalidUsernameLength,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }

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
      Fluttertoast.showToast(
          msg: e.toString().contains(CustomString.usernameAlreadyTaken)
              ? CustomString.usernameAlreadyTaken
              : e.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
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
          Center(
            child: Text(
              CustomString.myProfileCapital,
              style: CustomTextStyle.body1.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 25),
          _buildProfileImage(),
          const SizedBox(height: 25),
          BorderedIconTextField(
              icon: CustomIcon.editProfile,
              controller: _usernameController,
              hintText: CustomString.yourUsername,
              maxLength: 10),
          const SizedBox(height: 15),
          BorderedIconTextField(
              icon: CustomIcon.userLocation,
              controller: _locationController,
              hintText: CustomString.yourLocation),
          const SizedBox(height: 15),
          CustomDateField(
            controller: _birthDateController,
            hintText: CustomString.yourBirthdate,
            selectedDate: _selectedDate,
            onDateChanged: (DateTime? newDate) {
              setState(() {
                _selectedDate = newDate;
              });
            },
          ),
          const SizedBox(height: 35),
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
