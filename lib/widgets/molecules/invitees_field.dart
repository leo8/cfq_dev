// lib/widgets/molecules/invitees_field.dart

import 'package:flutter/material.dart';
import '../atoms/chips/invitee_chip.dart';
import '../molecules/invitee_search_result_item.dart';
import '../../models/user.dart' as model;

class InviteesField extends StatelessWidget {
  final List<model.User> selectedInvitees;
  final List<model.User> searchResults;
  final TextEditingController searchController;
  final bool isSearching;
  final Function(model.User) onAddInvitee;
  final Function(model.User) onRemoveInvitee;

  const InviteesField({
    required this.selectedInvitees,
    required this.searchResults,
    required this.searchController,
    required this.isSearching,
    required this.onAddInvitee,
    required this.onRemoveInvitee,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        TextField(
          controller: searchController,
          decoration: InputDecoration(
            labelText: 'Search friends',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Display Selected Invitees
        if (selectedInvitees.isNotEmpty)
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: selectedInvitees.map((invitee) {
              return InviteeChip(
                invitee: invitee,
                onDelete: () => onRemoveInvitee(invitee),
              );
            }).toList(),
          ),
        const SizedBox(height: 10),
        // Display Search Results
        if (isSearching)
          const CircularProgressIndicator()
        else
          // Make the search results list scrollable with a constrained height
          Container(
            constraints: const BoxConstraints(
              maxHeight: 150.0, // Set a maximum height for the list
            ),
            child: searchResults.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final user = searchResults[index];
                      return InviteeSearchResultItem(
                        user: user,
                        onAdd: () => onAddInvitee(user),
                      );
                    },
                  )
                : searchController.text.isNotEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'No users found.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : const SizedBox.shrink(),
          ),
      ],
    );
  }
}
