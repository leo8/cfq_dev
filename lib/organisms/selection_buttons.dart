import 'package:flutter/material.dart';
import 'package:cfq_dev/molecules/image_button.dart';
import 'package:cfq_dev/screens/add_cfq_screen.dart';
import 'package:cfq_dev/screens/add_turn_screen.dart';
import 'package:cfq_dev/utils/string.dart';

class SelectionButtons extends StatelessWidget {
  const SelectionButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ImageButton(
          title: CustomString.caFoutQuoi,
          imageUrl:
              'https://images.unsplash.com/photo-1617957689233-207e3cd3c610?q=80&w=2832&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AddCfqScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 40),
        ImageButton(
          title: CustomString.caTurn,
          imageUrl:
              'https://images.unsplash.com/photo-1617957772002-57adde1156fa?q=80&w=2832&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AddTurnScreen(),
              ),
            );
          },
        ),
      ],
    );
  }
}
