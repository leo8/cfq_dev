import 'package:flutter/material.dart';
import '../utils/styles/colors.dart';
import '../utils/styles/icons.dart';
import '../utils/styles/text_styles.dart';
import '../utils/styles/string.dart';

class CfqInviteesScreen extends StatelessWidget {
  const CfqInviteesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        automaticallyImplyLeading: false,
        backgroundColor: CustomColor.transparent,
        actions: [
          IconButton(
            icon: CustomIcon.close,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Container(
        color: CustomColor.customBlack,
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Text(
                CustomString.inviteesCapital,
                style: CustomTextStyle.title1.copyWith(
                  color: CustomColor.customWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // The rest of the screen is empty for now
          ],
        ),
      ),
    );
  }
}
