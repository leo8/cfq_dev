import 'dart:developer';

import 'package:cfq_dev/utils/styles/neon_background.dart';
import 'package:cfq_dev/utils/styles/string.dart';
import 'package:cfq_dev/widgets/atoms/dates/custom_date_field.dart';
import 'package:cfq_dev/widgets/atoms/progress_bar_login/progress_bar_login.dart';
import 'package:flutter/material.dart';

class InscriptionBirthdayDate extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final int currentPages;
  final int totalPages;
  final TextEditingController birthdayTextController;
  final DateTime? selectedBirthDate;
  final Function(DateTime?)
      onBirthDateChanged; // Callback for changes in birth date

  const InscriptionBirthdayDate(
      {super.key,
      required this.onNext,
      required this.onPrevious,
      required this.currentPages,
      required this.totalPages,
      required this.birthdayTextController,
      required this.selectedBirthDate,
      required this.onBirthDateChanged});

  @override
  State<InscriptionBirthdayDate> createState() =>
      _InscriptionBirthdayDateState();
}

class _InscriptionBirthdayDateState extends State<InscriptionBirthdayDate> {
  final otpController = TextEditingController();
  final double constaint = 30.0;

  void test(DateTime) {
    log("@@@ test ${widget.birthdayTextController.text}");
  }

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
            const Text(
              "TA DATE DE NAISSANCE",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
            const SizedBox(height: 40),
            CustomDateField(
              controller: widget.birthdayTextController,
              hintText: CustomString.yourBirthdate, // "Your Birth Date"
              selectedDate:
                  widget.selectedBirthDate, // Pass the currently selected date
              onDateChanged: widget.onBirthDateChanged,
              // Trigger callback on date selection
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
                          backgroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(
                                  color: Colors.white30, width: 1.0))),
                      child: const Text(
                        "Verify",
                        style: TextStyle(fontSize: 20, color: Colors.white),
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
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(
                              color: Colors.transparent, width: 0))),
                  onPressed: () {
                    widget.onPrevious();
                  },
                  child: const Text(
                    "Revenir en arrière",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.purple),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
