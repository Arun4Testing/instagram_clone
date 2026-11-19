// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/core/constants/app_constants.dart
// Layer   : Core
// Purpose : App-wide constant values (timings, limits, labels) so that no
//           "magic numbers" are scattered through the UI or data layers.
// Used by : AuthGate, AuthRepositoryImpl, CreateReelPage
// ─────────────────────────────────────────────────────────────────────────────

class AppConstants {
  AppConstants._();

  static const String appName = 'Pic Yapper';

  /// Shown on the splash and login screens.
  static const String tagline = 'Stories worth keeping.';

  /// How long the splash screen is shown before the auth gate decides.
  static const Duration splashDuration = Duration(milliseconds: 1500);

  /// Longest reel the user may upload.
  static const Duration maxReelDuration = Duration(seconds: 90);

  /// Minimum password length accepted on sign-up.
  static const int minPasswordLength = 4;
}
