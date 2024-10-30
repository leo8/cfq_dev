import 'package:flutter/material.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import '../../../utils/styles/colors.dart';
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
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Date & Time',
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
                    // Adjust end date if necessary
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
                  child: const Text('+ Add End Date/Time (Optional)'),
                ),
              if (_showEndDatePicker) ...[
                const Divider(color: CustomColor.customDarkGrey),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'End Date & Time',
                      style: CustomTextStyle.body1,
                    ),
                    IconButton(
                      icon: CustomIcon.close,
                      onPressed: () {
                        setState(() {
                          _showEndDatePicker = false;
                          _endDate = null;
                        });
                      },
                    ),
                  ],
                ),
                OmniDateTimePicker(
                  initialDate: _endDate ??
                      _startDate?.add(const Duration(hours: 1)) ??
                      DateTime.now(),
                  firstDate: _startDate ?? DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
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
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _validateDates()
                        ? () {
                            widget.onDateTimeSelected(_startDate!, _endDate);
                            Navigator.pop(context);
                          }
                        : null,
                    child: const Text('Confirm'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
