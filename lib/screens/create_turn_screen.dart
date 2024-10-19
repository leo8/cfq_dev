import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/create_turn_view_model.dart';
import '../widgets/organisms/turn_form.dart';
import '../utils/styles/string.dart';
import '../models/team.dart';
import '../models/user.dart' as model;
import '../../utils/styles/colors.dart';
import '../../utils/styles/icons.dart';
import '../../utils/styles/neon_background.dart';
import '../../utils/utils.dart';

/// Screen for creating a new TURN event.
class CreateTurnScreen extends StatelessWidget {
  final Team? prefillTeam;
  final List<model.User>? prefillMembers;

  const CreateTurnScreen({super.key, this.prefillTeam, this.prefillMembers});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CreateTurnViewModel>(
      create: (_) => CreateTurnViewModel(
        prefillTeam: prefillTeam,
        prefillMembers: prefillMembers,
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

                // Optionally navigate back to previous screen
                Navigator.of(context).pop();
              }
            });

            return NeonBackground(
              child: Scaffold(
                backgroundColor:
                    CustomColor.transparent, // Sets the background color
                appBar: AppBar(
                  toolbarHeight: 40,
                  automaticallyImplyLeading: false,
                  backgroundColor: CustomColor.transparent,
                  actions: [
                    IconButton(
                      icon: CustomIcon.close,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                body: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20), // Adds padding to the sides of the form
                  child: TurnForm(
                    currentUser: viewModel.currentUser!,
                    image: viewModel.turnImage,
                    onSelectImage: viewModel.pickTurnImage,
                    nameController: viewModel.turnNameController,
                    descriptionController: viewModel.descriptionController,
                    locationController: viewModel.locationController,
                    addressController: viewModel.addressController,
                    onSelectDateTime: () => viewModel.selectDateTime(context),
                    onSelectMoods: () => viewModel.selectMoods(context),
                    dateTimeDisplay: viewModel.selectedDateTime != null
                        ? '${viewModel.selectedDateTime!.day}/${viewModel.selectedDateTime!.month}/${viewModel.selectedDateTime!.year}'
                        : CustomString.date,
                    moodsDisplay: viewModel.selectedMoods != null &&
                            viewModel.selectedMoods!.isNotEmpty
                        ? viewModel.selectedMoods!.join(', ')
                        : CustomString.whatMood,
                    isLoading: viewModel.isLoading,
                    onSubmit: viewModel.createTurn,
                    inviteesController: viewModel.inviteesController,
                    openInviteesSelectorScreen: () =>
                        viewModel.openInviteesSelectorScreen(context),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
