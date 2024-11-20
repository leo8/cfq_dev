import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/create_turn_view_model.dart';
import '../widgets/organisms/turn_form.dart';
import '../utils/styles/string.dart';
import '../models/team.dart';
import '../models/user.dart' as model;
import '../models/turn_event_model.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/icons.dart';
import '../../utils/styles/neon_background.dart';
import '../../utils/utils.dart';
import '../utils/loading_overlay.dart';

/// Screen for creating a new TURN event.
class CreateTurnScreen extends StatelessWidget {
  final Team? prefillTeam;
  final List<model.User>? prefillMembers;
  final bool isEditing;
  final Turn? turnToEdit;

  const CreateTurnScreen({
    super.key,
    this.prefillTeam,
    this.prefillMembers,
    this.isEditing = false,
    this.turnToEdit,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CreateTurnViewModel>(
      create: (_) => CreateTurnViewModel(
        prefillTeam: prefillTeam,
        prefillMembers: prefillMembers,
        isEditing: isEditing,
        turnToEdit: turnToEdit,
      ),
      child: Consumer<CreateTurnViewModel>(
        builder: (context, viewModel, child) {
          if (!viewModel.isInitialized) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            // Handle success and error messages
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (viewModel.errorMessage != null) {
                showSnackBar(viewModel.errorMessage!, context);
                viewModel.resetStatus();
              } else if (viewModel.successMessage != null) {
                showSnackBar(viewModel.successMessage!, context);
                viewModel.resetStatus();
                Navigator.of(context).pop(true);
              }
            });

            return LoadingOverlay(
              isLoading: viewModel.isLoading,
              child: NeonBackground(
                child: Scaffold(
                  backgroundColor:
                      CustomColor.transparent, // Sets the background color
                  appBar: AppBar(
                    toolbarHeight: 40,
                    automaticallyImplyLeading: false,
                    backgroundColor: CustomColor.customBlack,
                    surfaceTintColor: CustomColor.customBlack,
                    actions: [
                      IconButton(
                        icon: CustomIcon.close,
                        onPressed: () async {
                          bool confirmed = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Center(
                                  child: Text(CustomString.sureToLeave),
                                ),
                                content: const Text(
                                    CustomString.yourModificationsWillBeLost),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text(CustomString.stay),
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                  ),
                                  TextButton(
                                    child: const Text(CustomString.leave),
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirmed) {
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ],
                  ),
                  body: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal:
                            20), // Adds padding to the sides of the form
                    child: TurnForm(
                      currentUser: viewModel.currentUser!,
                      image: viewModel.turnImage,
                      onSelectImage: () => viewModel.pickTurnImage(context),
                      nameController: viewModel.turnNameController,
                      descriptionController: viewModel.descriptionController,
                      locationController: viewModel.locationController,
                      addressController: viewModel.addressController,
                      onSelectDateTime: () => viewModel.selectDateTime(context),
                      onSelectMoods: () => viewModel.selectMoods(context),
                      dateTimeDisplay: _formatDateTimeDisplay(
                        viewModel.selectedDateTime,
                        viewModel.selectedEndDateTime,
                      ),
                      moodsDisplay: viewModel.selectedMoods != null &&
                              viewModel.selectedMoods!.isNotEmpty
                          ? viewModel.selectedMoods!.join(', ')
                          : CustomString.whatMood,
                      isLoading: viewModel.isLoading,
                      onSubmit: viewModel.isEditing
                          ? viewModel.updateTurn
                          : viewModel.createTurn,
                      inviteesController: viewModel.inviteesController,
                      openInviteesSelectorScreen: () =>
                          viewModel.openInviteesSelectorScreen(context),
                      submitButtonLabel:
                          isEditing ? CustomString.update : CustomString.create,
                    ),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  String _formatDateTimeDisplay(DateTime? startDate, DateTime? endDate) {
    if (startDate == null) return CustomString.date;

    final startDateStr =
        '${startDate.day.toString().padLeft(2, '0')}/${startDate.month.toString().padLeft(2, '0')}/${startDate.year}';
    final startTimeStr =
        '${startDate.hour.toString().padLeft(2, '0')}:${startDate.minute.toString().padLeft(2, '0')}';

    // If no end date, return simple format
    if (endDate == null) {
      return 'Le $startDateStr à $startTimeStr';
    }

    final endDateStr =
        '${endDate.day.toString().padLeft(2, '0')}/${endDate.month.toString().padLeft(2, '0')}/${endDate.year}';
    final endTimeStr =
        '${endDate.hour.toString().padLeft(2, '0')}:${endDate.minute.toString().padLeft(2, '0')}';

    // Check if same day or next day
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
}
