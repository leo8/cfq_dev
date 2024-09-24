import 'package:flutter/material.dart';
import 'package:cfq_dev/templates/standard_selection_template.dart';
import 'package:cfq_dev/organisms/selection_buttons.dart';
import 'package:cfq_dev/utils/string.dart';

class AddPostScreen extends StatelessWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StandardSelectionTemplate(
      title: CustomString.publier,
      body: const SelectionButtons(),
    );
  }
}
