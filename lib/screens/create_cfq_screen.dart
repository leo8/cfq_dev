import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/create_cfq_view_model.dart';
import '../widgets/organisms/cfq_form.dart';
import '../utils/styles/string.dart';
import '../utils/styles/colors.dart';
import '../utils/styles/icons.dart';
import '../utils/styles/neon_background.dart';
import '../models/team.dart';
import '../models/user.dart' as model;
import '../../utils/utils.dart';

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
                  child: CfqForm(
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
