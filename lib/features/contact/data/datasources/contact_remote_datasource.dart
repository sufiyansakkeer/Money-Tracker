import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:money_track/core/error/failures.dart';
import 'package:money_track/core/error/result.dart';

abstract class ContactRemoteDataSource {
  Future<Result<Map<String, String>>> checkPhoneNumbers(
      List<String> phoneNumbers);
}

class ContactRemoteDataSourceImpl implements ContactRemoteDataSource {
  final FirebaseFirestore firestore;

  ContactRemoteDataSourceImpl({required this.firestore});

  @override
  Future<Result<Map<String, String>>> checkPhoneNumbers(
      List<String> phoneNumbers) async {
    try {
      // Query users collection where phone is in the provided phone numbers
      final querySnapshot = await firestore
          .collection('users')
          .where('phone', whereIn: phoneNumbers)
          .get();

      // Create a map of phone number to user ID
      final phoneToUserMap = <String, String>{};
      for (final doc in querySnapshot.docs) {
        final phone = doc.data()['phone'] as String?;
        if (phone != null) {
          phoneToUserMap[phone] = doc.id;
        }
      }

      return Success(phoneToUserMap);
    } catch (e) {
      return Error(AuthFailure(
          message: "Failed to check phone numbers: ${e.toString()}"));
    }
  }
}
