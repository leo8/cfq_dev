import 'package:cfq_dev/utils/styles/neon_background.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/team.dart';
import '../view_models/team_details_view_model.dart';
import '../widgets/organisms/team_header.dart';
import '../widgets/organisms/team_options.dart';
import '../utils/styles/colors.dart';
import '../widgets/organisms/team_members_list.dart';
import '../../utils/styles/icons.dart';
import '../widgets/organisms/events_list.dart';
import '../utils/loading_overlay.dart';
import '../utils/styles/string.dart';
import '../utils/styles/text_styles.dart';

class TeamDetailsScreen extends StatelessWidget {
  final Team team;
  final bool viewMode;

  const TeamDetailsScreen({
    super.key,
    required this.team,
    this.viewMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TeamDetailsViewModel(team: team),
      child: Consumer<TeamDetailsViewModel>(
        builder: (context, viewModel, child) {
          return NeonBackground(
            child: Scaffold(
              backgroundColor: CustomColor.transparent,
              appBar: AppBar(
                toolbarHeight: 60,
                backgroundColor: CustomColor.customBlack,
                surfaceTintColor: CustomColor.customBlack,
                elevation: 0,
                title: Text(
                  team.name,
                  style: CustomTextStyle.title1,
                ),
                centerTitle: true,
                leading: IconButton(
                  icon: CustomIcon.arrowBack,
                  onPressed: () {
                    Navigator.of(context).pop(viewModel.hasChanges);
                  },
                ),
              ),
              body: SafeArea(
                child: LoadingOverlay(
                  isLoading: viewModel.isLoading,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TeamHeader(team: viewModel.team),
                        const SizedBox(height: 20),
                        if (!viewMode)
                          TeamOptions(
                            team: viewModel.team,
                            onTeamLeft: () {
                              Navigator.of(context).pop(true);
                            },
                            prefillMembers: viewModel.members,
                            prefillTeam: viewModel.team,
                          ),
                        if (!viewMode) const SizedBox(height: 20),
                        TeamMembersList(
                          members: viewModel.members,
                          isCurrentUserActive: viewModel.isCurrentUserActive,
                        ),
                        if (viewMode) ...[
                          const SizedBox(height: 20),
                          Column(
                            children: [
                              const Icon(
                                CustomIcon.privateProfile,
                                size: 120,
                                color: CustomColor.grey,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                CustomString.privateTeam,
                                style: CustomTextStyle.body1.copyWith(
                                  color: CustomColor.grey300,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 125),
                        if (!viewMode)
                          LoadingOverlay(
                            isLoading: viewModel.isLoading,
                            child: EventsList(
                              eventsStream: viewModel.fetchTeamCombinedEvents(),
                              currentUser: viewModel.currentUser,
                              onFavoriteToggle: viewModel.toggleFavorite,
                              addConversationToUserList:
                                  (String channelId) async {},
                              removeConversationFromUserList:
                                  (String channelId) async {},
                              isConversationInUserList:
                                  (String channelId) async => false,
                              resetUnreadMessages:
                                  (String conversationId) async {},
                              addFollowUp: TeamDetailsViewModel.removeFollowUp,
                              removeFollowUp:
                                  TeamDetailsViewModel.removeFollowUp,
                              isFollowingUpStream:
                                  viewModel.isFollowingUpStream,
                              toggleFollowUp: viewModel.toggleFollowUp,
                              onAttendingStatusChanged:
                                  viewModel.updateAttendingStatus,
                              attendingStatusStream:
                                  viewModel.attendingStatusStream,
                              attendingCountStream:
                                  viewModel.attendingCountStream,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
