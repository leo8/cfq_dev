import 'dart:typed_data';
import 'package:cfq_dev/responsive/mobile_screen_layout.dart';
import 'package:cfq_dev/responsive/repsonsive_layout_screen.dart';
import 'package:cfq_dev/responsive/web_screen_layout.dart';
import 'package:cfq_dev/ressources/auth_methods.dart';
import 'package:cfq_dev/screens/login_screen.dart';
import 'package:cfq_dev/utils/colors.dart';
import 'package:cfq_dev/utils/string.dart';
import 'package:cfq_dev/utils/utils.dart';
import 'package:cfq_dev/widgets/text_field_input.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  Uint8List? _image;
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
  }

  void selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    setState(() {
      _image = im;
    });
  }

  void signUpUser() async {
    setState(() {
      _isLoading = true;
    });
    String res = await AuthMethods().signUpUser(
      email: _emailController.text,
      password: _passwordController.text,
      username: _usernameController.text,
      bio: _bioController.text,
      profilePicture: _image != null ? _image! : null,
      location: _locationController.text,
    );
    setState(() {
      _isLoading = false;
    });
    if (res != CustomString.success) {
      showSnackBar(res, context);
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const RepsonsiveLayout(
            mobileScreenLayout: MobileScreenLayout(),
            webScreenLayout: WebScreenLayout(),
          ),
        ),
      );
    }
  }

  void navigateToLogIn() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                'https://images.unsplash.com/photo-1617957772002-57adde1156fa?q=80&w=2832&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
              ),
              fit: BoxFit.cover, // Background image
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // CaFoutQuoi Logo, adjusted to the same size as in LoginScreen
              Image.asset(
                'assets/logo_white.png',
                height: 250, // Adjusted to avoid overflow
                color: CustomColor.primaryColor,
              ),

              // Profile Image
              Stack(
                children: [
                  CircleAvatar(
                    radius: 64, // Keeping the CircleAvatar size
                    backgroundImage: _image != null
                        ? MemoryImage(_image!)
                        : const NetworkImage(
                            'https://as1.ftcdn.net/v2/jpg/05/16/27/58/1000_F_516275801_f3Fsp17x6HQK0xQgDQEELoTuERO4SsWV.jpg',
                          ) as ImageProvider,
                  ),
                  Positioned(
                    bottom: -10,
                    left: 80,
                    child: IconButton(
                      onPressed: selectImage,
                      icon: const Icon(
                        Icons.add_a_photo,
                        color: CustomColor.white70,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Email input
              Container(
                decoration: BoxDecoration(
                  color: CustomColor.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: _emailController,
                  style: const TextStyle(color: CustomColor.primaryColor),
                  decoration: InputDecoration(
                    hintText: CustomString.tonMail,
                    hintStyle: const TextStyle(color: CustomColor.white70),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Password input
              Container(
                decoration: BoxDecoration(
                  color: CustomColor.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: CustomColor.primaryColor),
                  decoration: InputDecoration(
                    hintText: CustomString.tonMotDePasse,
                    hintStyle: const TextStyle(color: CustomColor.white70),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Un petit nom and Ta localisation side by side
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: CustomColor.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        controller: _usernameController,
                        style: const TextStyle(color: CustomColor.primaryColor),
                        decoration: InputDecoration(
                          hintText: CustomString.unPetitNom,
                          hintStyle: const TextStyle(color: CustomColor.white70),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: CustomColor.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        controller: _locationController,
                        style: const TextStyle(color: CustomColor.primaryColor),
                        decoration: InputDecoration(
                          hintText: CustomString.taLocalisation,
                          hintStyle: const TextStyle(color: CustomColor.white70),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Bio input
              Container(
                decoration: BoxDecoration(
                  color: CustomColor.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: _bioController,
                  style: const TextStyle(color: CustomColor.primaryColor),
                  decoration: InputDecoration(
                    hintText: CustomString.taBio,
                    hintStyle: const TextStyle(color: CustomColor.white70),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Sign up button
              InkWell(
                onTap: signUpUser,
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [CustomColor.personnalizedPurple, Color(0xFF7900F4)],
                    ),
                  ),
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: CustomColor.primaryColor),
                        )
                      : const Text(
                          CustomString.inscriptionCapital,
                          style: TextStyle(
                            color: CustomColor.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 8),

              const Text(
                CustomString.ouCapital,
                style: TextStyle(color: CustomColor.white70),
              ),
              const SizedBox(height: 8),

              // Log in option
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    CustomString.dejaInscrit,
                    style: TextStyle(color: CustomColor.white70),
                  ),
                  GestureDetector(
                    onTap: navigateToLogIn,
                    child: const Text(
                      CustomString.jeMeConnecte,
                      style: TextStyle(
                        color: CustomColor.personnalizedPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
