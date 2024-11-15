import 'package:cfq_dev/utils/styles/neon_background.dart';
import 'package:cfq_dev/widgets/atoms/progress_bar_login/progress_bar_login.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../utils/styles/string.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/text_styles.dart';
import '../../widgets/atoms/texts/bordered_text_field.dart';
import '../../screens/login/login_screen_phone.dart';

class Inscription extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final int currentPages;
  final int totalPages;
  final TextEditingController nameTextController;
  final List<String> userNames;

  const Inscription(
      {super.key,
      required this.onNext,
      required this.onPrevious,
      required this.currentPages,
      required this.totalPages,
      required this.nameTextController,
      required this.userNames});

  @override
  State<Inscription> createState() => _InscriptionState();
}

class _InscriptionState extends State<Inscription> {
  final otpController = TextEditingController();
  final double constaint = 30.0;

  bool userNameIsAlreadyTaken(userName) {
    return widget.userNames.contains(userName);
  }

  @override
  Widget build(BuildContext context) {
    return NeonBackground(
        child: Padding(
      padding: EdgeInsets.all(constaint),
      child: Column(
        children: [
          const SizedBox(height: 70),
          ProgressBarLogin(
            widthProgressFull:
                MediaQuery.of(context).size.width - constaint * 2,
            pourcentProgression: widget.currentPages / widget.totalPages,
          ),
          const SizedBox(height: 100),
          Text(
            CustomString.yourUsernameCapital,
            textAlign: TextAlign.center,
            style: CustomTextStyle.body1.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),
          BorderedTextField(
            controller: widget.nameTextController,
            hintText: CustomString.yourUsername,
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
                      if (widget.nameTextController.text.isEmpty) {
                        Fluttertoast.showToast(
                            msg: "Comment on t'appelle ?",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.TOP,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0);
                      } else {
                        if (userNameIsAlreadyTaken(
                            widget.nameTextController.text)) {
                          Fluttertoast.showToast(
                              msg: CustomString.usernameAlreadyTaken,
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.TOP,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        } else {
                          Fluttertoast.cancel();
                          widget.onNext();
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: CustomColor.customBlack,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                            side: const BorderSide(
                                color: CustomColor.customWhite, width: 1.0))),
                    child: const Text(
                      CustomString.authProcessStep1,
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
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const NeonBackground(
                      child: LoginScreenMobile(),
                    ),
                  ),
                  (route) => false,
                );
              },
              child: Text(
                CustomString.backToLogInScreen,
                style: CustomTextStyle.body1.copyWith(
                  color: CustomColor.customPurple,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 50,
          ),
        ],
      ),
    ));
  }
}
