import 'package:flutter_test/flutter_test.dart';

import 'package:digital_platform_for_telemedicine/services/auth_service.dart';

void main() {
  const auth = AuthService();

  test('accepts the demo account and ignores spaces around the username', () {
    expect(auth.signIn('Admin', 'Admin'), 'Admin');
    expect(auth.signIn(' Admin ', 'Admin'), 'Admin');
  });

  test('rejects a different username, password, or letter case', () {
    expect(auth.signIn('admin', 'Admin'), isNull);
    expect(auth.signIn('Admin', 'admin'), isNull);
    expect(auth.signIn('Admin', 'Admin '), isNull);
    expect(auth.signIn('', ''), isNull);
  });
}
