import 'package:money_track/core/error/result.dart';
import 'package:money_track/features/contact/domain/entities/contact_match.dart';

abstract class ContactRepository {
  /// Get contacts with user matching information
  Future<Result<List<ContactMatch>>> getContactsWithMatching();

  /// Check if a phone number belongs to an existing user
  Future<Result<ContactMatch?>> checkPhoneNumber(String phoneNumber);
}
