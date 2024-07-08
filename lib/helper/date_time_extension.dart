import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  String to12HourFormat() {
    final DateFormat formatter =
        DateFormat.jm(); // jms() includes seconds, jm() includes minutes
    return formatter.format(this);
  }

  String toDayMonthYearFormat() {
    final DateFormat formatter = DateFormat('dd-MMMM-yyyy');
    return formatter.format(this);
  }

  bool compareDatesOnly(DateTime date2) {
    // Extract only the date part
    DateTime date1Only = DateTime(year, month, day);
    DateTime date2Only = DateTime(date2.year, date2.month, date2.day);

    return date1Only == date2Only;
  }

  bool isToday() {
    DateTime today = DateTime.now();
    return year == today.year && month == today.month && day == today.day;
  }

  bool isYesterday() {
    DateTime today = DateTime.now();
    return year == today.year && month == today.month && day == today.day - 1;
  }
}
