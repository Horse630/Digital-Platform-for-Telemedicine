import 'package:flutter/material.dart';

import '../language/ui_text.dart';
import '../services/auth_service.dart';
import '../services/health_api.dart';

/// Manual health readings. A wearable library is not connected.
class HealthScreen extends StatefulWidget {
  const HealthScreen({
    super.key,
    required this.authService,
    required this.user,
  });

  final AuthService authService;
  final SignedInUser user;

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  static const _metrics = ['heart_rate', 'steps', 'blood_oxygen'];

  final _value = TextEditingController();
  late final HealthApi _api = HealthApi(
    authService: widget.authService,
    token: widget.user.token,
  );
  String _metric = 'heart_rate';
  List<HealthReadingRecord> _rows = const [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final rows = await _api.list();
      if (mounted) {
        setState(() {
          _rows = rows;
          _error = null;
        });
      }
    } on HealthException catch (error) {
      if (mounted) {
        setState(() => _error = error.message);
      }
    }
  }

  Future<void> _save() async {
    final value = num.tryParse(_value.text.trim());
    if (value == null) {
      return;
    }
    try {
      await _api.save(metric: _metric, value: value);
      _value.clear();
      await _load();
    } on HealthException catch (error) {
      if (mounted) {
        setState(() => _error = error.message);
      }
    }
  }

  String _label(String metric) {
    final l10n = context.l10n;
    switch (metric) {
      case 'steps':
        return l10n.stepsCount;
      case 'blood_oxygen':
        return l10n.bloodOxygen;
      default:
        return l10n.heartRate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final patient = widget.user.role == 'patient';
    return Scaffold(
      appBar: AppBar(title: Text(l10n.healthTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.healthHint),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              localizeMessage(l10n, _error!),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          if (patient) ...[
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _metric,
              decoration: InputDecoration(labelText: l10n.healthTitle),
              items: [
                for (final metric in _metrics)
                  DropdownMenuItem(value: metric, child: Text(_label(metric))),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _metric = value);
                }
              },
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('healthValueField'),
              controller: _value,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: _label(_metric)),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _save,
              child: Text(l10n.saveReading),
            ),
          ],
          const SizedBox(height: 16),
          for (final row in _rows)
            ListTile(
              title: Text('${_label(row.metric)} ${row.value} ${row.unit}'),
            ),
        ],
      ),
    );
  }
}
