import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/profile_api.dart';
import '../widgets/account_avatar.dart';
import '../widgets/content_frame.dart';
import 'settings_screen.dart';

/// Shows the signed-in account, opens Settings, and returns to the login screen.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.user,
    required this.authService,
    required this.onLogout,
    required this.onUserChanged,
  });

  final SignedInUser user;
  final AuthService authService;
  final VoidCallback onLogout;
  final ValueChanged<SignedInUser> onUserChanged;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _description = '';
  String _avatarBase64 = '';
  List<String> _specialties = const [];
  List<String> _allergies = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user.token != widget.user.token) {
      _load();
    }
  }

  Future<void> _load() async {
    try {
      final details = await ProfileApi(
        authService: widget.authService,
        token: widget.user.token,
      ).load();
      if (!mounted) {
        return;
      }
      setState(() {
        _description = details.description;
        _avatarBase64 = details.avatarBase64;
        _specialties = details.specialties;
        _allergies = details.allergies;
      });
    } on ProfileException {
      // The username from sign-in is still shown when the profile request fails.
    }
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SettingsScreen(
          user: widget.user,
          authService: widget.authService,
          onUserChanged: widget.onUserChanged,
        ),
      ),
    );
    if (mounted) {
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    return ContentFrame(
      maxWidth: 520,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: AccountAvatar(avatarBase64: _avatarBase64)),
            const SizedBox(height: 16),
            Text(
              widget.user.fullName,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(widget.user.roleLabel, textAlign: TextAlign.center, style: muted),
            if (_description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(_description, textAlign: TextAlign.center),
            ],
            if (_specialties.isNotEmpty || _allergies.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final tag in widget.user.role == 'doctor'
                      ? _specialties
                      : _allergies)
                    Chip(label: Text(tag)),
                ],
              ),
            ],
            const SizedBox(height: 24),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text('Username'),
                    subtitle: Text(widget.user.username),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              key: const Key('settingsButton'),
              onPressed: _openSettings,
              icon: const Icon(Icons.settings_outlined),
              label: const Text('Settings'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: widget.onLogout,
              icon: const Icon(Icons.logout),
              label: const Text('Log out'),
            ),
          ],
        ),
      ),
    );
  }
}
