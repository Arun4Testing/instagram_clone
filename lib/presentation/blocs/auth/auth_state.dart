// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/presentation/blocs/auth/auth_state.dart
// Layer   : Presentation (bloc state)
// Purpose : Who is signed in, plus the latest error to show.
//           [stamp] changes on every login/sign-up attempt so a repeated error
//           message still triggers the BlocListener (Equatable would otherwise
//           treat two identical error states as "no change").
// ─────────────────────────────────────────────────────────────────────────────

part of 'auth_bloc.dart';

class AuthState extends Equatable {
  const AuthState({this.user, this.error, this.stamp = 0});

  final AppUser? user;
  final String? error;
  final int stamp;

  bool get loggedIn => user != null;

  @override
  List<Object?> get props => [user, error, stamp];
}
