// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/presentation/blocs/auth/auth_bloc.dart
// Layer   : Presentation (bloc)
// Purpose : Login, sign-up, logout, session restore and profile editing.
//           Talks only to the [AuthRepository] interface from the domain layer.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/app_user.dart';
import '../../../domain/failures/auth_exception.dart';
import '../../../domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._repository) : super(const AuthState()) {
    on<AuthStarted>(_onStarted);
    on<LoginRequested>(_onLogin);
    on<SignUpRequested>(_onSignUp);
    on<LoggedOut>(_onLoggedOut);
    on<ProfileUpdated>(_onProfileUpdated);
  }

  final AuthRepository _repository;

  int _stamp() => DateTime.now().microsecondsSinceEpoch;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    emit(AuthState(user: await _repository.restoreSession()));
  }

  Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
    try {
      final user = await _repository.login(username: event.username, password: event.password);
      emit(AuthState(user: user, stamp: _stamp()));
    } on AuthException catch (e) {
      emit(AuthState(user: state.user, error: e.message, stamp: _stamp()));
    }
  }

  Future<void> _onSignUp(SignUpRequested event, Emitter<AuthState> emit) async {
    try {
      final user = await _repository.signUp(
        username: event.username,
        password: event.password,
        name: event.name,
      );
      emit(AuthState(user: user, stamp: _stamp()));
    } on AuthException catch (e) {
      emit(AuthState(user: state.user, error: e.message, stamp: _stamp()));
    }
  }

  Future<void> _onLoggedOut(LoggedOut event, Emitter<AuthState> emit) async {
    await _repository.logout();
    emit(const AuthState());
  }

  Future<void> _onProfileUpdated(ProfileUpdated event, Emitter<AuthState> emit) async {
    try {
      final user = await _repository.updateProfile(name: event.name, bio: event.bio);
      emit(AuthState(user: user, stamp: _stamp()));
    } on AuthException catch (e) {
      emit(AuthState(user: state.user, error: e.message, stamp: _stamp()));
    }
  }
}
