import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:money_track/core/services/contact_service.dart';
import 'package:money_track/features/contact/domain/repositories/contact_repository.dart';

part 'contact_event.dart';
part 'contact_state.dart';

class ContactBloc extends Bloc<ContactEvent, ContactState> {
  final ContactService _contactService;
  final ContactRepository _contactRepository;

  ContactBloc(this._contactService, this._contactRepository)
      : super(ContactInitial()) {
    on<LoadContacts>((event, emit) async {
      emit(ContactLoading());
      try {
        final contacts = await _contactService.getContacts();
        emit(ContactLoaded(contacts));
      } catch (e) {
        emit(ContactError(e.toString()));
      }
    });

    on<LoadContactsWithMatching>((event, emit) async {
      emit(ContactLoading());
      try {
        final result = await _contactRepository.getContactsWithMatching();
        result.fold(
          (contactMatches) => emit(ContactWithMatchingLoaded(contactMatches)),
          (failure) => emit(ContactError(failure.message)),
        );
      } catch (e) {
        emit(ContactError(e.toString()));
      }
    });
  }
}
