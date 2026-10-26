import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/content_frame.dart';

/// Shows the signed-in account and returns to the login screen.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.user, required this.onLogout});

  final SignedInUser user;
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
              user.fullName,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(user.roleLabel, textAlign: TextAlign.center, style: muted),
            const SizedBox(height: 24),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.storage_outlined),
                    title: const Text('Database'),
                    subtitle: const Text(
                      'Sign-in uses the telemedicine database',
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text('Username'),
                    subtitle: Text(user.username),
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
