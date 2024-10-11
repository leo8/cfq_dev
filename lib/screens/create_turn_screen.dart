import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/create_turn_view_model.dart';
import '../widgets/organisms/turn_form.dart';
import '../utils/styles/string.dart';
import '../templates/standard_form_template.dart';
import '../models/team.dart';
import '../models/user.dart' as model;
import '../../utils/styles/text_styles.dart';

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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(viewModel.errorMessage!)),
                );
                viewModel.resetStatus();
              } else if (viewModel.successMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(viewModel.successMessage!)),
                );
                viewModel.resetStatus();

                // Optionally navigate back to previous screen
                Navigator.of(context).pop();
              }
            });

            return StandardFormTemplate(
              appBarTitle: Text(
                CustomString.createTurn,
                style: CustomTextStyle.title3,
              ),
              appBarActions: [
                TextButton(
                  onPressed: viewModel.isLoading
                      ? null
                      : () {
                          viewModel.createTurn();
                        },
                  child:
                      Text(CustomString.publier, style: CustomTextStyle.title3),
                ),
              ],
              onBackPressed: () {
                Navigator.of(context).pop();
              },
              body: TurnForm(
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
                inviteeSearchController: viewModel.searchController,
                selectedInvitees: viewModel.selectedInvitees,
                searchResults: viewModel.searchResults,
                isSearching: viewModel.isSearching,
                onAddInvitee: viewModel.addInvitee,
                onRemoveInvitee: viewModel.removeInvitee,
                userTeams: viewModel.userTeams,
                selectedTeams: viewModel.selectedTeamInvitees,
                onAddTeam: viewModel.addTeam,
                onRemoveTeam: viewModel.removeTeam,
                onSearch: viewModel.performSearch,
                onSelectEverybody: viewModel.selectEverybody,
                isEverybodySelected: viewModel.isEverybodySelected,
              ),
            );
          }
        },
      ),
    );
  }
}
