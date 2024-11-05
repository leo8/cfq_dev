import 'package:flutter/material.dart';
import '../../models/team.dart';
import '../atoms/avatars/custom_avatar.dart';
import '../atoms/texts/custom_text.dart';
import '../../utils/styles/text_styles.dart';

class TeamHeader extends StatelessWidget {
  final Team team;

  const TeamHeader({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomText(
          text: team.name,
          textStyle: CustomTextStyle.title1.copyWith(fontSize: 32),
        ),
        const SizedBox(
          height: 20,
        ),
        CustomAvatar(
          imageUrl: team.imageUrl,
          radius: 50,
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
