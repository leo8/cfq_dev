import 'dart:typed_data';

import 'package:cfq_dev/utils/styles/neon_background.dart';
import 'package:cfq_dev/widgets/atoms/avatars/profile_image_avatar.dart';
import 'package:cfq_dev/widgets/atoms/progress_bar_login/progress_bar_login.dart';
import 'package:flutter/material.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/text_styles.dart';
import 'package:cfq_dev/utils/styles/string.dart';

class LoginPhoto extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final int currentPages;
  final int totalPages;
  final Uint8List? image;
  final VoidCallback onImageSelected;

  const LoginPhoto(
      {super.key,
      required this.onNext,
      required this.onPrevious,
      required this.currentPages,
      required this.totalPages,
      required this.image,
      required this.onImageSelected});

  @override
  State<LoginPhoto> createState() => _LoginPhotoState();
}

class _LoginPhotoState extends State<LoginPhoto> {
  final otpController = TextEditingController();
  final double constaint = 30.0;
  final int pageNumber = 3;

  @override
  Widget build(BuildContext context) {
    return NeonBackground(
      child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: EdgeInsets.all(constaint),
            child: Column(
              children: [
                const SizedBox(height: 70),
                Stack(
                  children: [
                    ProgressBarLogin(
                      widthProgressFull:
                          MediaQuery.of(context).size.width - constaint * 2,
                      pourcentProgression:
                          widget.currentPages / widget.totalPages,
                    )
                  ],
                ),
                const SizedBox(height: 100),
                Text(
                  CustomString.profilePictureCapital,
                  textAlign: TextAlign.center,
                  style: CustomTextStyle.body1.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                ProfileImageAvatar(
                  image: widget.image,
                  onImageSelected: widget.onImageSelected,
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                          onPressed: () {
                            widget.onNext();
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: CustomColor.customBlack,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: const BorderSide(
                                      color: CustomColor.customWhite,
                                      width: 1.0))),
                          child: const Text(
                            CustomString.authProcessStep3,
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
                ),
                const SizedBox(
                  height: 50,
                ),
              ],
            ),
          )),
    );
  }
}
