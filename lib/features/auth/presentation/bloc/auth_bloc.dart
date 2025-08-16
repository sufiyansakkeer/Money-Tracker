import 'dart:async';
import 'dart:developer';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/features/auth/domain/entities/user_entity.dart';
import 'package:money_track/features/auth/domain/repositories/auth_repository.dart';
import 'package:money_track/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:money_track/features/auth/domain/usecases/is_signed_in_usecase.dart';
import 'package:money_track/features/auth/domain/usecases/send_password_reset_usecase.dart';
import 'package:money_track/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:money_track/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:money_track/features/auth/domain/usecases/sign_up_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase signInUseCase;
  final SignUpUseCase signUpUseCase;
  final SignOutUseCase signOutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final IsSignedInUseCase isSignedInUseCase;
  final SendPasswordResetUseCase sendPasswordResetUseCase;
  final AuthRepository authRepository;

  late StreamSubscription<UserEntity?> _authStateSubscription;

  AuthBloc({
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.signOutUseCase,
    required this.getCurrentUserUseCase,
    required this.isSignedInUseCase,
    required this.sendPasswordResetUseCase,
    required this.authRepository,
  }) : super(AuthInitial()) {
    // Listen to auth state changes
    _authStateSubscription = authRepository.authStateChanges.listen((user) {
      add(AuthStateChangedEvent(user: user));
    });

    on<CheckAuthStatusEvent>((event, emit) async {
      emit(AuthLoading());

      try {
        final result = await getCurrentUserUseCase();

        result.fold(
          (user) {
            if (user != null) {
              emit(AuthAuthenticated(user: user));
            } else {
              emit(AuthUnauthenticated());
            }
          },
          (failure) {
            log(failure.message, name: "CheckAuthStatusEvent");
            emit(AuthUnauthenticated());
          },
        );
      } catch (e) {
        log(e.toString(), name: "CheckAuthStatusEvent");
        emit(AuthUnauthenticated());
      }
    });

    on<SignInEvent>((event, emit) async {
      emit(AuthLoading());

      try {
        final params = SignInParams(
          email: event.email,
          password: event.password,
        );

        final result = await signInUseCase(params: params);

        result.fold(
          (user) {
            emit(AuthAuthenticated(user: user));
            // Sync will be automatically initialized by the repository
          },
          (failure) {
            emit(AuthError(message: failure.message));
          },
        );
      } catch (e) {
        log(e.toString(), name: "SignInEvent");
        emit(AuthError(message: "Sign in failed: ${e.toString()}"));
      }
    });

    on<SignUpEvent>((event, emit) async {
      emit(AuthLoading());

      try {
        final params = SignUpParams(
          email: event.email,
          password: event.password,
          displayName: event.displayName,
        );

        final result = await signUpUseCase(params: params);

        result.fold(
          (user) {
            emit(AuthAuthenticated(user: user));
            // Sync will be automatically initialized by the repository
          },
          (failure) {
            emit(AuthError(message: failure.message));
          },
        );
      } catch (e) {
        log(e.toString(), name: "SignUpEvent");
        emit(AuthError(message: "Sign up failed: ${e.toString()}"));
      }
    });

    on<SignOutEvent>((event, emit) async {
      emit(AuthLoading());

      try {
        final result = await signOutUseCase();

        result.fold(
          (_) {
            emit(AuthUnauthenticated());
            // Local data will be automatically cleared by the repository
          },
          (failure) {
            emit(AuthError(message: failure.message));
          },
        );
      } catch (e) {
        log(e.toString(), name: "SignOutEvent");
        emit(AuthError(message: "Sign out failed: ${e.toString()}"));
      }
    });

    on<SendPasswordResetEvent>((event, emit) async {
      emit(AuthLoading());

      try {
        final result = await sendPasswordResetUseCase(params: event.email);

        result.fold(
          (_) {
            emit(PasswordResetEmailSent(email: event.email));
          },
          (failure) {
            emit(AuthError(message: failure.message));
          },
        );
      } catch (e) {
        log(e.toString(), name: "SendPasswordResetEvent");
        emit(AuthError(
            message: "Failed to send password reset email: ${e.toString()}"));
      }
    });

    on<SendEmailVerificationEvent>((event, emit) async {
      emit(AuthLoading());

      try {
        final result = await authRepository.sendEmailVerification();

        result.fold(
          (_) {
            emit(EmailVerificationSent());
          },
          (failure) {
            emit(AuthError(message: failure.message));
          },
        );
      } catch (e) {
        log(e.toString(), name: "SendEmailVerificationEvent");
        emit(AuthError(
            message: "Failed to send email verification: ${e.toString()}"));
      }
    });

    on<ReloadUserEvent>((event, emit) async {
      try {
        final result = await authRepository.reloadUser();

        result.fold(
          (user) {
            emit(AuthAuthenticated(user: user));
          },
          (failure) {
            emit(AuthError(message: failure.message));
          },
        );
      } catch (e) {
        log(e.toString(), name: "ReloadUserEvent");
        emit(AuthError(message: "Failed to reload user: ${e.toString()}"));
      }
    });

    on<DeleteAccountEvent>((event, emit) async {
      emit(AuthLoading());

      try {
        final result = await authRepository.deleteAccount();

        result.fold(
          (_) {
            emit(AccountDeleted());
          },
          (failure) {
            emit(AuthError(message: failure.message));
          },
        );
      } catch (e) {
        log(e.toString(), name: "DeleteAccountEvent");
        emit(AuthError(message: "Failed to delete account: ${e.toString()}"));
      }
    });

    on<UpdateProfileEvent>((event, emit) async {
      emit(AuthLoading());

      try {
        final result = await authRepository.updateProfile(
          displayName: event.displayName,
          photoUrl: event.photoUrl,
        );

        result.fold(
          (user) {
            emit(AuthAuthenticated(user: user));
          },
          (failure) {
            emit(AuthError(message: failure.message));
          },
        );
      } catch (e) {
        log(e.toString(), name: "UpdateProfileEvent");
        emit(AuthError(message: "Failed to update profile: ${e.toString()}"));
      }
    });

    on<AuthStateChangedEvent>((event, emit) {
      if (event.user != null) {
        emit(AuthAuthenticated(user: event.user!));
      } else {
        emit(AuthUnauthenticated());
      }
    });
  }

  @override
  Future<void> close() {
    _authStateSubscription.cancel();
    return super.close();
  }
}
