import 'package:flutter/material.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/text_styles.dart';
import '../../utils/styles/icons.dart';
import '../../utils/date_time_utils.dart';
import '../../utils/styles/string.dart';

class TurnHeader extends StatelessWidget {
  final String turnImageUrl;
  final DateTime eventDateTime;
  final bool isExpanded;

  const TurnHeader({
    Key? key,
    required this.turnImageUrl,
    required this.eventDateTime,
    required this.isExpanded,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Image.network(
            turnImageUrl,
            width: double.infinity,
            height: 175,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: isExpanded ? 30 : 10,
          left: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: CustomColor.customBlack.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  eventDateTime.day.toString().padLeft(2, '0'),
                  style: CustomTextStyle.bigBody1.copyWith(
                    fontSize: 26,
                    height: 1.05,
                  ),
                ),
                Text(
                  DateTimeUtils.getMonthAbbreviation(eventDateTime.month)
                      .toUpperCase(),
                  style: CustomTextStyle.body2.copyWith(
                    fontSize: 18,
                    height: 1.05,
                  ),
                ),
              ],
            ),
          ),
        ),
        isExpanded
            ? Positioned(
                top: 10,
                child: Center(
                  child: Text(
                    CustomString.turnCapital,
                    style: CustomTextStyle.hugeTitle.copyWith(
                      fontSize: 32,
                    ),
                  ),
                ),
              )
            : Positioned(
                top: 30,
                right: 10,
                child: Text(
                  CustomString.turnCapital,
                  style: CustomTextStyle.hugeTitle.copyWith(
                    fontSize: 32,
                  ),
                ),
              ),
        if (isExpanded)
          Positioned(
            top: 30,
            right: 10,
            child: IconButton(
              icon: CustomIcon.close,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
      ],
    );
  }
}
