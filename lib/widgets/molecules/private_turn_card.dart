import 'package:flutter/material.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/text_styles.dart';
import '../../utils/date_time_utils.dart';

class PrivateTurnCard extends StatelessWidget {
  final DateTime eventDateTime;

  const PrivateTurnCard({
    super.key,
    required this.eventDateTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: CustomColor.turnBackgroundGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lock,
            color: CustomColor.customWhite,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Participe à un turn privé   -   ${DateTimeUtils.formatEventDateTime(eventDateTime)}',
              style: CustomTextStyle.body1,
            ),
          ),
        ],
      ),
    );
  }
}
