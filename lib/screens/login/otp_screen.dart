import 'dart:developer';
import 'package:cfq_dev/responsive/mobile_screen_layout.dart';
import 'package:cfq_dev/responsive/repsonsive_layout_screen.dart';
import 'package:cfq_dev/responsive/web_screen_layout.dart';
import 'package:cfq_dev/screens/login/registration_pageview_controller.dart';
import 'package:cfq_dev/utils/styles/neon_background.dart';
import 'package:cfq_dev/widgets/atoms/texts/bordered_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../utils/styles/string.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/text_styles.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen(
      {super.key, required this.verificationId, required this.isSign});
  final String verificationId;
  final bool isSign;

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final otpController = TextEditingController();

  void signUp(UserCredential cred) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => NeonBackground(
              child: RegistrationFlow(
            cred: cred,
          )),
        ));
  }

  void signIn(UserCredential cred) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => NeonBackground(
            child: RepsonsiveLayout(
          mobileScreenLayout: MobileScreenLayout(
            uid: cred.user!.uid,
          ),
          webScreenLayout: WebScreenLayout(),
        )),
      ),
      (route) => false,
    );
  }

  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return NeonBackground(
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: CustomColor.transparent,
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  CustomString.verificationCodeCapital,
                  textAlign: TextAlign.center,
                  style: CustomTextStyle.body1.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                BorderedTextField(
                  controller: otpController,
                  hintText: CustomString.yourVerificationCode,
                ),
                const SizedBox(height: 40),
                isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            isLoading = true;
                          });
                          try {
                            final cred = PhoneAuthProvider.credential(
                                verificationId: widget.verificationId,
                                smsCode: otpController.text);

                            final test = await FirebaseAuth.instance
                                .signInWithCredential(cred);
                            log("@@@ ${cred}");
                            widget.isSign ? signUp(test) : signIn(test);
                          } catch (e) {
                            log(e.toString());
                          }
                          setState(() {
                            isLoading = false;
                          });
                        },
                        child: Text(
                          CustomString.check,
                          style: CustomTextStyle.bigBody1.copyWith(
                            color: CustomColor.customPurple,
                          ),
                        ),
                      )
              ],
            ),
          )),
    );
  }
}
