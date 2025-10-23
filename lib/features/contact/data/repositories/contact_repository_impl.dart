import 'package:money_track/core/error/failures.dart';
import 'package:money_track/core/error/result.dart';
import 'package:money_track/core/services/contact_service.dart';
import 'package:money_track/core/widgets/logger_service.dart';
import 'package:money_track/features/contact/data/datasources/contact_remote_datasource.dart';
import 'package:money_track/features/contact/domain/entities/contact_match.dart';
import 'package:money_track/features/contact/domain/repositories/contact_repository.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactRepositoryImpl implements ContactRepository {
  final ContactService _contactService;
  final ContactRemoteDataSource _remoteDataSource;
  final LoggerService logger = LoggerService();

  ContactRepositoryImpl({
    required ContactService contactService,
    required ContactRemoteDataSource remoteDataSource,
  })  : _contactService = contactService,
        _remoteDataSource = remoteDataSource;

  @override
  Future<Result<List<ContactMatch>>> getContactsWithMatching() async {
    try {
      // Get contacts from device
      final contacts = await _contactService.getContacts();

      if (contacts.isEmpty) {
        return const Success([]);
      }

      // Extract phone numbers from contacts
      final phoneNumbers = <String>[];
      for (final contact in contacts) {
        if (contact.phones.isNotEmpty) {
          phoneNumbers.add(contact.phones.first.number);
        }
      }

      if (phoneNumbers.isEmpty) {
        // Return contacts with unknown status if no phone numbers
        final contactMatches = contacts
            .map((contact) =>
                ContactMatch(contact: contact, status: ContactStatus.unknown))
            .toList();
        return Success(contactMatches);
      }

      // Check which phone numbers exist in users collection
      final phoneCheckResult =
          await _remoteDataSource.checkPhoneNumbers(phoneNumbers);

      return phoneCheckResult.fold(
        (phoneToUserMap) {
          // Create contact matches based on phone number lookup
          final contactMatches = <ContactMatch>[];

          for (final contact in contacts) {
            if (contact.phones.isNotEmpty) {
              final phone = contact.phones.first.number;
              final userId = phoneToUserMap[phone];

              if (userId != null) {
                // Found existing user
                contactMatches.add(ContactMatch(
                  contact: contact,
                  status: ContactStatus.existingUser,
                  userId: userId,
                  userName: contact
                      .displayName, // Could be enhanced to get actual user name
                ));
              } else {
                // User needs to be invited
                contactMatches.add(ContactMatch(
                  contact: contact,
                  status: ContactStatus.inviteNeeded,
                ));
              }
            } else {
              // Contact has no phone number
              contactMatches.add(ContactMatch(
                contact: contact,
                status: ContactStatus.unknown,
              ));
            }
          }

          return Success(contactMatches);
        },
        (failure) => Error(failure),
      );
    } catch (e) {
      logger.e(e.toString(), error: "Get contacts with matching exception");
      return Error(
          AuthFailure(message: "Failed to get contacts: ${e.toString()}"));
    }
  }

  @override
  Future<Result<ContactMatch?>> checkPhoneNumber(String phoneNumber) async {
    try {
      final phoneCheckResult =
          await _remoteDataSource.checkPhoneNumbers([phoneNumber]);

      return phoneCheckResult.fold(
        (phoneToUserMap) {
          final userId = phoneToUserMap[phoneNumber];
          if (userId != null) {
            // Create a dummy contact for the phone number
            final contact = Contact(
              id: phoneNumber,
              displayName: phoneNumber, // Placeholder name
              phones: [Phone(phoneNumber)],
            );

            return Success(ContactMatch(
              contact: contact,
              status: ContactStatus.existingUser,
              userId: userId,
              userName: phoneNumber, // Placeholder
            ));
          } else {
            return const Success(null);
          }
        },
        (failure) => Error(failure),
      );
    } catch (e) {
      logger.e(e.toString(), error: "Check phone number exception");
      return Error(AuthFailure(
          message: "Failed to check phone number: ${e.toString()}"));
    }
  }
}
