import 'package:flutter/material.dart';
import '../../../utils/styles/colors.dart';
import '../../../utils/styles/icons.dart';
import '../../../utils/styles/text_styles.dart';
import '../../../utils/styles/string.dart';

class CfqBorderedIconTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String)? onChanged;

  const CfqBorderedIconTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
  });

  @override
  State<CfqBorderedIconTextField> createState() =>
      _CfqBorderedIconTextFieldState();
}

class _CfqBorderedIconTextFieldState extends State<CfqBorderedIconTextField> {
  late final LayerLink _layerLink;
  late final OverlayEntry _overlayEntry;
  final GlobalKey _textFieldKey = GlobalKey();
  Size? _textSize;
  Size? _hintTextSize;

  @override
  void initState() {
    super.initState();
    _layerLink = LayerLink();
    widget.controller.addListener(_updateQuestionMarkPosition);

    final hintTextPainter = TextPainter(
      text: TextSpan(
          text: widget.hintText,
          style: CustomTextStyle.body2.copyWith(color: CustomColor.grey)),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    _hintTextSize = hintTextPainter.size;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry);
    });
  }

  @override
  void dispose() {
    _overlayEntry.remove();
    widget.controller.removeListener(_updateQuestionMarkPosition);
    super.dispose();
  }

  void _updateQuestionMarkPosition() {
    final text = widget.controller.text.isEmpty
        ? widget.hintText
        : widget.controller.text;
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: widget.controller.text.isEmpty
            ? CustomTextStyle.body2.copyWith(color: CustomColor.grey)
            : CustomTextStyle.body1,
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    setState(() {
      _textSize = textPainter.size;

      _overlayEntry.markNeedsBuild();
    });
  }

  void _createOverlayEntry() {
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset:
              Offset((_textSize?.width ?? _hintTextSize?.width ?? 0) + 7, 9),
          child: Material(
            color: Colors.transparent,
            child: SizedBox(
              height: 22,
              child: Text(
                CustomString.interrogationMark,
                style: CustomTextStyle.body1,
              ),
            ),
          ),
        );
      },
    );
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
            child: CompositedTransformTarget(
              link: _layerLink,
              child: TextField(
                key: _textFieldKey,
                controller: widget.controller,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle:
                      CustomTextStyle.body2.copyWith(color: CustomColor.grey),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
                style: CustomTextStyle.body1,
                onChanged: (value) {
                  widget.onChanged?.call(value);
                  _updateQuestionMarkPosition();
                },
              ),
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }
}
