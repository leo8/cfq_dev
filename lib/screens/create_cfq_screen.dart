import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/create_cfq_view_model.dart';
import '../widgets/organisms/cfq_form.dart';
import '../utils/utils.dart';
import '../utils/styles/colors.dart';
import '../utils/styles/fonts.dart';
import '../utils/styles/string.dart';
import '../templates/standard_form_template.dart';

/// Screen for creating a new CFQ event.
class CreateCfqScreen extends StatelessWidget {
  const CreateCfqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CreateCfqViewModel>(
      create: (_) => CreateCfqViewModel(),
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
              appBarTitle: const Text(
                CustomString.creerUnCfq,
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
                          viewModel.createCfq();
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
                    : CustomString.tonMood,
                isLoading: viewModel.isLoading,
                onSubmit: viewModel.createCfq,
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
