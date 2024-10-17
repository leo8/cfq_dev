import 'package:flutter/material.dart';
import '../utils/styles/colors.dart';
import '../utils/styles/icons.dart';
import '../utils/styles/string.dart';
import '../utils/styles/text_styles.dart';
import '../utils/logger.dart';
import 'package:provider/provider.dart';
import '../view_models/invitees_selector_view_model.dart';
import '../widgets/atoms/search_bars/invitee_search_bar.dart';
import '../widgets/atoms/chips/invitee_chip.dart';
import '../widgets/atoms/chips/team_chip.dart';

class InviteesSelectorScreen extends StatelessWidget {
  const InviteesSelectorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<InviteesSelectorViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 40,
            leading: IconButton(
              icon: CustomIcon.arrowBack,
              onPressed: () {
                AppLogger.debug('Back button pressed');
                viewModel.revertSelections();
                Navigator.of(context).pop();
              },
            ),
            backgroundColor: CustomColor.customBlack,
            actions: [
              TextButton(
                onPressed: () {
                  AppLogger.debug('Done button pressed');
                  AppLogger.debug(
                      'Returning selected invitees: ${viewModel.selectedInvitees.length}');
                  AppLogger.debug(
                      'Returning selected teams: ${viewModel.selectedTeamInvitees.length}');
                  Navigator.of(context).pop({
                    'invitees': viewModel.selectedInvitees,
                    'teams': viewModel.selectedTeamInvitees,
                    'isEverybodySelected': viewModel.isEverybodySelected,
                  });
                },
                child: Text(
                  CustomString.done,
                  style: CustomTextStyle.body1.copyWith(
                    fontWeight: FontWeight.bold,
                    color: CustomColor.customPurple,
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              InviteeSearchBar(
                controller: viewModel.searchController,
                onSearch: viewModel.performSearch,
                searchResults: viewModel.searchResults,
                onAddInvitee: viewModel.addInvitee,
                onAddTeam: viewModel.addTeam,
                onSelectEverybody: viewModel.selectEverybody,
                isEverybodySelected: viewModel.isEverybodySelected,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8.0,
                children: [
                  if (viewModel.isEverybodySelected)
                    Chip(
                      avatar: const CircleAvatar(
                        backgroundImage:
                            AssetImage('assets/images/turn_button.png'),
                      ),
                      label: const Text(CustomString.everybody),
                      deleteIcon: CustomIcon.close.copyWith(size: 18),
                      onDeleted: viewModel.selectEverybody,
                      backgroundColor: CustomColor.white.withOpacity(0.1),
                      labelStyle: CustomTextStyle.body1,
                    ),
                  ...viewModel.selectedTeamInvitees
                      .map((teamInvitee) => TeamChip(
                            team: teamInvitee,
                            onDelete: () => viewModel.removeTeam(teamInvitee),
                          )),
                  ...viewModel.selectedInvitees.map((invitee) => InviteeChip(
                        invitee: invitee,
                        onDelete: () => viewModel.removeInvitee(invitee),
                      )),
                ],
              ),
              if (viewModel.isSearching) const CircularProgressIndicator(),
            ],
          ),
        );
      },
    );
  }
}
