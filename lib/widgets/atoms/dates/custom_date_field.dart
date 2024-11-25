import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cfq_dev/utils/styles/colors.dart';
import '../../../utils/styles/icons.dart';
import '../../../utils/styles/text_styles.dart';
import '../../../utils/styles/string.dart';

class CustomDateField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final DateTime? selectedDate;
  final Widget? suffixIcon;
  final Function(DateTime?) onDateChanged;

  const CustomDateField({
    required this.controller,
    required this.hintText,
    this.selectedDate,
    this.suffixIcon,
    required this.onDateChanged,
    super.key,
  });

  Future<void> _selectDate(BuildContext context) async {
    // Initialize with selected date or default to 18 years ago
    final DateTime initialDate =
        selectedDate ?? DateTime.now().subtract(const Duration(days: 365 * 18));

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        DateTime? tempDate = initialDate;
        return Dialog(
          backgroundColor: CustomColor.customBlack,
          child: Container(
            height: 300,
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: CupertinoPicker(
                          itemExtent: 32,
                          backgroundColor: CustomColor.customBlack,
                          onSelectedItemChanged: (int index) {
                            tempDate = DateTime(
                              tempDate?.year ?? initialDate.year,
                              tempDate?.month ?? initialDate.month,
                              index + 1,
                            );
                          },
                          scrollController: FixedExtentScrollController(
                            initialItem: (initialDate.day - 1),
                          ),
                          children: List<Widget>.generate(31, (index) {
                            return Center(
                              child: Text(
                                '${index + 1}',
                                style: CustomTextStyle.body1,
                              ),
                            );
                          }),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: CupertinoPicker(
                          itemExtent: 32,
                          backgroundColor: CustomColor.customBlack,
                          onSelectedItemChanged: (int index) {
                            tempDate = DateTime(
                              tempDate?.year ?? initialDate.year,
                              index + 1,
                              tempDate?.day ?? initialDate.day,
                            );
                          },
                          scrollController: FixedExtentScrollController(
                            initialItem: (initialDate.month - 1),
                          ),
                          children: [
                            'Janvier',
                            'Février',
                            'Mars',
                            'Avril',
                            'Mai',
                            'Juin',
                            'Juillet',
                            'Août',
                            'Septembre',
                            'Octobre',
                            'Novembre',
                            'Décembre'
                          ]
                              .map((month) => Center(
                                    child: Text(
                                      month,
                                      style: CustomTextStyle.body1,
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.visible,
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: CupertinoPicker(
                          itemExtent: 32,
                          backgroundColor: CustomColor.customBlack,
                          onSelectedItemChanged: (int index) {
                            tempDate = DateTime(
                              DateTime.now().year - 100 + index,
                              tempDate?.month ?? initialDate.month,
                              tempDate?.day ?? initialDate.day,
                            );
                          },
                          scrollController: FixedExtentScrollController(
                            initialItem: 82, // Default to 18 years ago
                          ),
                          children: List<Widget>.generate(100, (index) {
                            return Center(
                              child: Text(
                                '${DateTime.now().year - 100 + index}',
                                style: CustomTextStyle.body1,
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        CustomString.cancel,
                        style: CustomTextStyle.body1.copyWith(
                          color: CustomColor.customPurple,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (tempDate != null) {
                          controller.text =
                              "${tempDate!.day.toString().padLeft(2, '0')}/${tempDate!.month.toString().padLeft(2, '0')}/${tempDate!.year}";
                          onDateChanged(tempDate);
                        }
                        Navigator.pop(context);
                      },
                      child: Text(
                        CustomString.confirm,
                        style: CustomTextStyle.body1.copyWith(
                          color: CustomColor.customPurple,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    // Format the initial date if it exists
    if (selectedDate != null) {
      controller.text = _formatDate(selectedDate!);
    }

    return GestureDetector(
      onTap: () => _selectDate(context),
      child: AbsorbPointer(
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            color: CustomColor.customBlack,
            border: Border.all(color: CustomColor.customWhite, width: 0.5),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                alignment: Alignment.center,
                child: CustomIcon.calendar,
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  style: CustomTextStyle.body1,
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle:
                        CustomTextStyle.body1.copyWith(color: CustomColor.grey),
                    border: InputBorder.none,
                  ),
                  readOnly: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
