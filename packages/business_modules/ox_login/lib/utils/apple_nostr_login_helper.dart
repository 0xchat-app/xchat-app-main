// Apple Sign-In + NostrSocialLogin KDF: obtain credential, parse sub, derive Keychain.

import 'dart:typed_data';

import 'package:jwt_decode/jwt_decode.dart';
import 'package:nostr_core_dart/nostr.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'nostr_social_login_kdf.dart';

/// Result of Apple Sign-In for Nostr key derivation.
class AppleCredential {
  const AppleCredential({
    required this.identityToken,
    required this.userIdentifier,
    this.email,
    this.givenName,
    this.familyName,
  });

  final String identityToken;
  final String userIdentifier;
  final String? email;
  final String? givenName;
  final String? familyName;
}

/// Helper for Apple Sign-In and deriving Nostr Keychain via NostrSocialLogin KDF.
class AppleNostrLoginHelper {
  AppleNostrLoginHelper._();
  static final AppleNostrLoginHelper instance = AppleNostrLoginHelper._();

  /// Performs Sign in with Apple and returns credential with identityToken.
  /// Returns null if user cancelled or error.
  static Future<AppleCredential?> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final token = credential.identityToken;
      if (token == null || token.isEmpty) return null;
      return AppleCredential(
        identityToken: token,
        userIdentifier: credential.userIdentifier ?? '',
        email: credential.email,
        givenName: credential.givenName,
        familyName: credential.familyName,
      );
    } catch (_) {
      return null;
    }
  }

  /// Decodes Apple identityToken (JWT) and returns the "sub" claim (stable user id).
  static String? parseSubFromAppleIdentityToken(String identityToken) {
    try {
      final payload = Jwt.parseJwt(identityToken);
      final sub = payload['sub'];
      return sub is String ? sub : sub?.toString();
    } catch (_) {
      return null;
    }
  }

  /// Derives 32-byte key with NostrSocialLogin KDF, then builds Keychain from hex.
  /// [appleSub] is the "sub" from Apple JWT; [password] is user-chosen recovery password.
  static Keychain generateKeychainFromApple(String appleSub, String password) {
    final keyBytes = generateNostrKey('apple', appleSub, password);
    final hex = _bytesToHex(keyBytes);
    return Keychain(hex);
  }

  static String _bytesToHex(Uint8List bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
