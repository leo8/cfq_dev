import 'package:flutter/material.dart';
import 'package:cfq_dev/screens/create_turn_screen.dart';
import 'package:cfq_dev/utils/logger.dart';
import 'package:cfq_dev/models/team.dart';
import 'package:cfq_dev/models/user.dart' as model;
import 'package:flutter_svg/flutter_svg.dart';

class TurnButton extends StatelessWidget {
  final Team? prefillTeam;
  final List<model.User>? prefillMembers;

  const TurnButton({
    super.key,
    this.prefillTeam,
    this.prefillMembers,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppLogger.debug("Navigating to AddTurnScreen");
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => CreateTurnScreen(
                    prefillTeam: prefillTeam,
                    prefillMembers: prefillMembers,
                  )),
        );
      },
      child: SvgPicture.asset(
        'assets/images/turn_button.svg',
        width: 60,
        height: 60,
      ),
    );
  }
}
