import 'package:cfq_dev/utils/styles/neon_background.dart';
import 'package:cfq_dev/widgets/atoms/progress_bar_login/progress_bar_login.dart';
import 'package:cfq_dev/widgets/atoms/texts/bordered_text_field.dart';
import 'package:flutter/material.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/text_styles.dart';
import 'package:cfq_dev/utils/styles/string.dart';

class InscriptionFriends extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback signUp;
  final int currentPages;
  final int totalPages;

  const InscriptionFriends(
      {super.key,
      required this.onNext,
      required this.onPrevious,
      required this.currentPages,
      required this.totalPages,
      required this.signUp});

  @override
  State<InscriptionFriends> createState() => _InscriptionFriendsState();
}

class _InscriptionFriendsState extends State<InscriptionFriends> {
  final otpController = TextEditingController();
  final double constaint = 30.0;
  final int pageNumber = 2;

  @override
  Widget build(BuildContext context) {
    return NeonBackground(
      child: Padding(
        padding: EdgeInsets.all(constaint),
        child: Column(
          children: [
            const SizedBox(height: 70),
            Stack(
              children: [
                ProgressBarLogin(
                  widthProgressFull:
                      MediaQuery.of(context).size.width - constaint * 2,
                  pourcentProgression: widget.currentPages / widget.totalPages,
                )
              ],
            ),
            const SizedBox(height: 100),
            Text(
              CustomString.addYourFriendsCapital,
              textAlign: TextAlign.center,
              style: CustomTextStyle.body1.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            BorderedTextField(
              controller: otpController,
              hintText: CustomString.addFriends,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                      onPressed: () {
                        widget.signUp();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: CustomColor.customBlack,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(
                                  color: CustomColor.customWhite, width: 1.0))),
                      child: const Text(
                        CustomString.authProcessStep5,
                        style: TextStyle(
                            fontSize: 20, color: CustomColor.customWhite),
                      )),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 30,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColor.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(
                            color: CustomColor.transparent, width: 0))),
                onPressed: () {
                  widget.onPrevious();
                },
                child: Text(
                  CustomString.lastStep,
                  style: CustomTextStyle.body1.copyWith(
                    color: CustomColor.customPurple,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
