import 'package:equatable/equatable.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

enum ContactStatus {
  existingUser,
  inviteNeeded,
  unknown,
}

class ContactMatch extends Equatable {
  final Contact contact;
  final ContactStatus status;
  final String? userId; // If existing user, their user ID
  final String? userName; // If existing user, their display name

  const ContactMatch({
    required this.contact,
    required this.status,
    this.userId,
    this.userName,
  });

  @override
  List<Object?> get props => [contact, status, userId, userName];
}
