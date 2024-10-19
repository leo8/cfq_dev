import 'package:flutter/material.dart';
import '../../utils/styles/text_styles.dart';
import '../../utils/styles/string.dart';

class CFQHeader extends StatelessWidget {
  final String cfqImageUrl;

  const CFQHeader({
    Key? key,
    required this.cfqImageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Image.network(
            cfqImageUrl,
            width: double.infinity,
            height: 175,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: Text(
            CustomString.cfqCapital,
            style: CustomTextStyle.hugeTitle.copyWith(
              fontSize: 32,
            ),
          ),
        ),
      ],
    );
  }
}
