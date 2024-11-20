import '../utils/styles/string.dart';
import '../utils/styles/icons.dart';

class MoodItem {
  final CustomIcon icon;
  final String label;

  const MoodItem(this.icon, this.label);
}

class CustomMood {
  static const List<MoodItem> moods = [
    MoodItem(CustomIcon.homeMood, CustomString.houseMood),
    MoodItem(CustomIcon.barMood, CustomString.barMood),
    MoodItem(CustomIcon.clubMood, CustomString.clubMood),
    MoodItem(CustomIcon.streetMood, CustomString.streetMood),
    MoodItem(CustomIcon.otherMood, CustomString.otherMood),
    MoodItem(CustomIcon.chillMood, CustomString.chillMood),
    MoodItem(CustomIcon.dinerMood, CustomString.dinerMood),
    MoodItem(CustomIcon.afterMood, CustomString.afterMood),
    MoodItem(CustomIcon.beforeMood, CustomString.beforeMood),
    MoodItem(CustomIcon.concertMood, CustomString.concertMood),
    MoodItem(CustomIcon.everythingMood, CustomString.everythingMood),
  ];
}
