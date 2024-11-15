import 'package:flutter/material.dart';
import '../../../utils/styles/colors.dart';
import '../../../utils/styles/icons.dart';
import '../../../utils/styles/text_styles.dart';
import '../../../utils/styles/string.dart';

class CfqBorderedIconTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String)? onChanged;
  final int? maxLength;

  const CfqBorderedIconTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.maxLength,
  });

  @override
  State<CfqBorderedIconTextField> createState() =>
      _CfqBorderedIconTextFieldState();
}

class _CfqBorderedIconTextFieldState extends State<CfqBorderedIconTextField> {
  Size? _textSize;
  Size? _hintTextSize;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateTextSize);
    _calculateHintTextSize();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateTextSize);
    super.dispose();
  }

  void _calculateHintTextSize() {
    final hintTextPainter = TextPainter(
      text: TextSpan(
        text: widget.hintText,
        style: CustomTextStyle.body2.copyWith(color: CustomColor.grey),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    _hintTextSize = hintTextPainter.size;
  }

  void _updateTextSize() {
    if (!mounted) return;

    final text = widget.controller.text;
    if (text.isEmpty) {
      setState(() => _textSize = null);
      return;
    }

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: CustomTextStyle.body1,
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    setState(() => _textSize = textPainter.size);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46.0,
      decoration: BoxDecoration(
        color: CustomColor.customBlack,
        border: Border.all(color: CustomColor.customWhite, width: 0.5),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            alignment: Alignment.center,
            child: CustomIcon.eventTitle,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Text(
              '${CustomString.cfqCapital} ',
              style: CustomTextStyle.body1,
            ),
          ),
          Expanded(
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                TextField(
                  controller: widget.controller,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle:
                        CustomTextStyle.body2.copyWith(color: CustomColor.grey),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    counterText: '',
                  ),
                  style: CustomTextStyle.body1,
                  onChanged: (value) {
                    widget.onChanged?.call(value);
                    _updateTextSize();
                  },
                  maxLength: widget.maxLength,
                ),
                Positioned(
                  left: (_textSize?.width ?? _hintTextSize?.width ?? 0) + 15,
                  top: 8,
                  child: SizedBox(
                    height: 22,
                    child: Text(
                      CustomString.interrogationMark,
                      style: CustomTextStyle.body1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }
}
