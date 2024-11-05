import 'dart:typed_data';
import 'package:cfq_dev/providers/auth_methods.dart';
import 'package:cfq_dev/responsive/mobile_screen_layout.dart';
import 'package:cfq_dev/responsive/repsonsive_layout_screen.dart';
import 'package:cfq_dev/responsive/web_screen_layout.dart';
import 'package:cfq_dev/screens/login/inscription.dart';
import 'package:cfq_dev/screens/login/inscription_birthday_date.dart';
import 'package:cfq_dev/screens/login/inscription_friends.dart';
import 'package:cfq_dev/screens/login/inscription_localisation.dart';
import 'package:cfq_dev/screens/login/inscription_photo.dart';
import 'package:cfq_dev/utils/styles/string.dart';
import 'package:cfq_dev/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class RegistrationFlow extends StatefulWidget {
  final UserCredential cred;
  const RegistrationFlow({super.key, required this.cred});

  @override
  // ignore: library_private_types_in_public_api
  _RegistrationFlowState createState() => _RegistrationFlowState();
}

class _RegistrationFlowState extends State<RegistrationFlow> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  final int totalPages = 4;
  final TextEditingController nameTextController = TextEditingController();
  final TextEditingController birthdayTextController = TextEditingController();
  final TextEditingController localisationTextController =
      TextEditingController();
  DateTime? _selectedBirthDate;
  Uint8List? _image;
  bool _isLoading = false;

  void selectImage() async {
    final ImageSource? source = await showImageSourceDialog(context);
    if (source != null) {
      Uint8List? im = await pickImage(source);
      setState(() {
        _image = im;
      });
    }
  }

  /// Attempts to sign up the user with the provided information.
  void signUpUser() async {
    setState(() {
      _isLoading = true; // Show loading state
    });

    // Call AuthMethods to sign up the user
    String res = await AuthMethods().signUpUser(
        email: "",
        password: "",
        username: nameTextController.text,
        profilePicture: _image,
        location: localisationTextController.text,
        birthDate: _selectedBirthDate, // Pass selected birth date
        uid: widget.cred.user!.uid);

    setState(() {
      _isLoading = false; // Hide loading state
    });

    if (res != CustomString.success) {
      showSnackBar(res, context); // Show error message if signup fails
    } else {
      // Navigate to the main layout on successful signup
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => RepsonsiveLayout(
            mobileScreenLayout: MobileScreenLayout(uid: widget.cred.user!.uid),
            webScreenLayout: WebScreenLayout(),
          ),
        ),
        (route) => false,
      );
    }
  }

  void _nextPage() {
    if (_currentIndex < totalPages) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentIndex++;
      });
    }
  }

  void _previousPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics:
                        const NeverScrollableScrollPhysics(), // Désactive le swipe manuel
                    children: [
                      Inscription(
                        onNext: _nextPage,
                        onPrevious: _previousPage,
                        currentPages: _currentIndex,
                        totalPages: totalPages,
                        nameTextController: nameTextController,
                      ),
                      InscriptionBirthdayDate(
                        onNext: _nextPage,
                        onPrevious: _previousPage,
                        currentPages: _currentIndex,
                        totalPages: totalPages,
                        birthdayTextController: birthdayTextController,
                        selectedBirthDate: _selectedBirthDate,
                        onBirthDateChanged: (DateTime? newDate) {
                          setState(() {
                            _selectedBirthDate =
                                newDate; // Update selected birth date
                          });
                        },
                      ),
                      LoginPhoto(
                        onNext: _nextPage,
                        onPrevious: _previousPage,
                        currentPages: _currentIndex,
                        totalPages: totalPages,
                        image: _image,
                        onImageSelected: selectImage,
                      ),
                      InscriptionLocalisation(
                        onNext: _nextPage,
                        onPrevious: _previousPage,
                        currentPages: _currentIndex,
                        totalPages: totalPages,
                        localisationTextController: localisationTextController,
                      ),
                      InscriptionFriends(
                          onNext: _nextPage,
                          onPrevious: _previousPage,
                          currentPages: _currentIndex,
                          totalPages: totalPages,
                          signUp: signUpUser)
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
