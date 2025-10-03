import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

// secure password hashing utility with salt
// uses PBKDF2-like iteration with SHA-256
class PasswordHasher {
  // number of iterations for key stretching (higher = more secure but slower)
  static const int _iterations = 10000;
  static const int _saltLength = 32; // 32 bytes = 256 bits

  // generates a cryptographically secure random salt
  static String _generateSalt() {
    final random = Random.secure();
    final saltBytes =
        List<int>.generate(_saltLength, (_) => random.nextInt(256));
    return base64Url.encode(saltBytes);
  }

  // hashes a password with the given salt using iterative SHA-256
  static String _hashWithSalt(String password, String salt) {
    var bytes = utf8.encode(password + salt);

    // apply SHA-256 multiple times (key stretching)
    for (var i = 0; i < _iterations; i++) {
      bytes = utf8.encode(base64.encode(sha256.convert(bytes).bytes));
    }

    return base64Url.encode(sha256.convert(bytes).bytes);
  }

  // hashes a password and returns the complete hash string
  // format: salt:hash
  static String hashPassword(String password) {
    final salt = _generateSalt();
    final hash = _hashWithSalt(password, salt);
    return '$salt:$hash';
  }

  // verifies a password against a stored hash
  // returns true if password matches
  static bool verifyPassword(String password, String storedHash) {
    try {
      final parts = storedHash.split(':');
      if (parts.length != 2) return false;

      final salt = parts[0];
      final originalHash = parts[1];
      final newHash = _hashWithSalt(password, salt);

      // use constant-time comparison to prevent timing attacks
      return _constantTimeCompare(originalHash, newHash);
    } catch (e) {
      return false;
    }
  }

  // constant-time string comparison to prevent timing attacks
  static bool _constantTimeCompare(String a, String b) {
    if (a.length != b.length) return false;

    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }

  // example of storing the API key securely (though API keys should be in env vars)
  static String hashApiKey(String apiKey) {
    final bytes = utf8.encode(apiKey);
    final digest = sha256.convert(bytes);
    return base64Url.encode(digest.bytes);
  }
}
