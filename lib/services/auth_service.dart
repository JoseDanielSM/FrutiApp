class AuthService {
  static const String defaultEmail = 'admin@gmail.com';
  static const String defaultPassword = '123456';

  static bool validateCredentials(String email, String password) {
    final normalizedEmail = email.trim().toLowerCase();
    return normalizedEmail == defaultEmail && password == defaultPassword;
  }
}
