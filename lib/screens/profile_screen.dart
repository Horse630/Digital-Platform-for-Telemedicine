import 'package:flutter/material.dart';

import '../widgets/content_frame.dart';

/// Shows the demo account and returns to the login screen.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.username,
    required this.onLogout,
  });

  final String username;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = Theme.of(context).textTheme.bodyMedium
        ?.copyWith(color: scheme.onSurfaceVariant);

    return ContentFrame(
      maxWidth: 520,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: scheme.primaryContainer,
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: scheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              username,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Local demo account',
              textAlign: TextAlign.center,
              style: muted,
            ),
            const SizedBox(height: 24),
            const Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.storage_outlined),
                    title: Text('Database'),
                    subtitle: Text('MongoDB is not connected yet'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.phonelink_lock_outlined),
                    title: Text('Sign-in check'),
                    subtitle: Text(
                      'The demo username and password are checked on this device',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: onLogout,
              icon: const Icon(Icons.logout),
              label: const Text('Log out'),
            ),
          ],
        ),
      ),
    );
  }
}
