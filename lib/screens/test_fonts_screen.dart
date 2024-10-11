import 'package:flutter/material.dart';
import 'package:cfq_dev/utils/styles/colors.dart';
import 'package:cfq_dev/utils/styles/text_styles.dart';

class TestFontsScreen extends StatelessWidget {
  const TestFontsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.customBlack,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 50),
              Text('HUGE TITLE',
                  style: CustomTextStyle.hugeTitle
                      .copyWith(color: CustomColor.customWhite)),
              const SizedBox(height: 20),
              Text('CFQ - HUGE TITLES',
                  style: CustomTextStyle.hugeTitle2
                      .copyWith(color: CustomColor.customWhite)),
              const SizedBox(height: 20),
              Text('CFQ - TITLES 1',
                  style: CustomTextStyle.title1
                      .copyWith(color: CustomColor.customWhite)),
              Text('CFQ - TITLES 2',
                  style: CustomTextStyle.title2
                      .copyWith(color: CustomColor.customWhite)),
              Text('CFQ - TITLES 3',
                  style: CustomTextStyle.title3
                      .copyWith(color: CustomColor.customWhite)),
              const SizedBox(height: 20),
              Text('TITLES 1',
                  style: CustomTextStyle.title1
                      .copyWith(color: CustomColor.customWhite)),
              Text('TITLES 2',
                  style: CustomTextStyle.title2
                      .copyWith(color: CustomColor.customWhite)),
              Text('TITLES 3',
                  style: CustomTextStyle.title3
                      .copyWith(color: CustomColor.customWhite)),
              const SizedBox(height: 20),
              Text('Body 1',
                  style: CustomTextStyle.body1
                      .copyWith(color: CustomColor.customWhite)),
              Text('Body 2',
                  style: CustomTextStyle.body2
                      .copyWith(color: CustomColor.customWhite)),
              Text('Body 3',
                  style: CustomTextStyle.body1
                      .copyWith(color: CustomColor.customWhite)),
              Text('Body 4',
                  style: CustomTextStyle.body2
                      .copyWith(color: CustomColor.customWhite)),
              const SizedBox(height: 10),
              Text('mini Body',
                  style: CustomTextStyle.miniBody
                      .copyWith(color: CustomColor.customWhite)),
              Text('XS Body',
                  style: CustomTextStyle.xsBody
                      .copyWith(color: CustomColor.customWhite)),
              const SizedBox(height: 20),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: CustomColor.customWhite,
                child: Text('sub + buttons',
                    style: CustomTextStyle.subButton
                        .copyWith(color: CustomColor.customBlack)),
              ),
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: CustomColor.customWhite,
                child: Text('Mini button',
                    style: CustomTextStyle.miniButton
                        .copyWith(color: CustomColor.customBlack)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
