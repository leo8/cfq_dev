import 'package:cfq_dev/utils/fonts.dart';
import 'package:cfq_dev/utils/string.dart';
import 'package:flutter/material.dart';
import 'package:cfq_dev/screens/add_turn_screen.dart';
import 'package:cfq_dev/screens/add_cfq_screen.dart';
import 'package:cfq_dev/utils/colors.dart';

class AddPostScreen extends StatelessWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.mobileBackgroundColor,
      appBar: AppBar(
        backgroundColor: CustomColor.mobileBackgroundColor,
        centerTitle: true,
        title: const Text(
          CustomString.publier,
          style: TextStyle(
            fontWeight: CustomFont.fontWeightBold,
            fontSize: CustomFont.fontSize20,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Button for 'Ça fout quoi ?' with image as background and increased height
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddCfqScreen(),
                  ),
                );
              },
              child: Container(
                height: 180, // Increase the height to make the button taller
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1617957689233-207e3cd3c610?q=80&w=2832&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                    ),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      CustomColor.deepPurpleAccent, // Tint overlay
                      BlendMode.overlay,
                    ),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: CustomColor.personnalizedPurple,
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset: Offset(0, 5), // Shadow position
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    CustomString.caFoutQuoi,
                    style: TextStyle(
                      fontSize: CustomFont.fontSize30,
                      fontWeight: CustomFont.fontWeightBold,
                      color: CustomColor.primaryColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Button for 'Ça turn' with image as background and increased height
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddTurnScreen(),
                  ),
                );
              },
              child: Container(
                height: 180, // Increase the height to make the button taller
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1617957772002-57adde1156fa?q=80&w=2832&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                    ),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      CustomColor.deepPurpleAccent, // Tint overlay
                      BlendMode.overlay,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (CustomColor.deepPurpleAccent[800] ??
                              Colors.deepPurpleAccent)
                          .withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset: const Offset(0, 5), // Shadow position
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    CustomString.caTurn,
                    style: TextStyle(
                      fontSize: CustomFont.fontSize30,
                      fontWeight: CustomFont.fontWeightBold,
                      color: CustomColor.primaryColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
