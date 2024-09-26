import 'package:flutter/material.dart';
import 'package:cfq_dev/templates/standard_selection_template.dart';
import '../utils/styles/string.dart';
import '../widgets/organisms/selection_buttons.dart';

class AddPostScreen extends StatelessWidget {
  const AddPostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StandardSelectionTemplate(
      title: CustomString.publier,
      body: SelectionButtons(),
    );
  }
}
