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
import '../utils/utils.dart';
import '../utils/date_time_utils.dart';
import '../utils/loading_overlay.dart';
import '../models/cfq_event_model.dart';

/// Screen for creating a new CFQ event.
class CreateCfqScreen extends StatelessWidget {
  final Team? prefillTeam;
  final List<model.User>? prefillMembers;
  final bool isEditing;
  final Cfq? cfqToEdit;

  const CreateCfqScreen({
    super.key,
    this.prefillTeam,
    this.prefillMembers,
    this.isEditing = false,
    this.cfqToEdit,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CreateCfqViewModel>(
      create: (_) => CreateCfqViewModel(
        prefillTeam: prefillTeam,
        prefillMembers: prefillMembers,
        isEditing: isEditing,
        cfqToEdit: cfqToEdit,
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
                Navigator.of(context).pop(true);
              }
            });
            return LoadingOverlay(
              isLoading: viewModel.isLoading,
              child: NeonBackground(
                child: Scaffold(
                  backgroundColor: CustomColor.transparent,
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
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: CfqForm(
                      currentUser: viewModel.currentUser!,
                      image: viewModel.cfqImage,
                      onSelectImage: () => viewModel.pickCfqImage(context),
                      descriptionController: viewModel.descriptionController,
                      locationController: viewModel.locationController,
                      whenController: viewModel.whenController,
                      onSelectMoods: () => viewModel.selectMoods(context),
                      onSelectDateTime: () => viewModel.selectDateTime(context),
                      moodsDisplay: viewModel.selectedMoods != null &&
                              viewModel.selectedMoods!.isNotEmpty
                          ? viewModel.selectedMoods!.join(', ')
                          : CustomString.whatMood,
                      dateTimeDisplay: DateTimeUtils.formatDateTimeDisplay(
                        viewModel.selectedDateTime,
                        viewModel.selectedEndDateTime,
                      ),
                      isLoading: viewModel.isLoading,
                      onSubmit: viewModel.isEditing
                          ? viewModel.updateCfq
                          : viewModel.createCfq,
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
}
