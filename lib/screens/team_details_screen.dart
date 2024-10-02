// team_details_screen.dart

import 'package:flutter/material.dart';
import '../models/team.dart';

class TeamDetailsScreen extends StatelessWidget {
  final Team team;

  const TeamDetailsScreen({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(team.name),
      ),
      body: Center(
        child: Text(
          'Team Details for ${team.name}',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
