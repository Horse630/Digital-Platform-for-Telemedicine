/// Local stand-in for a MongoDB user lookup.
///
/// Phase 1 has no database connection. [signIn] accepts one demo account
/// so the login screen, home dashboard, and navigation can be tested.
class AuthService {
  const AuthService();

  static const demoUsername = 'Admin';
  static const demoPassword = 'Admin';

  /// Returns the canonical username when the pair matches.
  ///
  /// Spaces around the username are ignored. The password is compared
  /// exactly, including spaces. Returns null when the pair does not match.
  String? signIn(String username, String password) {
    final trimmedName = username.trim();
    if (trimmedName == demoUsername && password == demoPassword) {
      return demoUsername;
    }
    return null;
  }
}
