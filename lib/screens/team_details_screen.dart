import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/team.dart';
import '../view_models/team_details_view_model.dart';
import '../widgets/organisms/team_header.dart';
import '../widgets/organisms/team_options.dart';
import '../utils/styles/colors.dart';
import '../utils/styles/fonts.dart';
import '../widgets/organisms/team_members.dart';

class TeamDetailsScreen extends StatelessWidget {
  final Team team;

  const TeamDetailsScreen({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TeamDetailsViewModel(team: team),
      child: Scaffold(
        backgroundColor: CustomColor.mobileBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: CustomColor.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Consumer<TeamDetailsViewModel>(
              builder: (context, viewModel, child) {
                return Column(
                  children: [
                    TeamHeader(team: team),
                    const SizedBox(height: 20),
                    TeamOptions(),
                    const SizedBox(height: 20),
                    viewModel.isLoading
                        ? const CircularProgressIndicator()
                        : TeamMembersList(members: viewModel.members),
                    const SizedBox(height: 20),
                    const Center(
                      child: Text(
                        'Team feed',
                        style: TextStyle(
                          color: CustomColor.white,
                          fontSize: CustomFont.fontSize20,
                          fontWeight: CustomFont.fontWeightBold,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
