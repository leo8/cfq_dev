import 'package:flutter/material.dart';
import 'package:cfq_dev/templates/feed_template.dart';
import 'package:cfq_dev/organisms/app_bar_content.dart';
import 'package:cfq_dev/organisms/profile_pictures_row.dart';
import 'package:cfq_dev/organisms/events_list.dart';
import 'package:cfq_dev/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class ThreadScreen extends StatefulWidget {
  const ThreadScreen({Key? key}) : super(key: key);

  @override
  State<ThreadScreen> createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Helper function to parse date
  DateTime parseDate(dynamic date) {
    if (date is Timestamp) {
      return date.toDate();
    } else if (date is String) {
      try {
        return DateTime.parse(date);
      } catch (e) {
        print("Warning: Could not parse date as DateTime: $date");
        return DateTime.now(); // Fallback to current date
      }
    } else if (date is DateTime) {
      return date;
    } else {
      print("Warning: Unknown type for date: $date");
      return DateTime.now(); // Fallback to current date
    }
  }

  // Fetch turns and cfqs and combine them into a single stream
  Stream<List<DocumentSnapshot>> fetchCombinedEvents() {
    try {
      print("Fetching turns and cfqspackage:cfq_dev.");

      // Fetch turns
      Stream<QuerySnapshot> turnsStream = FirebaseFirestore.instance
          .collection('turns')
          .orderBy('datePublished', descending: true)
          .snapshots();

      // Fetch cfqs
      Stream<QuerySnapshot> cfqsStream = FirebaseFirestore.instance
          .collection('cfqs')
          .orderBy('datePublished', descending: true)
          .snapshots();

      // Combine both streams using Rx.combineLatest2 from rxdart
      return Rx.combineLatest2(turnsStream, cfqsStream,
          (QuerySnapshot turnsSnapshot, QuerySnapshot cfqsSnapshot) {
        // Merge the docs from both collections
        List<DocumentSnapshot> allDocs = [];
        allDocs.addAll(turnsSnapshot.docs);
        allDocs.addAll(cfqsSnapshot.docs);

        // Helper function to get date for sorting
        DateTime getDate(DocumentSnapshot doc) {
          dynamic date;
          if (doc.reference.parent.id == 'turns') {
            date = doc['eventDateTime'];
          } else if (doc.reference.parent.id == 'cfqs') {
            date = doc['datePublished'];
          } else {
            date = DateTime.now(); // Default to now if unknown collection
          }
          return parseDate(date);
        }

        // Sort combined events by their respective dates
        allDocs.sort((a, b) {
          try {
            DateTime dateTimeA = getDate(a);
            DateTime dateTimeB = getDate(b);
            // Compare the two DateTime objects
            return dateTimeB.compareTo(dateTimeA); // Sort descending
          } catch (error) {
            print("Error while sorting events: $error");
            return 0; // Avoid crashing on errors
          }
        });

        print("Total events after merging and sorting: ${allDocs.length}");
        return allDocs;
      });
    } catch (error) {
      print("Error in fetchCombinedEvents: $error");
      rethrow;
    }
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
          const ProfilePicturesRow(
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
