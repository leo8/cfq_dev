
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class ThreadViewModel {

    ThreadViewModel();
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
        // Debug logs for turns and cfqs snapshots
        print("Turns snapshot docs count: ${turnsSnapshot.docs.length}");
        print("CFQs snapshot docs count: ${cfqsSnapshot.docs.length}");

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

}