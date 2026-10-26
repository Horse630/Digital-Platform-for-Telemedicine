import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/avatar_image.dart';
import '../services/profile_api.dart';
import '../theme/app_theme.dart';
import '../theme/theme_settings.dart';
import '../widgets/account_avatar.dart';
import '../widgets/content_frame.dart';

/// Profile photo, account fields, password, and the device theme.
///
/// Photo, username, description, and password are saved through the Node API.
/// Color and dark mode stay on this device.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.user,
    required this.authService,
    required this.onUserChanged,
  });

  final SignedInUser user;
  final AuthService authService;
  final ValueChanged<SignedInUser> onUserChanged;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static final _usernamePattern = RegExp(r'^[A-Za-z0-9._-]{3,40}$');

  final _profileFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _description = TextEditingController();
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();

  late SignedInUser _user = widget.user;
  String _avatarBase64 = '';
  String _avatarMime = '';
  String? _profileError;
  String? _passwordError;
  bool _loading = true;
  bool _ready = false;
  bool _saving = false;
  bool _changingPassword = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _username.dispose();
    _description.dispose();
    _currentPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  ProfileApi get _api => ProfileApi(authService: widget.authService, token: _user.token);

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _profileError = null;
    });
    try {
      final details = await _api.load();
      if (!mounted) {
        return;
      }
      _username.text = details.username;
      _description.text = details.description;
      _avatarBase64 = details.avatarBase64;
      _avatarMime = details.avatarMime;
      _ready = true;
    } on ProfileException catch (error) {
      if (!mounted) {
        return;
      }
      _profileError = error.message;
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _pickPhoto() async {
    const group = XTypeGroup(
      label: 'images',
      extensions: <String>['jpg', 'jpeg', 'png', 'webp'],
    );
    final file = await openFile(acceptedTypeGroups: const [group]);
    if (file == null || !mounted) {
      return;
    }
    final avatar = avatarFromBytes(await file.readAsBytes());
    if (!mounted) {
      return;
    }
    if (avatar == null) {
      setState(() {
        _profileError = 'Choose a JPEG, PNG, or WebP image under 512 KB.';
      });
      return;
    }
    setState(() {
      _avatarBase64 = avatar.base64Data;
      _avatarMime = avatar.mime;
      _profileError = null;
    });
  }

  Future<void> _saveProfile() async {
    if (!_profileFormKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _saving = true;
      _profileError = null;
    });
    try {
      final details = await _api.save(
        username: _username.text,
        description: _description.text,
        avatarBase64: _avatarBase64,
        avatarMime: _avatarBase64.isEmpty ? '' : _avatarMime,
      );
      if (!mounted) {
        return;
      }
      _user = _user.copyWith(
        username: details.username,
        token: details.token ?? _user.token,
      );
      _avatarBase64 = details.avatarBase64;
      _avatarMime = details.avatarMime;
      widget.onUserChanged(_user);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved.')),
      );
    } on ProfileException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _profileError = error.message);
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _changePassword() async {
    if (_changingPassword) {
      return;
    }
    // The button stays enabled. These checks explain a rejected password.
    if (!_passwordFormKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _changingPassword = true;
      _passwordError = null;
    });
    try {
      final message = await _api.changePassword(
        currentPassword: _currentPassword.text,
        newPassword: _newPassword.text,
      );
      if (!mounted) {
        return;
      }
      _currentPassword.clear();
      _newPassword.clear();
      _confirmPassword.clear();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } on ProfileException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _passwordError = error.message);
    } finally {
      if (mounted) {
        setState(() => _changingPassword = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ThemeScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ContentFrame(
        maxWidth: 560,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            _sectionTitle('Appearance'),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    key: const Key('darkModeSwitch'),
                    secondary: const Icon(Icons.dark_mode_outlined),
                    title: const Text('Dark mode'),
                    subtitle: const Text('Switch the app between light and dark'),
                    value: settings.isDark,
                    onChanged: (dark) {
                      settings.setDark(dark);
                    },
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'App color',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Color and dark mode stay on this device.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            for (final choice in AppTheme.choices)
                              _ColorChoice(
                                choice: choice,
                                selected:
                                    settings.seed.toARGB32() ==
                                    choice.color.toARGB32(),
                                onTap: () => settings.setSeed(choice.color),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _sectionTitle('Account'),
            const SizedBox(height: 8),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (!_ready)
              _MessageBlock(
                message: _profileError ?? 'The profile could not be read.',
                action: TextButton(onPressed: _load, child: const Text('Retry')),
              )
            else
              _accountCard(),
            const SizedBox(height: 24),
            _sectionTitle('Password'),
            const SizedBox(height: 8),
            _passwordCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _accountCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _profileFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: AccountAvatar(avatarBase64: _avatarBase64, radius: 48)),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    key: const Key('uploadPhotoButton'),
                    onPressed: _saving ? null : _pickPhoto,
                    icon: const Icon(Icons.image_outlined),
                    label: const Text('Upload photo'),
                  ),
                  if (_avatarBase64.isNotEmpty)
                    TextButton(
                      key: const Key('removePhotoButton'),
                      onPressed: _saving
                          ? null
                          : () => setState(() {
                              _avatarBase64 = '';
                              _avatarMime = '';
                            }),
                      child: const Text('Remove photo'),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('settingsUsernameField'),
                controller: _username,
                decoration: const InputDecoration(labelText: 'Username'),
                textInputAction: TextInputAction.next,
                maxLength: 40,
                validator: (value) {
                  if (!_usernamePattern.hasMatch((value ?? '').trim())) {
                    return 'Use 3 to 40 letters, numbers, dots, underscores, or hyphens.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                key: const Key('settingsDescriptionField'),
                controller: _description,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                ),
                minLines: 3,
                maxLines: 5,
                maxLength: 280,
              ),
              if (_profileError != null) ...[
                const SizedBox(height: 8),
                Text(
                  _profileError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 12),
              FilledButton(
                key: const Key('saveProfileButton'),
                onPressed: _saving ? null : _saveProfile,
                child: Text(_saving ? 'Saving...' : 'Save profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _passwordCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _passwordFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                key: const Key('currentPasswordField'),
                controller: _currentPassword,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Current password'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter your current password.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('newPasswordField'),
                controller: _newPassword,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New password'),
                validator: (value) {
                  if (value == null || value.length < 8) {
                    return 'Use at least 8 characters.';
                  }
                  if (value == _currentPassword.text) {
                    return 'Choose a different password.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('confirmPasswordField'),
                controller: _confirmPassword,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirm new password'),
                validator: (value) {
                  if (value != _newPassword.text) {
                    return 'Enter the same password twice.';
                  }
                  return null;
                },
              ),
              if (_passwordError != null) ...[
                const SizedBox(height: 8),
                Text(
                  _passwordError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 12),
              FilledButton(
                key: const Key('changePasswordButton'),
                onPressed: _changePassword,
                child: Text(_changingPassword ? 'Updating...' : 'Change password'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(text, style: Theme.of(context).textTheme.titleLarge);
  }
}

class _ColorChoice extends StatelessWidget {
  const _ColorChoice({
    required this.choice,
    required this.selected,
    required this.onTap,
  });

  final ThemeChoice choice;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: choice.name,
      selected: selected,
      child: InkWell(
        key: Key('themeColor${choice.name}'),
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: CircleAvatar(
          radius: 20,
          backgroundColor: choice.color,
          child: selected ? const Icon(Icons.check, color: Colors.white) : null,
        ),
      ),
    );
  }
}

class _MessageBlock extends StatelessWidget {
  const _MessageBlock({required this.message, required this.action});

  final String message;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(message, textAlign: TextAlign.center),
        action,
      ],
    );
  }
}
