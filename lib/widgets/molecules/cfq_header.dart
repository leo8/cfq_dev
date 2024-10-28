import 'package:flutter/material.dart';
import '../../utils/styles/text_styles.dart';
import '../../utils/styles/string.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/icons.dart';
import '../../utils/logger.dart';

class CFQHeader extends StatelessWidget {
  final String cfqImageUrl;
  final String when;
  final bool isExpanded;
  final VoidCallback? onClose;

  const CFQHeader({
    Key? key,
    required this.cfqImageUrl,
    required this.when,
    this.isExpanded = false,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: cfqImageUrl != ''
              ? Image.network(
                  cfqImageUrl,
                  width: double.infinity,
                  height: isExpanded ? 275 : 175,
                  fit: BoxFit.cover,
                )
              : isExpanded
                  ? Container(
                      decoration: const BoxDecoration(
                          gradient: CustomColor.cfqBackgroundGradient),
                      width: double.infinity,
                      height: 275,
                    )
                  : Container(
                      color: CustomColor.transparent,
                      width: double.infinity,
                      height: 75,
                    ),
        ),
        isExpanded
            ? Positioned.fill(
                top: -130,
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    CustomString.cfqCapital,
                    style: CustomTextStyle.hugeTitle.copyWith(
                      fontSize: 32,
                    ),
                  ),
                ),
              )
            : Positioned(
                top: 10,
                right: 10,
                child: Text(
                  CustomString.cfqCapital,
                  style: CustomTextStyle.hugeTitle.copyWith(
                    fontSize: 32,
                  ),
                ),
              ),
        if (isExpanded)
          Positioned(
            bottom: 10,
            left: 10,
            child: RichText(
              text: TextSpan(
                style: CustomTextStyle.hugeTitle.copyWith(
                  fontSize: 28,
                  letterSpacing: 1.4,
                ),
                children: [
                  const TextSpan(text: 'ÇFQ '),
                  TextSpan(
                    text: when.toUpperCase(),
                    style: const TextStyle(color: CustomColor.customPurple),
                  ),
                  const TextSpan(text: ' ?'),
                ],
              ),
            ),
          ),
        if (isExpanded)
          Positioned(
            top: 65,
            right: 20,
            child: GestureDetector(
              onTap: () {
                AppLogger.debug('Close button tapped in CFQHeader');
                if (onClose != null) {
                  onClose!();
                } else {
                  AppLogger.warning('onClose callback is null in CFQHeader');
                }
              },
              child: const Center(child: CustomIcon.close),
            ),
          ),
      ],
    );
  }
}
