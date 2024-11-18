import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/text_styles.dart';
import '../../utils/styles/string.dart';
import '../../utils/styles/neon_background.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.transparent,
      body: NeonBackground(
        child: Stack(
          children: [
            // SVG Map
            Positioned.fill(
              child: SvgPicture.asset(
                'assets/images/map_screen.svg',
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  CustomColor.customWhite.withOpacity(0.25),
                  BlendMode.dstATop,
                ),
              ),
            ),
            // Overlay Text
            Center(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: CustomColor.customBlack.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  CustomString.upcomingFeatureCapital,
                  style: CustomTextStyle.hugeTitle2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
