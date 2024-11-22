import 'logger.dart';
import 'styles/string.dart';

class DateTimeUtils {
  static const List<String> _monthAbbreviations = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  static String getMonthAbbreviation(int month) {
    if (month < 1 || month > 12) {
      throw ArgumentError('Month must be between 1 and 12');
    }
    return _monthAbbreviations[month - 1];
  }

  static String formatEventTime(DateTime dateTime) {
    return '${_padZero(dateTime.hour)}:${_padZero(dateTime.minute)}';
  }

  static String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  static String formatEventDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final nextWeek = now.add(const Duration(days: 7));

    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return "Aujourd'hui | ${formatEventTime(dateTime)}";
    } else if (dateTime.year == tomorrow.year &&
        dateTime.month == tomorrow.month &&
        dateTime.day == tomorrow.day) {
      return "Demain | ${formatEventTime(dateTime)}";
    } else if (dateTime.isBefore(nextWeek)) {
      final dayName = _getDayName(dateTime.weekday);
      return "$dayName | ${formatEventTime(dateTime)}";
    } else {
      return '${dateTime.day} ${getMonthNameFrench(dateTime.month)} | ${formatEventTime(dateTime)}';
    }
  }

  static String formatBirthdayDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final nextWeek = now.add(const Duration(days: 7));

    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return "aujourd'hui";
    } else if (dateTime.year == tomorrow.year &&
        dateTime.month == tomorrow.month &&
        dateTime.day == tomorrow.day) {
      return "demain";
    } else if (dateTime.isBefore(nextWeek)) {
      final dayName = _getDayName(dateTime.weekday);
      return dayName;
    } else {
      return 'le ${dateTime.day} ${getMonthNameFrench(dateTime.month)}';
    }
  }

  static String _getDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Lundi';
      case DateTime.tuesday:
        return 'Mardi';
      case DateTime.wednesday:
        return 'Mercredi';
      case DateTime.thursday:
        return 'Jeudi';
      case DateTime.friday:
        return 'Vendredi';
      case DateTime.saturday:
        return 'Samedi';
      case DateTime.sunday:
        return 'Dimanche';
      default:
        throw ArgumentError('Invalid weekday');
    }
  }

  static String getMonthNameFrench(int month) {
    switch (month) {
      case 1:
        return 'Janvier';
      case 2:
        return 'Février';
      case 3:
        return 'Mars';
      case 4:
        return 'Avril';
      case 5:
        return 'Mai';
      case 6:
        return 'Juin';
      case 7:
        return 'Juillet';
      case 8:
        return 'Août';
      case 9:
        return 'Septembre';
      case 10:
        return 'Octobre';
      case 11:
        return 'Novembre';
      case 12:
        return 'Décembre';
      default:
        throw ArgumentError('Invalid month');
    }
  }

  static String _padZero(int number) {
    return number.toString().padLeft(2, '0');
  }

  static DateTime parseDate(dynamic date) {
    if (date is DateTime) {
      return date;
    } else if (date is String) {
      try {
        return DateTime.parse(date);
      } catch (e) {
        AppLogger.warning("Warning: Could not parse date string: $date");
        return DateTime.now();
      }
    } else if (date is DateTime) {
      return date;
    } else {
      AppLogger.warning("Warning: Unknown type for date: $date");
      return DateTime.now();
    }
  }

  static DateTime roundToNextFiveMinutes(DateTime date) {
    final int minutes = date.minute;
    final int remainder = minutes % 5;
    final int minutesToAdd = remainder == 0 ? 0 : 5 - remainder;
    return date.add(Duration(
      minutes: minutesToAdd,
      seconds: -date.second,
      milliseconds: -date.millisecond,
      microseconds: -date.microsecond,
    ));
  }

  static String formatMessageDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final sixDaysAgo = DateTime(now.year, now.month, now.day - 6);

    String timeStr = '${_padZero(dateTime.hour)}:${_padZero(dateTime.minute)}';

    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return "Aujourd'hui à $timeStr";
    } else if (dateTime.year == yesterday.year &&
        dateTime.month == yesterday.month &&
        dateTime.day == yesterday.day) {
      return "Hier à $timeStr";
    } else if (dateTime.isAfter(sixDaysAgo)) {
      final dayName = _getDayName(dateTime.weekday);
      return "$dayName à $timeStr";
    } else if (dateTime.year == now.year) {
      return "${_padZero(dateTime.day)}/${_padZero(dateTime.month)} à $timeStr";
    } else {
      return "${_padZero(dateTime.day)}/${_padZero(dateTime.month)}/${dateTime.year} à $timeStr";
    }
  }

  static bool shouldShowTimestamp(
      DateTime? previousMessageTime, DateTime currentMessageTime) {
    if (previousMessageTime == null) return true;

    final difference = currentMessageTime.difference(previousMessageTime);
    return difference.inMinutes >= 10;
  }

  String formatDateTimeDisplay(DateTime? startDate, DateTime? endDate) {
    if (startDate == null) return CustomString.date;

    final startDateStr =
        '${startDate.day.toString().padLeft(2, '0')}/${startDate.month.toString().padLeft(2, '0')}/${startDate.year}';
    final startTimeStr =
        '${startDate.hour.toString().padLeft(2, '0')}:${startDate.minute.toString().padLeft(2, '0')}';

    // If no end date, return simple format
    if (endDate == null) {
      return 'Le $startDateStr à $startTimeStr';
    }

    final endDateStr =
        '${endDate.day.toString().padLeft(2, '0')}/${endDate.month.toString().padLeft(2, '0')}/${endDate.year}';
    final endTimeStr =
        '${endDate.hour.toString().padLeft(2, '0')}:${endDate.minute.toString().padLeft(2, '0')}';

    // Check if same day or next day
    final isSameDay = startDate.year == endDate.year &&
        startDate.month == endDate.month &&
        startDate.day == endDate.day;

    final isNextDay = endDate.difference(startDate).inMinutes <= 1439;

    if (isSameDay || isNextDay) {
      return 'Le $startDateStr de $startTimeStr à $endTimeStr';
    } else {
      return 'Du $startDateStr à $startTimeStr au $endDateStr à $endTimeStr';
    }
  }
}
