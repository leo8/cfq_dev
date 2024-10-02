import 'package:flutter/material.dart';

import '../../screens/create_cfq_screen.dart'; // Screen for adding CFQ
import '../../screens/create_turn_screen.dart'; // Screen for adding Turn
import '../../utils/styles/string.dart'; // String constants
import '../molecules/image_button.dart'; // Custom button with image

class SelectionButtons extends StatelessWidget {
  const SelectionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Button for adding a CFQ
        ImageButton(
          title: CustomString.caFoutQuoi, // Title for the button
          imageUrl:
              'https://images.unsplash.com/photo-1617957689233-207e3cd3c610?q=80&w=2832&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          onTap: () {
            // Navigate to AddCfqScreen when button is tapped
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const CreateCfqScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 40), // Space between buttons
        // Button for adding a Turn
        ImageButton(
          title: CustomString.caTurn, // Title for the button
          imageUrl:
              'https://images.unsplash.com/photo-1617957772002-57adde1156fa?q=80&w=2832&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          onTap: () {
            // Navigate to AddTurnScreen when button is tapped
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const CreateTurnScreen(),
              ),
            );
          },
        ),
      ],
    );
  }
}
