import 'package:cfq_dev/widgets/atoms/buttons/turn_button.dart';
import '../atoms/buttons/cfq_button.dart';
import 'package:flutter/material.dart';
import '../molecules/team_option_button.dart';
import '../../utils/styles/string.dart';

class TeamOptions extends StatelessWidget {
  const TeamOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TeamOptionButton(
          icon: Icons.person_add,
          label: CustomString.ajouter,
          onPressed: () {},
        ),
        TurnButton(),
        CfqButton(),
        TeamOptionButton(
          icon: Icons.exit_to_app,
          label: 'Quitter',
          onPressed: () {},
        ),
      ],
    );
  }
}