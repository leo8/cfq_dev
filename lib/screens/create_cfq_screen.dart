import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/create_cfq_view_model.dart';
import '../widgets/organisms/cfq_form.dart';
import '../utils/styles/string.dart';
import '../utils/styles/text_styles.dart';
import '../templates/standard_form_template.dart';
import '../models/team.dart';
import '../models/user.dart' as model;

/// Screen for creating a new CFQ event.
class CreateCfqScreen extends StatelessWidget {
  final Team? prefillTeam;
  final List<model.User>? prefillMembers;

  const CreateCfqScreen({super.key, this.prefillTeam, this.prefillMembers});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CreateCfqViewModel>(
      create: (_) => CreateCfqViewModel(
        prefillTeam: prefillTeam,
        prefillMembers: prefillMembers,
      ),
      child: Consumer<CreateCfqViewModel>(
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
              appBarTitle:
                  Text(CustomString.createCfq, style: CustomTextStyle.title3),
              appBarActions: [
                TextButton(
                  onPressed: viewModel.isLoading
                      ? null
                      : () {
                          viewModel.createCfq();
                        },
                  child:
                      Text(CustomString.publier, style: CustomTextStyle.title3),
                ),
              ],
              onBackPressed: () {
                Navigator.of(context).pop();
              },
              body: CfqForm(
                currentUser: viewModel.currentUser!,
                image: viewModel.cfqImage,
                onSelectImage: viewModel.pickCfqImage,
                nameController: viewModel.cfqNameController,
                descriptionController: viewModel.descriptionController,
                locationController: viewModel.locationController,
                whenController: viewModel.whenController,
                onSelectMoods: () => viewModel.selectMoods(context),
                moodsDisplay: viewModel.selectedMoods != null &&
                        viewModel.selectedMoods!.isNotEmpty
                    ? viewModel.selectedMoods!.join(', ')
                    : CustomString.whatMood,
                isLoading: viewModel.isLoading,
                onSubmit: viewModel.createCfq,
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
