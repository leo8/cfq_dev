import 'package:flutter/material.dart';
import 'package:cfq_dev/templates/standard_selection_template.dart';
import '../utils/styles/string.dart';
import '../widgets/organisms/selection_buttons.dart';

/// The `AddPostScreen` provides a UI for the user to select the type of post they want to create.
class AddPostScreen extends StatelessWidget {
  const AddPostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This screen uses a template (StandardSelectionTemplate) to structure the selection process.
    // The body contains buttons for the user to choose the type of post to create.
    return const StandardSelectionTemplate(
      title: CustomString.publier, // Page title displayed at the top of the screen
      body: SelectionButtons(),    // Organism widget displaying options for post creation
    );
  }
}
