import 'package:cfq_dev/screens/create_team_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/teams_view_model.dart';
import '../utils/styles/colors.dart';
import '../utils/styles/fonts.dart';
import '../widgets/atoms/texts/custom_text.dart';
import '../widgets/atoms/buttons/outlined_icon_button.dart';

class TeamsScreen extends StatelessWidget {
  const TeamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TeamsViewModel>(
      create: (_) => TeamsViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Teams'),
        ),
        body: Consumer<TeamsViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (viewModel.teams.isEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Add more space between AppBar and "+" button
                  const SizedBox(height: 60),
                  // Centered Outlined "+" Button
                  Center(
                    child: OutlinedIconButton(
                      icon: Icons.add,
                      onPressed: () {
                        // Navigate to CreateTeamScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateTeamScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  // Add more space below the "+" button
                  const SizedBox(height: 20),
                  // Expanded widget to center the message vertically
                  Expanded(
                    child: Center(
                      child: CustomText(
                        text: 'Vous n\'avez pas encore de teams.',
                        fontSize: CustomFont.fontSize18,
                        color: CustomColor.white,
                      ),
                    ),
                  ),
                ],
              );
            } else {
              // Placeholder for future implementation
              return ListView.builder(
                itemCount: viewModel.teams.length,
                itemBuilder: (context, index) {
                  // Placeholder code for displaying teams
                  return Container(); // Empty container
                },
              );
            }
          },
        ),
      ),
    );
  }
}
