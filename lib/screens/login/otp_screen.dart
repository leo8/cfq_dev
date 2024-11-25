import 'package:cfq_dev/responsive/mobile_screen_layout.dart';
import 'package:cfq_dev/responsive/repsonsive_layout_screen.dart';
import 'package:cfq_dev/responsive/web_screen_layout.dart';
import 'package:cfq_dev/screens/login/registration_pageview_controller.dart';
import 'package:cfq_dev/utils/styles/neon_background.dart';
import 'package:cfq_dev/widgets/atoms/texts/bordered_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../utils/styles/string.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/text_styles.dart';
import '../../utils/logger.dart';

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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> userUIDs = [];

// Fonction pour récupérer tous les noms d'utilisateur
  Future<void> fetchUserUID() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('users').get();
      List<String> uids = snapshot.docs.map((doc) {
        return doc['uid'] as String;
      }).toList();

      setState(() {
        userUIDs = uids;
      });
    } catch (e) {
      AppLogger.error("Erreur lors de la récupération des uid : $e");
    }
  }

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

  @override
  void initState() {
    fetchUserUID();
  }

  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return NeonBackground(
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: CustomColor.transparent,
          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Container(
              color: Colors.white.withAlpha(0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 200),
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
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 60),
                    isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () async {
                              if (otpController.text.isEmpty) {
                                Fluttertoast.showToast(
                                    msg: "Pas de code de confirmation ?",
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.TOP,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0);
                              } else {
                                Fluttertoast.cancel();
                                setState(() {
                                  isLoading = true;
                                });
                                try {
                                  final cred = PhoneAuthProvider.credential(
                                      verificationId: widget.verificationId,
                                      smsCode: otpController.text);

                                  final data = await FirebaseAuth.instance
                                      .signInWithCredential(cred);

                                  if (widget.isSign &&
                                      userUIDs.contains(data.user!.uid)) {
                                    signIn(data);
                                  } else if (!widget.isSign &&
                                      userUIDs.contains(data.user!.uid)) {
                                    signIn(data);
                                  } else if (widget.isSign &&
                                      !userUIDs.contains(data.user!.uid)) {
                                    signUp(data);
                                  } else {
                                    signUp(data);
                                  }

                                  // ignore: empty_catches
                                } catch (e) {}
                                setState(() {
                                  isLoading = false;
                                });
                              }
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
              ),
            ),
          )),
    );
  }
}
