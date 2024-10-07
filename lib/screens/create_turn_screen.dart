import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/create_turn_view_model.dart';
import '../widgets/organisms/turn_form.dart';
import '../utils/utils.dart';
import '../utils/styles/colors.dart';
import '../utils/styles/fonts.dart';
import '../utils/styles/string.dart';
import '../templates/standard_form_template.dart';

/// Screen for creating a new TURN event.
class CreateTurnScreen extends StatelessWidget {
  const CreateTurnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CreateTurnViewModel>(
      create: (_) => CreateTurnViewModel(),
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
              appBarTitle: const Text(
                CustomString.creerUnTurn,
                style: TextStyle(
                  fontWeight: CustomFont.fontWeightBold,
                  fontSize: CustomFont.fontSize20,
                ),
              ),
              appBarActions: [
                TextButton(
                  onPressed: viewModel.isLoading
                      ? null
                      : () {
                          viewModel.createTurn();
                        },
                  child: const Text(
                    CustomString.publier,
                    style: TextStyle(
                      color: CustomColor.white,
                      fontWeight: CustomFont.fontWeightBold,
                    ),
                  ),
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
                    : CustomString.laDate,
                moodsDisplay: viewModel.selectedMoods != null &&
                        viewModel.selectedMoods!.isNotEmpty
                    ? viewModel.selectedMoods!.join(', ')
                    : CustomString.tonMood,
                isLoading: viewModel.isLoading,
                onSubmit: viewModel.createTurn,
                inviteeSearchController: viewModel.searchController,
                selectedInvitees: viewModel.selectedInvitees,
                searchResults: viewModel.searchResults,
                isSearching: viewModel.isSearching,
                onAddInvitee: viewModel.addInvitee,
                onRemoveInvitee: viewModel.removeInvitee,
              ),
            );
          }
        },
      ),
    );
  }
}
