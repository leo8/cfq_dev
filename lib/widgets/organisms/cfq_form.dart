import 'dart:typed_data';
import 'package:cfq_dev/widgets/atoms/buttons/custom_button.dart';
import 'package:cfq_dev/widgets/molecules/event_organizer.dart';
import 'package:flutter/material.dart';
import '../atoms/image_selectors/event_image_selector.dart';
import '../../models/user.dart' as model;
import '../atoms/texts/bordered_icon_text_field.dart';
import '../atoms/texts/cfq_bordered_icon_text_field.dart';
import '../../utils/styles/text_styles.dart';
import '../atoms/texts/custom_text_field.dart';
import '../../utils/styles/string.dart';
import '../../utils/styles/icons.dart';
import '../atoms/address_selectors/google_places_address_selector.dart';

class CfqForm extends StatelessWidget {
  final Uint8List? image;
  final VoidCallback onSelectImage;
  final TextEditingController descriptionController;
  final TextEditingController locationController;
  final TextEditingController whenController;
  final VoidCallback onSelectMoods;
  final VoidCallback onSelectDateTime;
  final String moodsDisplay;
  final String dateTimeDisplay;
  final bool isLoading;
  final VoidCallback onSubmit;
  final model.User currentUser;
  final TextEditingController inviteesController;
  final VoidCallback openInviteesSelectorScreen;
  final Function(PlaceData) onAddressSelected;
  final String submitButtonLabel;

  const CfqForm({
    super.key,
    required this.image,
    required this.onSelectImage,
    required this.descriptionController,
    required this.locationController,
    required this.whenController,
    required this.onSelectMoods,
    required this.onSelectDateTime,
    required this.moodsDisplay,
    required this.dateTimeDisplay,
    required this.isLoading,
    required this.onSubmit,
    required this.currentUser,
    required this.inviteesController,
    required this.openInviteesSelectorScreen,
    required this.onAddressSelected,
    this.submitButtonLabel = CustomString.create,
  });

  String _formatDateTimeDisplay(DateTime? startDate, DateTime? endDate) {
    if (startDate == null) return CustomString.date;

    final startDateStr =
        '${startDate.day.toString().padLeft(2, '0')}/${startDate.month.toString().padLeft(2, '0')}/${startDate.year}';
    final startTimeStr =
        '${startDate.hour.toString().padLeft(2, '0')}:${startDate.minute.toString().padLeft(2, '0')}';

    if (endDate == null) {
      return 'Le $startDateStr à $startTimeStr';
    }

    final endDateStr =
        '${endDate.day.toString().padLeft(2, '0')}/${endDate.month.toString().padLeft(2, '0')}/${endDate.year}';
    final endTimeStr =
        '${endDate.hour.toString().padLeft(2, '0')}:${endDate.minute.toString().padLeft(2, '0')}';

    final isSameDay = startDate.year == endDate.year &&
        startDate.month == endDate.month &&
        startDate.day == endDate.day;

    final isNextDay = endDate.difference(startDate).inMinutes <= 1439;

    if (isSameDay || isNextDay) {
      return 'Le $startDateStr de $startTimeStr à $endTimeStr';
    } else {
      return 'Du $startDateStr à $startTimeStr au $endDateStr à $endTimeStr';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              CustomString.cfqCapital,
              style: CustomTextStyle.title1,
            ),
          ),
          const SizedBox(height: 15),
          Center(
            child:
                EventImageSelector(image: image, onSelectImage: onSelectImage),
          ),
          const SizedBox(height: 15),
          EventOrganizer(
            profilePictureUrl: currentUser.profilePictureUrl,
            username: currentUser.username,
          ),
          const SizedBox(height: 15),
          CfqBorderedIconTextField(
            controller: whenController,
            hintText: CustomString.cfqName,
            maxLength: 24,
          ),
          const SizedBox(height: 15),
          BorderedIconTextField(
            icon: CustomIcon.eventMood,
            controller: TextEditingController(text: moodsDisplay),
            hintText: CustomString.whatMood,
            readOnly: true,
            onTap: onSelectMoods,
          ),
          const SizedBox(height: 15),
          BorderedIconTextField(
            icon: CustomIcon.calendar,
            controller: TextEditingController(text: dateTimeDisplay),
            hintText: CustomString.date,
            readOnly: true,
            onTap: onSelectDateTime,
          ),
          const SizedBox(height: 15),
          GooglePlacesAddressSelector(
            icon: CustomIcon.eventLocation,
            controller: locationController,
            hintText: CustomString.where,
            onPlaceSelected: onAddressSelected,
            showPredictions: true,
          ),
          const SizedBox(height: 15),
          CustomTextField(
            controller: descriptionController,
            hintText: CustomString.describeCfq,
            maxLines: 50,
            height: 100,
          ),
          const SizedBox(height: 15),
          BorderedIconTextField(
            icon: CustomIcon.eventInvitees,
            controller: inviteesController,
            hintText: CustomString.who,
            readOnly: true,
            onTap: openInviteesSelectorScreen,
          ),
          const SizedBox(height: 15),
          CustomButton(
            label: submitButtonLabel,
            onTap: isLoading ? () {} : onSubmit,
          ),
        ],
      ),
    );
  }
}
