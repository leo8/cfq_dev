import 'package:flutter/material.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/text_styles.dart';
import '../../utils/date_time_utils.dart';

class BirthdayCard extends StatelessWidget {
  final String username;
  final DateTime birthDate;

  const BirthdayCard({
    super.key,
    required this.username,
    required this.birthDate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: CustomColor.cfqBackgroundGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Text(
              "🎂",
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: CustomTextStyle.body1,
                  children: [
                    TextSpan(
                      text: username,
                      style: CustomTextStyle.body1
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                          ' fête son anniversaire le ${DateTimeUtils.formatEventDateTime(birthDate)}',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
