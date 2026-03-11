// NostrSocialLogin KDF - Dart reimplementation matching packages/NostrSocialLogin (Rust).
// See TECHNICAL_DESIGN.md and src/lib.rs for the canonical spec.

import 'dart:typed_data';

import 'package:argon2/argon2.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/key_derivators/api.dart' show HkdfParameters;
import 'package:pointycastle/key_derivators/hkdf.dart' show HKDFKeyDerivator;

/// Fixed salt for key derivation (must match Rust: b"nostrbridge_v1").
const _salt = 'nostrbridge_v1';

/// HKDF info string (must match Rust: b"NostrSocialLogin Key Derivation v1").
const _hkdfInfo = 'NostrSocialLogin Key Derivation v1';

/// secp256k1 curve order (hex); key must be in (0, order).
const _secp256k1OrderHex =
    'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141';

/// Argon2id parameters matching Rust: memory 65536 (64MB), time 3, parallelism 1, output 32.
const _argon2Memory = 65536;
const _argon2Iterations = 3;
const _argon2Lanes = 1;
const _argon2OutputLen = 32;

/// Generates a 32-byte Nostr private key from social login credentials.
///
/// Matches NostrSocialLogin (Rust): Argon2id stretch -> HKDF -> secp256k1 range adjustment.
/// [providerId] e.g. "apple", "google".
/// [userId] e.g. Apple JWT payload "sub".
/// [password] user-chosen password for recovery.
/// Returns 32 bytes (big-endian) or throws.
Uint8List generateNostrKey(
  String providerId,
  String userId,
  String password,
) {
  final stretched = _stretchPassword(password);
  final keyMaterial = _deriveKeyWithHkdf(providerId, userId, stretched);
  return _validateAndAdjustKey(keyMaterial);
}

Uint8List _stretchPassword(String password) {
  final saltBytes = Uint8List.fromList(_salt.codeUnits);
  final params = Argon2Parameters(
    Argon2Parameters.ARGON2_id,
    saltBytes,
    iterations: _argon2Iterations,
    memory: _argon2Memory,
    lanes: _argon2Lanes,
    version: Argon2Parameters.ARGON2_VERSION_13,
  );
  final gen = Argon2BytesGenerator();
  gen.init(params);
  final out = Uint8List(_argon2OutputLen);
  gen.generateBytesFromString(password, out, 0, _argon2OutputLen);
  return out;
}

Uint8List _deriveKeyWithHkdf(
  String providerId,
  String userId,
  Uint8List stretchedPassword,
) {
  // HKDF input: provider_id:user_id:stretched_password (match Rust exactly)
  final parts = <List<int>>[
    providerId.codeUnits,
    [0x3a], // ':'
    userId.codeUnits,
    [0x3a],
    stretchedPassword,
  ];
  final ikm = Uint8List.fromList(parts.expand((e) => e).toList());
  final saltBytes = Uint8List.fromList(_salt.codeUnits);
  final infoBytes = Uint8List.fromList(_hkdfInfo.codeUnits);

  final params = HkdfParameters(ikm, 32, saltBytes, infoBytes, false);
  final hkdf = HKDFKeyDerivator(SHA256Digest());
  hkdf.init(params);
  final out = Uint8List(32);
  hkdf.deriveKey(null, 0, out, 0);
  return out;
}

Uint8List _validateAndAdjustKey(Uint8List keyMaterial) {
  final keyInt = _bytesToBigIntBe(keyMaterial);
  final order = BigInt.parse(_secp256k1OrderHex, radix: 16);

  BigInt finalKey;
  if (keyInt == BigInt.zero || keyInt >= order) {
    final orderMinusOne = order - BigInt.one;
    final remainder = keyInt % orderMinusOne;
    finalKey = remainder + BigInt.one;
  } else {
    finalKey = keyInt;
  }

  return _bigIntToBytesBe32(finalKey);
}

BigInt _bytesToBigIntBe(Uint8List bytes) {
  BigInt r = BigInt.zero;
  for (var i = 0; i < bytes.length; i++) {
    r = (r << 8) | BigInt.from(bytes[i] & 0xff);
  }
  return r;
}

/// Encode BigInt as 32-byte big-endian (low 32 bytes; Rust uses to_be_bytes).
Uint8List _bigIntToBytesBe32(BigInt n) {
  if (n == BigInt.zero) {
    return Uint8List(32);
  }
  final hex = n.toRadixString(16);
  final padded = hex.length.isOdd ? '0$hex' : hex;
  final len = padded.length ~/ 2;
  final start = len > 32 ? len - 32 : 0;
  final list = <int>[];
  for (var i = start * 2; i < padded.length; i += 2) {
    list.add(int.parse(padded.substring(i, i + 2), radix: 16));
  }
  // Left-pad with zeros to 32 bytes
  while (list.length < 32) {
    list.insert(0, 0);
  }
  return Uint8List.fromList(list.length > 32 ? list.sublist(list.length - 32) : list);
}
