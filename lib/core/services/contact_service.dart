import 'package:flutter_contacts/flutter_contacts.dart';

class ContactService {
  Future<List<Contact>> getContacts() async {
    if (await FlutterContacts.requestPermission()) {
      return await FlutterContacts.getContacts();
    }
    return [];
  }
}
