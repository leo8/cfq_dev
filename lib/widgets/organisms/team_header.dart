import 'package:flutter/material.dart';
import '../../models/team.dart';
import '../atoms/avatars/custom_avatar.dart';
import '../atoms/texts/custom_text.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/fonts.dart';

class TeamHeader extends StatelessWidget {
  final Team team;

  const TeamHeader({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomAvatar(
          imageUrl: team.imageUrl,
          radius: 50,
        ),
        const SizedBox(height: 10),
        CustomText(
          text: team.name,
          color: CustomColor.white,
          fontSize: CustomFont.fontSize24,
          fontWeight: CustomFont.fontWeightBold,
        ),
      ],
    );
  }
}