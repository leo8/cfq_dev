import 'package:flutter/material.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import '../../../utils/styles/colors.dart';
import '../../../utils/styles/string.dart';
import '../../../utils/styles/text_styles.dart';
import '../../../utils/styles/icons.dart';
import '../../../utils/date_time_utils.dart';

class CustomDateTimeRangePicker extends StatefulWidget {
  final DateTime? startInitialDate;
  final DateTime? endInitialDate;
  final Function(DateTime start, DateTime? end) onDateTimeSelected;

  const CustomDateTimeRangePicker({
    super.key,
    this.startInitialDate,
    this.endInitialDate,
    required this.onDateTimeSelected,
  });

  @override
  State<CustomDateTimeRangePicker> createState() =>
      _CustomDateTimeRangePickerState();
}

class _CustomDateTimeRangePickerState extends State<CustomDateTimeRangePicker> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _showEndDatePicker = false;
  late DateTime _minimumDate;

  @override
  void initState() {
    super.initState();
    _minimumDate = DateTimeUtils.roundToNextFiveMinutes(DateTime.now());
    _startDate = widget.startInitialDate ?? _minimumDate;
    _endDate = widget.endInitialDate;
  }

  bool _validateDates() {
    final now = DateTimeUtils.roundToNextFiveMinutes(DateTime.now());
    if (_startDate == null || _startDate!.isBefore(now)) {
      return false;
    }
    if (_showEndDatePicker && _endDate != null) {
      // Ensure end date is at least 5 minutes after start date
      final minimumEndDate = DateTimeUtils.roundToNextFiveMinutes(_startDate!);
      if (_endDate!.isBefore(minimumEndDate.add(const Duration(minutes: 5)))) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: CustomColor.customBlack,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      CustomString.eventDateTime,
                      style: CustomTextStyle.bigBody1,
                    ),
                    const SizedBox(height: 16),
                    OmniDateTimePicker(
                      initialDate: _startDate!,
                      firstDate: _minimumDate,
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                      is24HourMode: true,
                      isShowSeconds: false,
                      minutesInterval: 5,
                      onDateTimeChanged: (dateTime) {
                        setState(() {
                          _startDate = dateTime;
                          if (_endDate != null &&
                              _endDate!.isBefore(
                                  dateTime.add(const Duration(minutes: 5)))) {
                            _endDate = DateTimeUtils.roundToNextFiveMinutes(
                                dateTime.add(const Duration(minutes: 5)));
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    if (!_showEndDatePicker)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _showEndDatePicker = true;
                          });
                        },
                        child: const Text(CustomString.addEndTime),
                      ),
                    if (_showEndDatePicker) ...[
                      const Divider(color: CustomColor.customDarkGrey),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Centered title
                          Center(
                            child: Text(
                              CustomString.endDateTime,
                              style: CustomTextStyle.bigBody1,
                            ),
                          ),
                          // Close icon positioned on the right
                          Positioned(
                            right: 0,
                            child: IconButton(
                              icon: CustomIcon.close,
                              onPressed: () {
                                setState(() {
                                  _showEndDatePicker = false;
                                  _endDate = null;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      OmniDateTimePicker(
                        initialDate: _endDate ??
                            _startDate?.add(const Duration(hours: 1)) ??
                            DateTime.now(),
                        firstDate: _startDate ?? DateTime.now(),
                        lastDate:
                            DateTime.now().add(const Duration(days: 3650)),
                        is24HourMode: true,
                        isShowSeconds: false,
                        minutesInterval: 5,
                        onDateTimeChanged: (dateTime) {
                          setState(() {
                            _endDate = dateTime;
                          });
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: CustomColor.customBlack,
                  width: 1,
                ),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColor.customDarkGrey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    CustomString.cancel,
                    style: CustomTextStyle.body1,
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _validateDates()
                      ? () {
                          widget.onDateTimeSelected(_startDate!, _endDate);
                          Navigator.pop(context);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColor.customPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    CustomString.confirm,
                    style: CustomTextStyle.body1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
