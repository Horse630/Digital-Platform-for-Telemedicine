import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../language/language_settings.dart';
import '../language/ui_text.dart';
import '../services/auth_service.dart';
import '../services/avatar_image.dart';
import '../services/doctor_types.dart';
import '../services/profile_api.dart';
import '../theme/app_theme.dart';
import '../theme/theme_settings.dart';
import '../widgets/account_avatar.dart';
import '../widgets/content_frame.dart';

/// Profile photo, account fields, password, language, and the device theme.
///
/// Photo, username, description, and password are saved through the Node API.
/// Color, dark mode, font size, and language stay on this device.
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
  final _allergyInput = TextEditingController();

  late SignedInUser _user = widget.user;
  String _avatarBase64 = '';
  String _avatarMime = '';
  List<String> _specialties = [];
  List<String> _allergies = [];
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
    _allergyInput.dispose();
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
      _specialties = List<String>.from(details.specialties);
      _allergies = List<String>.from(details.allergies);
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
        specialties: _specialties,
        allergies: _allergies,
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
      _specialties = List<String>.from(details.specialties);
      _allergies = List<String>.from(details.allergies);
      widget.onUserChanged(_user);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.profileSaved)),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizeMessage(context.l10n, message))),
      );
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
    final language = LanguageScope.of(context);
    final l10n = context.l10n;
    final languageCode = LanguageSettings.codeFor(language.locale);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ContentFrame(
        maxWidth: 560,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            _sectionTitle(l10n.language),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      key: const Key('languagePicker'),
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('English'),
                          selected: languageCode == 'en',
                          onSelected: (_) => language.setLocale(
                            LanguageSettings.localeFromCode('en'),
                          ),
                        ),
                        ChoiceChip(
                          label: const Text('繁體中文'),
                          selected: languageCode == 'zh_Hant',
                          onSelected: (_) => language.setLocale(
                            LanguageSettings.localeFromCode('zh_Hant'),
                          ),
                        ),
                        ChoiceChip(
                          label: const Text('简体中文'),
                          selected: languageCode == 'zh_Hans',
                          onSelected: (_) => language.setLocale(
                            LanguageSettings.localeFromCode('zh_Hans'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.languageStaysOnDevice,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _sectionTitle(l10n.appearance),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    key: const Key('darkModeSwitch'),
                    secondary: const Icon(Icons.dark_mode_outlined),
                    title: Text(l10n.darkMode),
                    subtitle: Text(l10n.darkModeSubtitle),
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
                          l10n.appColor,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.colorStaysOnDevice,
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
                        const SizedBox(height: 16),
                        Text(
                          l10n.fontSize,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.fontSizeStaysOnDevice,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          key: const Key('fontSizePicker'),
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ChoiceChip(
                              label: Text(l10n.fontSizeSmall),
                              selected: settings.fontSize == 'small',
                              onSelected: (_) => settings.setFontSize('small'),
                            ),
                            ChoiceChip(
                              label: Text(l10n.fontSizeNormal),
                              selected: settings.fontSize == 'normal',
                              onSelected: (_) => settings.setFontSize('normal'),
                            ),
                            ChoiceChip(
                              label: Text(l10n.fontSizeLarge),
                              selected: settings.fontSize == 'large',
                              onSelected: (_) => settings.setFontSize('large'),
                            ),
                            ChoiceChip(
                              label: Text(l10n.fontSizeExtra),
                              selected: settings.fontSize == 'extra',
                              onSelected: (_) => settings.setFontSize('extra'),
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
            _sectionTitle(l10n.account),
            const SizedBox(height: 8),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (!_ready)
              _MessageBlock(
                message: localizeMessage(
                  l10n,
                  _profileError ?? 'The profile could not be read.',
                ),
                action: TextButton(onPressed: _load, child: Text(l10n.retry)),
              )
            else
              _accountCard(),
            const SizedBox(height: 24),
            _sectionTitle(l10n.passwordSection),
            const SizedBox(height: 8),
            _passwordCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _accountCard() {
    final l10n = context.l10n;
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
                    label: Text(l10n.uploadPhoto),
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
                      child: Text(l10n.removePhoto),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('settingsUsernameField'),
                controller: _username,
                decoration: InputDecoration(labelText: l10n.username),
                textInputAction: TextInputAction.next,
                maxLength: 40,
                validator: (value) {
                  if (!_usernamePattern.hasMatch((value ?? '').trim())) {
                    return l10n.usernameRule;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                key: const Key('settingsDescriptionField'),
                controller: _description,
                decoration: InputDecoration(
                  labelText: l10n.description,
                  alignLabelWithHint: true,
                ),
                minLines: 3,
                maxLines: 5,
                maxLength: 280,
              ),
              if (widget.user.role == 'doctor') _doctorTypes(),
              if (widget.user.role == 'patient') _allergyEditor(),
              if (_profileError != null) ...[
                const SizedBox(height: 8),
                Text(
                  localizeMessage(l10n, _profileError!),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 12),
              FilledButton(
                key: const Key('saveProfileButton'),
                onPressed: _saving ? null : _saveProfile,
                child: Text(_saving ? l10n.saving : l10n.saveProfile),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _doctorTypes() {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.doctorTypeLabel, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final type in doctorTypes)
                FilterChip(
                  key: Key('doctorType_$type'),
                  label: Text(localizedDoctorType(l10n, type)),
                  selected: _specialties.contains(type),
                  onSelected: _saving
                      ? null
                      : (selected) {
                          setState(() {
                            if (selected) {
                              _specialties = [..._specialties, type];
                            } else {
                              _specialties = [
                                for (final item in _specialties)
                                  if (item != type) item,
                              ];
                            }
                          });
                        },
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _addAllergy() {
    final name = _allergyInput.text.trim();
    if (name.isEmpty) {
      return;
    }
    if (name.length > 40) {
      setState(() => _profileError = 'Keep each allergy under 40 characters.');
      return;
    }
    if (_allergies.length >= 20) {
      setState(() => _profileError = 'Keep the allergy list to 20 items.');
      return;
    }
    if (_allergies.any((item) => item.toLowerCase() == name.toLowerCase())) {
      _allergyInput.clear();
      return;
    }
    setState(() {
      _allergies = [..._allergies, name];
      _allergyInput.clear();
      _profileError = null;
    });
  }

  Widget _allergyEditor() {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.allergies, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: const Key('allergyField'),
                  controller: _allergyInput,
                  decoration: InputDecoration(hintText: l10n.addAllergyHint),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _addAllergy(),
                ),
              ),
              IconButton(
                key: const Key('addAllergyButton'),
                tooltip: l10n.addAllergy,
                onPressed: _saving ? null : _addAllergy,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          if (_allergies.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final allergy in _allergies)
                  InputChip(
                    label: Text(allergy),
                    onDeleted: _saving
                        ? null
                        : () {
                            setState(() {
                              _allergies = [
                                for (final item in _allergies)
                                  if (item != allergy) item,
                              ];
                            });
                          },
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _passwordCard() {
    final l10n = context.l10n;
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
                decoration: InputDecoration(labelText: l10n.currentPassword),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.enterCurrentPassword;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('newPasswordField'),
                controller: _newPassword,
                obscureText: true,
                decoration: InputDecoration(labelText: l10n.newPassword),
                validator: (value) {
                  if (value == null || value.length < 8) {
                    return l10n.atLeast8;
                  }
                  if (value == _currentPassword.text) {
                    return l10n.differentPassword;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('confirmPasswordField'),
                controller: _confirmPassword,
                obscureText: true,
                decoration: InputDecoration(labelText: l10n.confirmNewPassword),
                validator: (value) {
                  if (value != _newPassword.text) {
                    return l10n.samePasswordTwice;
                  }
                  return null;
                },
              ),
              if (_passwordError != null) ...[
                const SizedBox(height: 8),
                Text(
                  localizeMessage(l10n, _passwordError!),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 12),
              FilledButton(
                key: const Key('changePasswordButton'),
                onPressed: _changePassword,
                child: Text(_changingPassword ? l10n.updating : l10n.changePassword),
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
      label: localizedColorName(context.l10n, choice.name),
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
