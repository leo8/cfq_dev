import 'package:cfq_dev/screens/login/otp_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../utils/styles/string.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/text_styles.dart';
import '../../widgets/atoms/texts/bordered_text_field.dart';
import '../../utils/logger.dart';

class LoginScreenMobile extends StatefulWidget {
  const LoginScreenMobile({super.key});

  @override
  State<LoginScreenMobile> createState() => _LoginScreenMobileState();
}

class _LoginScreenMobileState extends State<LoginScreenMobile> {
  final phoneController = TextEditingController();

  bool isloading = false;
  bool isSignIn = false;
  String titleConnexion = CustomString.logInCapital;
  String buttonConnectionTitle = CustomString.logIn;
  String buttonBackTitle = CustomString.noAccountYet;

  void _toggleConnectionPage() {
    isSignIn = !isSignIn;
    setState(() {
      titleConnexion =
          isSignIn ? CustomString.signUpCapital : CustomString.logInCapital;
      buttonConnectionTitle =
          isSignIn ? CustomString.signUp : CustomString.logIn;
      buttonBackTitle =
          isSignIn ? CustomString.alreadySignedUp : CustomString.noAccountYet;
    });
  }

  void OPTAuth() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: convertPhoneNumber(),
      verificationCompleted: (phoneAuthCredential) {},
      verificationFailed: (error) {
        AppLogger.debug("@@@ error ${error.toString()}");
        AppLogger.debug("@@@ error.tenantId ${error.tenantId}");
        AppLogger.debug("@@@ error.stackTrace ${error.stackTrace.toString()}");
        AppLogger.debug("@@@ error.tenantId ${error.message}");
        AppLogger.debug("@@@ ${error.phoneNumber}");
      },
      codeSent: (verificationId, forceResendingToken) {
        setState(() {
          isloading = false;
        });
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
        AppLogger.debug("Auto Retrieval timeout");
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
                child: Image(
                  image: AssetImage('assets/images/logo_white.png'),
                ),
              ),
              const SizedBox(height: 60),
              Text(
                titleConnexion,
                textAlign: TextAlign.center,
                style: CustomTextStyle.body1
                    .copyWith(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              BorderedTextField(
                controller: phoneController,
                hintText: CustomString.yourNumber,
                keyboardType: TextInputType.number,
              ),
              /*
              Text("ou",
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.grey[300],
                  )),
              const SizedBox(height: 10),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 65,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () => {AppLogger.debug("@@@ click google")},
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
                          onPressed: () => {AppLogger.debug("@@@ click apple")},
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
                                if (phoneController.text.isEmpty) {
                                  Fluttertoast.showToast(
                                      msg: "Quel est ton num ?",
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.TOP,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                } else {
                                  Fluttertoast.cancel();
                                  setState(() {
                                    isloading = true;
                                  });
                                  OPTAuth();
                                  isloading = false;
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: CustomColor.customBlack,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7),
                                  side: const BorderSide(
                                    color: CustomColor.customWhite,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              child: Text(
                                buttonConnectionTitle,
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: CustomColor.customWhite,
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
                                  borderRadius: BorderRadius.circular(7),
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
                                  style: CustomTextStyle.body1.copyWith(
                                    color: CustomColor.customPurple,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 50)
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
