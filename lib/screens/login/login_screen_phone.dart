import 'dart:developer';
import 'package:cfq_dev/providers/auth_methods.dart';
import 'package:cfq_dev/responsive/mobile_screen_layout.dart';
import 'package:cfq_dev/responsive/repsonsive_layout_screen.dart';
import 'package:cfq_dev/responsive/web_screen_layout.dart';
import 'package:cfq_dev/screens/login/otp_screen.dart';
import 'package:cfq_dev/screens/login/registration_pageview_controller.dart';
import 'package:cfq_dev/screens/thread_screen.dart';
import 'package:cfq_dev/utils/styles/neon_background.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreenMobile extends StatefulWidget {
  const LoginScreenMobile({super.key});

  @override
  State<LoginScreenMobile> createState() => _LoginScreenMobileState();
}

class _LoginScreenMobileState extends State<LoginScreenMobile> {
  final phoneController = TextEditingController();

  bool isloading = false;
  bool isSignIn = true;
  String titleConnexion = "INSCRIPTION";
  String buttonConnectionTitle = "inscrit toi";
  String buttonBackTitle = "Deja un compte";

  void _toggleConnectionPage() {
    isSignIn = !isSignIn;
    setState(() {
      titleConnexion = isSignIn ? "INSCRIPTION" : "CONNEXION";
      buttonConnectionTitle = isSignIn ? "inscrit toi" : "Connencte toi";
      buttonBackTitle =
          isSignIn ? "Deja un compte ?" : "Pas encore de compte ?";
    });
  }

  void OPTAuth() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: convertPhoneNumber(),
      verificationCompleted: (phoneAuthCredential) {},
      verificationFailed: (error) {
        log("@@@ error ${error.toString()}");
        log("@@@ error.tenantId ${error.tenantId}");
        log("@@@ error.stackTrace ${error.stackTrace.toString()}");
        log("@@@ error.tenantId ${error.message}");
        log("@@@ ${error.phoneNumber}");
      },
      codeSent: (verificationId, forceResendingToken) {
        setState(() {
          isloading = false;
        });
        log("here");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPScreen(
              verificationId: verificationId,
              isSign: isSignIn,
            ),
          ),
        );
      },
      codeAutoRetrievalTimeout: (verificationId) {
        log("Auto Retrieval timeout");
      },
    );
  }

  String convertPhoneNumber() {
    return phoneController.text.replaceFirst(RegExp('0'), '+33');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Column(
            children: [
              const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child:
                      Image(image: AssetImage('assets/images/logo_white.png'))),
              Text(titleConnexion,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, color: Colors.white)),
              const SizedBox(height: 40),
              TextField(
                keyboardType: TextInputType.phone,
                controller: phoneController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    fillColor: Colors.black,
                    filled: true,
                    hintText: "Ton num ...",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none)),
              ),
              const SizedBox(height: 20),
              Text("ou",
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.grey[300],
                  )),
              const SizedBox(height: 10),
              /*
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 65,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () => {log("@@@ click google")},
                        child: const Image(
                          image: AssetImage("assets/google_logo.png"),
                          height: 20,
                          width: 20,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    SizedBox(
                      width: 65,
                      height: 40,
                      child: ElevatedButton(
                          onPressed: () => {log("@@@ click apple")},
                          child: const Image(
                            image: AssetImage("assets/apple_logo.png"),
                            height: 20,
                            width: 20,
                          )),
                    )
                  ],
                ),
              ),
              */
              isloading
                  ? const CircularProgressIndicator()
                  : Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () async {
                                setState(() {
                                  isloading = true;
                                });
                                OPTAuth();
                                isloading = false;
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: const BorderSide(
                                    color: Colors.white30,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              child: Text(
                                buttonConnectionTitle,
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            height: 30,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: const BorderSide(
                                    color: Colors.transparent,
                                    width: 0,
                                  ),
                                ),
                              ),
                              onPressed: () {
                                _toggleConnectionPage();
                              },
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  buttonBackTitle,
                                  style: const TextStyle(
                                    fontSize: 25,
                                    color: Colors.purple,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }
}
