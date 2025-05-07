import 'package:flutter_test/flutter_test.dart';
import 'package:money_track/core/utils/date_time_extension.dart';

void main() {
  group('DateTimeExtension', () {
    test('to12HourFormat returns correct format', () {
      final date = DateTime(2023, 1, 1, 13, 30); // 1:30 PM
      expect(date.to12HourFormat(), equals('1:30 PM'));
      
      final date2 = DateTime(2023, 1, 1, 1, 30); // 1:30 AM
      expect(date2.to12HourFormat(), equals('1:30 AM'));
      
      final date3 = DateTime(2023, 1, 1, 0, 0); // 12:00 AM
      expect(date3.to12HourFormat(), equals('12:00 AM'));
      
      final date4 = DateTime(2023, 1, 1, 12, 0); // 12:00 PM
      expect(date4.to12HourFormat(), equals('12:00 PM'));
    });
    
    test('toDayMonthYearFormat returns correct format', () {
      final date = DateTime(2023, 1, 1);
      expect(date.toDayMonthYearFormat(), equals('01-January-2023'));
      
      final date2 = DateTime(2023, 12, 31);
      expect(date2.toDayMonthYearFormat(), equals('31-December-2023'));
    });
    
    test('compareDatesOnly compares only the date part', () {
      final date1 = DateTime(2023, 1, 1, 13, 30);
      final date2 = DateTime(2023, 1, 1, 10, 15);
      final date3 = DateTime(2023, 1, 2, 13, 30);
      
      expect(date1.compareDatesOnly(date2), isTrue);
      expect(date1.compareDatesOnly(date3), isFalse);
      expect(date2.compareDatesOnly(date3), isFalse);
    });
    
    test('isToday returns true for today', () {
      final today = DateTime.now();
      final todayWithDifferentTime = DateTime(
        today.year,
        today.month,
        today.day,
        (today.hour + 1) % 24,
      );
      
      expect(today.isToday(), isTrue);
      expect(todayWithDifferentTime.isToday(), isTrue);
      
      final yesterday = DateTime(
        today.year,
        today.month,
        today.day - 1,
      );
      expect(yesterday.isToday(), isFalse);
      
      final tomorrow = DateTime(
        today.year,
        today.month,
        today.day + 1,
      );
      expect(tomorrow.isToday(), isFalse);
    });
    
    test('isYesterday returns true for yesterday', () {
      final today = DateTime.now();
      final yesterday = DateTime(
        today.year,
        today.month,
        today.day - 1,
      );
      
      expect(yesterday.isYesterday(), isTrue);
      expect(today.isYesterday(), isFalse);
      
      final twoDaysAgo = DateTime(
        today.year,
        today.month,
        today.day - 2,
      );
      expect(twoDaysAgo.isYesterday(), isFalse);
    });
  });
}
