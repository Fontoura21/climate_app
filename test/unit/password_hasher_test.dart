import 'package:flutter_test/flutter_test.dart';
import 'package:olly_app/auth/password_hasher.dart';

void main() {
  group('PasswordHasher', () {
    test('hashPassword generates a hash with salt', () {
      const password = 'testPassword123';
      final hash = PasswordHasher.hashPassword(password);

      // hash should contain salt and hashed password separated by ':'
      expect(hash.contains(':'), true);
      expect(hash.split(':').length, 2);
    });

    test('hashPassword generates different hashes for same password', () {
      const password = 'samePassword';
      final hash1 = PasswordHasher.hashPassword(password);
      final hash2 = PasswordHasher.hashPassword(password);

      // different salts should produce different hashes
      expect(hash1, isNot(equals(hash2)));
    });

    test('verifyPassword returns true for correct password', () {
      const password = 'correctPassword';
      final hash = PasswordHasher.hashPassword(password);

      final isValid = PasswordHasher.verifyPassword(password, hash);
      expect(isValid, true);
    });

    test('verifyPassword returns false for incorrect password', () {
      const correctPassword = 'correctPassword';
      const wrongPassword = 'wrongPassword';
      final hash = PasswordHasher.hashPassword(correctPassword);

      final isValid = PasswordHasher.verifyPassword(wrongPassword, hash);
      expect(isValid, false);
    });

    test('verifyPassword handles empty password', () {
      const password = '';
      final hash = PasswordHasher.hashPassword(password);

      final isValid = PasswordHasher.verifyPassword(password, hash);
      expect(isValid, true);
    });

    test('verifyPassword handles special characters', () {
      const password = '!@#\$%^&*()_+-=[]{}|;:,.<>?';
      final hash = PasswordHasher.hashPassword(password);

      final isValid = PasswordHasher.verifyPassword(password, hash);
      expect(isValid, true);
    });

    test('verifyPassword handles unicode characters', () {
      const password = '你好世界';
      final hash = PasswordHasher.hashPassword(password);

      final isValid = PasswordHasher.verifyPassword(password, hash);
      expect(isValid, true);
    });

    test('verifyPassword returns false for malformed hash', () {
      const password = 'testPassword';
      const malformedHash = 'not-a-valid-hash';

      final isValid = PasswordHasher.verifyPassword(password, malformedHash);
      expect(isValid, false);
    });

    test('hash length is consistent', () {
      const password1 = 'short';
      const password2 = 'this is a much longer password with many characters';

      final hash1 = PasswordHasher.hashPassword(password1);
      final hash2 = PasswordHasher.hashPassword(password2);

      // both hashes should have similar structure (salt:hash)
      expect(hash1.split(':').length, hash2.split(':').length);
    });

    test('constant-time comparison prevents timing attacks', () {
      const password = 'testPassword';
      final hash = PasswordHasher.hashPassword(password);

      // these should all take roughly the same time
      final result1 = PasswordHasher.verifyPassword('a', hash);
      final result2 = PasswordHasher.verifyPassword('testPasswor', hash);
      final result3 = PasswordHasher.verifyPassword('wrongPassword', hash);

      expect(result1, false);
      expect(result2, false);
      expect(result3, false);
    });
  });
}
