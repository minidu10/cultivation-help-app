import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Gets a Google ID token for the AgroMaster backend.
///
/// The token is requested for the backend's web client id (served by
/// /api/auth/config), so its audience is the one the server already accepts
/// and no extra server configuration is needed for the app.
abstract interface class GoogleIdentity {
  /// The ID token, or null if the user backed out of the account picker.
  Future<String?> idToken({required String serverClientId});
}

final googleIdentityProvider = Provider<GoogleIdentity>((ref) => PlatformGoogleIdentity());

class PlatformGoogleIdentity implements GoogleIdentity {
  String? _initialisedFor;

  @override
  Future<String?> idToken({required String serverClientId}) async {
    final google = GoogleSignIn.instance;
    if (_initialisedFor != serverClientId) {
      await google.initialize(serverClientId: serverClientId);
      _initialisedFor = serverClientId;
    }
    try {
      final account = await google.authenticate();
      return account.authentication.idToken;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled || e.code == GoogleSignInExceptionCode.interrupted) {
        return null;
      }
      rethrow;
    }
  }
}
