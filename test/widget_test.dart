import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:digital_platform_for_telemedicine/main.dart';

void main() {
  testWidgets('empty sign-in asks for both fields', (tester) async {
    await _pumpPhone(tester);

    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pump();

    expect(find.text('Enter your username'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
  });

  testWidgets('a wrong password stays on the login screen', (tester) async {
    await _pumpPhone(tester);

    await tester.enterText(find.byKey(const Key('usernameField')), 'Admin');
    await tester.enterText(find.byKey(const Key('passwordField')), 'wrong');
    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pump();

    expect(find.text('Username or password is incorrect.'), findsOneWidget);
    expect(find.text('Welcome back, Admin'), findsNothing);
  });

  testWidgets('Admin can open the dashboard, a tab, and log out', (
    tester,
  ) async {
    await _pumpPhone(tester);
    await _signIn(tester);

    expect(find.text('Welcome back, Admin'), findsOneWidget);
    expect(find.text('Patient dashboard'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Appointments'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No appointments yet'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Profile'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'Sign in'), findsOneWidget);
  });

  testWidgets('a later-phase module explains that it does not save data', (
    tester,
  ) async {
    await _pumpPhone(tester);
    await _signIn(tester);

    final sickLeave = find.text('Sick leave');
    await tester.ensureVisible(sickLeave);
    await tester.pumpAndSettle();
    await tester.tap(sickLeave);
    await tester.pumpAndSettle();

    expect(
      find.text(
        'This module is on the project schedule. This build only shows the entry point and does not save data.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    expect(find.text('Close'), findsNothing);
  });

  testWidgets('wide windows use the side rail', (tester) async {
    await _pumpSurface(tester, const Size(1200, 800));
    await _signIn(tester);

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });
}

Future<void> _pumpPhone(WidgetTester tester) {
  return _pumpSurface(tester, const Size(800, 600));
}

Future<void> _pumpSurface(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const TelemedicineApp());
}

Future<void> _signIn(WidgetTester tester) async {
  await tester.enterText(find.byKey(const Key('usernameField')), 'Admin');
  await tester.enterText(find.byKey(const Key('passwordField')), 'Admin');
  await tester.tap(find.byKey(const Key('loginButton')));
  await tester.pumpAndSettle();
}
