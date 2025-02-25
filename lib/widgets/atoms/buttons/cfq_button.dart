import 'package:flutter/material.dart';
import 'package:cfq_dev/screens/create_cfq_screen.dart';
import 'package:cfq_dev/utils/logger.dart';
import 'package:cfq_dev/models/user.dart' as model;
import 'package:cfq_dev/models/team.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CfqButton extends StatelessWidget {
  final Team? prefillTeam;
  final List<model.User>? prefillMembers;

  const CfqButton({
    super.key,
    this.prefillTeam,
    this.prefillMembers,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppLogger.debug("Navigating to CreateCfqScreen");
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => CreateCfqScreen(
                    prefillTeam: prefillTeam,
                    prefillMembers: prefillMembers,
                  )),
        );
      },
      child: SvgPicture.asset(
        'assets/images/cfq_button.svg',
        width: 60,
        height: 60,
      ),
    );
  }
}
