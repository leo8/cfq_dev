import 'package:flutter/material.dart';
import 'package:cfq_dev/templates/feed_template.dart';
import 'package:cfq_dev/organisms/app_bar_content.dart';
import 'package:cfq_dev/organisms/profile_pictures_row.dart';
import 'package:cfq_dev/organisms/events_list.dart';
import 'package:cfq_dev/utils/colors.dart';
import 'package:cfq_dev/utils/icons.dart';
import 'package:cfq_dev/utils/string.dart';
import 'package:cfq_dev/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:cfq_dev/widgets/turn_card.dart';
import 'package:cfq_dev/widgets/cfq_card.dart';

class ThreadScreen extends StatefulWidget {
  const ThreadScreen({Key? key}) : super(key: key);

  @override
  State<ThreadScreen> createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Helper function to parse date
  DateTime parseDate(dynamic date) {
    // Your existing implementation
  }

  // Fetch turns and cfqs and combine them into a single stream
  Stream<List<DocumentSnapshot>> fetchCombinedEvents() {
    // Your existing implementation
  }

  @override
  Widget build(BuildContext context) {
    return FeedTemplate(
      appBar: AppBar(
        backgroundColor: CustomColor.transparent,
        elevation: 0,
        title: AppBarContent(
          searchController: _searchController,
          onNotificationPressed: () {
            // Handle notification press
          },
        ),
      ),
      backgroundImageUrl:
          'https://images.unsplash.com/photo-1617957772002-57adde1156fa?q=80&w=2832&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 135),
          // Profile Pictures Row
          ProfilePicturesRow(
            profiles: [
              // Provide a list of profiles with imageUrl and username
              {'imageUrl': 'https://randomuser.me/api/portraits/men/1.jpg', 'username': 'User1'},
              {'imageUrl': 'https://randomuser.me/api/portraits/women/2.jpg', 'username': 'User2'},
              // Add more profiles as needed
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: EventsList(
              eventsStream: fetchCombinedEvents(),
            ),
          ),
        ],
      ),
    );
  }
}
