import 'package:cfq_dev/utils/styles/colors.dart';
import 'package:flutter/material.dart';
import '../../../models/team.dart';
import '../../../models/user.dart' as model;
import '../../../utils/styles/string.dart';
import '../../../utils/styles/icons.dart';
import '../../../utils/styles/text_styles.dart';
import '../../../utils/logger.dart';
import '../texts/bordered_icon_text_field.dart';

class InviteeSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final String hintText;
  final List<dynamic> searchResults;
  final Function(model.User) onAddInvitee;
  final Function(Team) onAddTeam;
  final VoidCallback onSelectEverybody;
  final bool isEverybodySelected;

  const InviteeSearchBar({
    super.key,
    required this.controller,
    required this.onSearch,
    this.hintText = CustomString.searchFriends,
    required this.searchResults,
    required this.onAddInvitee,
    required this.onAddTeam,
    required this.onSelectEverybody,
    required this.isEverybodySelected,
  });

  @override
  Widget build(BuildContext context) {
    AppLogger.debug('Search results length: ${searchResults.length}');
    return Column(
      children: [
        Container(
          height: 46,
          child: BorderedIconTextField(
            icon: CustomIcon.search
                .copyWith(color: CustomColor.customWhite, size: 22),
            controller: controller,
            hintText: hintText,
            hintTextStyle: CustomTextStyle.body1,
            borderRadius: BorderRadius.circular(30),
            height: 46,
            onTap: null,
            readOnly: false,
          ),
        ),
        const SizedBox(
          height: 25,
        ),
        if (searchResults.isNotEmpty)
          SizedBox(
            height: 400,
            child: ListView.builder(
              itemCount: searchResults.length + (isEverybodySelected ? 0 : 1),
              itemBuilder: (context, index) {
                if (!isEverybodySelected && index == 0) {
                  // "Tout le monde" option
                  return ListTile(
                    leading: const CircleAvatar(
                      backgroundImage:
                          AssetImage('assets/images/turn_button.png'),
                    ),
                    title: const Text(CustomString.toutLeMonde),
                    trailing: IconButton(
                      icon: CustomIcon.add.copyWith(
                        color: CustomColor.customPurple,
                        size: 24,
                      ),
                      onPressed: onSelectEverybody,
                    ),
                  );
                } else {
                  final result = isEverybodySelected
                      ? searchResults[index]
                      : searchResults[index - 1];
                  if (result is Team) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(result.imageUrl),
                      ),
                      title: Text(result.name),
                      subtitle: const Text(CustomString.team),
                      trailing: IconButton(
                        icon: CustomIcon.add.copyWith(
                          color: CustomColor.customPurple,
                          size: 24,
                        ),
                        onPressed: () => onAddTeam(result),
                      ),
                    );
                  } else if (result is model.User) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(result.profilePictureUrl),
                      ),
                      title: Text(result.username),
                      trailing: IconButton(
                        icon: CustomIcon.add.copyWith(
                          color: CustomColor.customPurple,
                          size: 24,
                        ),
                        onPressed: () => onAddInvitee(result),
                      ),
                    );
                  }
                }
                return const SizedBox.shrink();
              },
            ),
          ),
      ],
    );
  }
}
