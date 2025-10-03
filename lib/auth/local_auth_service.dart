import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'password_hasher.dart';

// local authentication service with secure password hashing
// this is an alternative to Supabase for demonstration purposes
class LocalAuthService {
  static const String _usersKey = 'local_users';
  static const String _currentUserKey = 'current_user';

  // register a new user with hashed password
  Future<bool> register(String email, String password) async {
    try {
      // get existing users
      final users = await _getUsers();

      // check if user already exists
      if (users.containsKey(email)) {
        throw Exception('User already exists');
      }

      // hash the password with salt
      final hashedPassword = PasswordHasher.hashPassword(password);

      // store user with hashed password
      users[email] = {
        'email': email,
        'passwordHash': hashedPassword,
        'createdAt': DateTime.now().toIso8601String(),
      };

      await _saveUsers(users);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  // login with email and password
  Future<bool> login(String email, String password) async {
    try {
      final users = await _getUsers();

      // check if user exists
      if (!users.containsKey(email)) {
        throw Exception('Invalid email or password');
      }

      final user = users[email]!;
      final storedHash = user['passwordHash'] as String;

      // verify password using secure comparison
      if (!PasswordHasher.verifyPassword(password, storedHash)) {
        throw Exception('Invalid email or password');
      }

      // store current logged-in user
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, email);

      return true;
    } catch (e) {
      rethrow;
    }
  }

  // logout current user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  // get current logged-in user email
  Future<String?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserKey);
  }

  // check if user is logged in
  Future<bool> isLoggedIn() async {
    final email = await getCurrentUser();
    return email != null;
  }

  // change password for current user
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      final currentEmail = await getCurrentUser();
      if (currentEmail == null) {
        throw Exception('No user logged in');
      }

      final users = await _getUsers();
      final user = users[currentEmail]!;
      final storedHash = user['passwordHash'] as String;

      // verify old password
      if (!PasswordHasher.verifyPassword(oldPassword, storedHash)) {
        throw Exception('Invalid current password');
      }

      // hash new password
      final newHash = PasswordHasher.hashPassword(newPassword);
      user['passwordHash'] = newHash;
      user['passwordChangedAt'] = DateTime.now().toIso8601String();

      users[currentEmail] = user;
      await _saveUsers(users);

      return true;
    } catch (e) {
      rethrow;
    }
  }

  // private helper methods

  Future<Map<String, Map<String, dynamic>>> _getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);

    if (usersJson == null) {
      return {};
    }

    final decoded = json.decode(usersJson) as Map<String, dynamic>;
    return decoded.map(
        (key, value) => MapEntry(key, Map<String, dynamic>.from(value as Map)));
  }

  Future<void> _saveUsers(Map<String, Map<String, dynamic>> users) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = json.encode(users);
    await prefs.setString(_usersKey, usersJson);
  }

  // debug method: clear all users (for development only)
  Future<void> clearAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usersKey);
    await prefs.remove(_currentUserKey);
  }
}
