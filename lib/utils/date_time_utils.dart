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
      return "${dayName[0].toUpperCase() + dayName.substring(1)} | ${formatEventTime(dateTime)}";
    } else {
      return '${dateTime.day} ${getMonthNameFrench(dateTime.month)[0].toUpperCase() + getMonthNameFrench(dateTime.month).substring(1)} | ${formatEventTime(dateTime)}';
    }
  }

  static String formatBirthdayDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final nextWeek = now.add(const Duration(days: 7));

    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return "Aujourd'hui";
    } else if (dateTime.year == tomorrow.year &&
        dateTime.month == tomorrow.month &&
        dateTime.day == tomorrow.day) {
      return "Demain";
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
        return 'lundi';
      case DateTime.tuesday:
        return 'mardi';
      case DateTime.wednesday:
        return 'mercredi';
      case DateTime.thursday:
        return 'jeudi';
      case DateTime.friday:
        return 'vendredi';
      case DateTime.saturday:
        return 'samedi';
      case DateTime.sunday:
        return 'dimanche';
      default:
        throw ArgumentError('Invalid weekday');
    }
  }

  static String getMonthNameFrench(int month) {
    switch (month) {
      case 1:
        return 'janvier';
      case 2:
        return 'février';
      case 3:
        return 'mars';
      case 4:
        return 'avril';
      case 5:
        return 'mai';
      case 6:
        return 'juin';
      case 7:
        return 'juillet';
      case 8:
        return 'août';
      case 9:
        return 'septembre';
      case 10:
        return 'octobre';
      case 11:
        return 'novembre';
      case 12:
        return 'décembre';
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
      return "${dayName[0].toUpperCase()}${dayName.substring(1)} à $timeStr";
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

  static String formatDateTimeDisplay(DateTime? startDate, DateTime? endDate) {
    if (startDate == null) return CustomString.date;

    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final nextWeek = now.add(const Duration(days: 7));

    // Format start date string based on when it is
    String startDateStr;
    if (startDate.year == now.year &&
        startDate.month == now.month &&
        startDate.day == now.day) {
      startDateStr = "Aujourd'hui";
    } else if (startDate.year == tomorrow.year &&
        startDate.month == tomorrow.month &&
        startDate.day == tomorrow.day) {
      startDateStr = "Demain";
    } else if (startDate.isBefore(nextWeek)) {
      startDateStr = _getDayName(startDate.weekday);
    } else {
      startDateStr =
          'le ${startDate.day} ${getMonthNameFrench(startDate.month)}';
    }

    final startTimeStr = formatEventTime(startDate);

    // If no end date, return simple format
    if (endDate == null) {
      return '$startDateStr | $startTimeStr';
    }

    // Format end date string
    String endDateStr;
    if (endDate.year == now.year &&
        endDate.month == now.month &&
        endDate.day == now.day) {
      endDateStr = "aujourd'hui";
    } else if (endDate.year == tomorrow.year &&
        endDate.month == tomorrow.month &&
        endDate.day == tomorrow.day) {
      endDateStr = "demain";
    } else if (endDate.isBefore(nextWeek)) {
      endDateStr = _getDayName(endDate.weekday).toLowerCase();
    } else {
      endDateStr = '${endDate.day} ${getMonthNameFrench(endDate.month)}';
    }

    final endTimeStr = formatEventTime(endDate);

    // Check if same day or next day
    final isSameDay = startDate.year == endDate.year &&
        startDate.month == endDate.month &&
        startDate.day == endDate.day;

    final isNextDay = endDate.difference(startDate).inMinutes <= 1439;
    final isNextWeek = endDate.difference(DateTime.now()).inDays <= 6;
    if ((isSameDay || isNextDay) &&
        endDate.difference(startDate).inHours < 24) {
      return '${startDateStr[0].toUpperCase()}${startDateStr.substring(1)} de $startTimeStr à $endTimeStr';
    } else {
      // Use "au" instead of "à" for dates
      final useAu = (isSameDay || isNextDay || isNextWeek) ? true : false;
      print(useAu);
      return '${startDateStr[0].toUpperCase()}${startDateStr.substring(1)} à $startTimeStr jusqu\'${useAu ? 'à' : 'au'} $endDateStr à $endTimeStr';
    }
  }
}
