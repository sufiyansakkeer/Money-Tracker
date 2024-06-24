import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  String to12HourFormat() {
    final DateFormat formatter =
        DateFormat.jm(); // jms() includes seconds, jm() includes minutes
    return formatter.format(this);
  }
}
