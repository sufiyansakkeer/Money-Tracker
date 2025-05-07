import 'package:flutter_test/flutter_test.dart';
import 'package:money_track/core/utils/string_extensions.dart';

void main() {
  group('StringExtensions', () {
    test('capitalize returns string with first letter capitalized', () {
      expect('hello'.capitalize(), equals('Hello'));
      expect('world'.capitalize(), equals('World'));
      expect('test string'.capitalize(), equals('Test string'));
      expect('a'.capitalize(), equals('A'));
      expect('A'.capitalize(), equals('A'));
      expect('hello world'.capitalize(), equals('Hello world'));
    });
    
    test('capitalize handles empty string', () {
      expect(() => ''.capitalize(), throwsRangeError);
    });
    
    test('capitalize handles strings with first character already capitalized', () {
      expect('Hello'.capitalize(), equals('Hello'));
      expect('World'.capitalize(), equals('World'));
      expect('Test string'.capitalize(), equals('Test string'));
    });
    
    test('capitalize handles strings with numbers', () {
      expect('1hello'.capitalize(), equals('1hello'));
      expect('123'.capitalize(), equals('123'));
    });
    
    test('capitalize handles strings with special characters', () {
      expect('!hello'.capitalize(), equals('!hello'));
      expect('@world'.capitalize(), equals('@world'));
    });
  });
}
