import 'package:cfq_dev/utils/styles/neon_background.dart';
import 'package:cfq_dev/widgets/atoms/progress_bar_login/progress_bar_login.dart';
import 'package:flutter/material.dart';

class InscriptionLocalisation extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final int currentPages;
  final int totalPages;
  final TextEditingController localisationTextController;

  const InscriptionLocalisation(
      {super.key,
      required this.onNext,
      required this.onPrevious,
      required this.currentPages,
      required this.totalPages,
      required this.localisationTextController});

  @override
  State<InscriptionLocalisation> createState() =>
      _InscriptionLocalisationState();
}

class _InscriptionLocalisationState extends State<InscriptionLocalisation> {
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
            const Text(
              "TA LOCALISATION",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: widget.localisationTextController,
              keyboardType: TextInputType.name,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                  fillColor: Colors.black,
                  filled: true,
                  hintText: "Paris",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: Colors.white, width: 1.0))),
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
