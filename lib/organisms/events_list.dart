import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/turn_card.dart';
import '../widgets/cfq_card.dart';
import '../utils/string.dart';
import '../utils/utils.dart';

class EventsList extends StatelessWidget {
  final Stream<List<DocumentSnapshot>> eventsStream;

  const EventsList({
    required this.eventsStream,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DocumentSnapshot>>(
      stream: eventsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print("Error fetching events: ${snapshot.error}");
          return const Center(child: Text(CustomString.errorFetchingEvents));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final events = snapshot.data!;
        if (events.isEmpty) {
          return const Center(child: Text(CustomString.noEventsAvailable));
        }

        return ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            final isTurn = event.reference.parent.id == 'turns';

            if (isTurn) {
              return TurnCard(
                // Pass the required data from the event
              );
            } else {
              return CFQCard(
                // Pass the required data from the event
              );
            }
          },
        );
      },
    );
  }
}
