import 'package:flutter/material.dart';

import '../language/ui_text.dart';
import '../services/appointment_api.dart';
import '../services/auth_service.dart';
import '../services/sick_leave_api.dart';
import '../services/sick_leave_pdf.dart';

/// Sick leave certificates.
///
/// A doctor fills one in for a patient who already has an appointment.
/// A patient can only read it and download a copy.
class SickLeaveScreen extends StatefulWidget {
  const SickLeaveScreen({
    super.key,
    required this.authService,
    required this.user,
  });

  final AuthService authService;
  final SignedInUser user;

  @override
  State<SickLeaveScreen> createState() => _SickLeaveScreenState();
}

class _SickLeaveScreenState extends State<SickLeaveScreen> {
  late final SickLeaveApi _api = SickLeaveApi(
    authService: widget.authService,
    token: widget.user.token,
  );
  late final AppointmentApi _appointments = AppointmentApi(
    authService: widget.authService,
    token: widget.user.token,
  );
  List<SickLeaveCertificate> _rows = const [];
  bool _loading = true;
  String? _error;

  bool get _canIssue => widget.user.role == 'doctor';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final rows = await _api.list();
      if (!mounted) {
        return;
      }
      setState(() {
        _rows = rows;
        _error = null;
      });
    } on SickLeaveException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _error = error.message);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _issue() async {
    final issued = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => _IssuePage(api: _api, appointments: _appointments),
      ),
    );
    if (issued == true) {
      await _load();
    }
  }

  void _open(SickLeaveCertificate certificate) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _CertificatePage(certificate: certificate),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.sickLeave)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null && _rows.isEmpty
          ? Center(child: Text(localizeMessage(l10n, _error!)))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                Text(
                  _canIssue ? l10n.sickLeaveDoctorHint : l10n.sickLeavePatientHint,
                ),
                if (_canIssue) ...[
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _issue,
                    icon: const Icon(Icons.add),
                    label: Text(l10n.issueCertificate),
                  ),
                ],
                const SizedBox(height: 16),
                if (_rows.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 32),
                    child: Center(child: Text(l10n.noSickLeave)),
                  )
                else
                  for (final row in _rows) ...[
                    Card(
                      child: ListTile(
                        title: Text(row.patient.fullName),
                        subtitle: Text(row.certificateNumber),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _open(row),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
              ],
            ),
    );
  }
}

class _IssuePage extends StatefulWidget {
  const _IssuePage({required this.api, required this.appointments});

  final SickLeaveApi api;
  final AppointmentApi appointments;

  @override
  State<_IssuePage> createState() => _IssuePageState();
}

class _IssuePageState extends State<_IssuePage> {
  final _address = TextEditingController();
  final _unfit = TextEditingController();
  final _sickness = TextEditingController();
  final _signature = TextEditingController();
  List<AppointmentRecord> _visits = const [];
  String? _appointmentId;
  DateTime? _from;
  DateTime? _until;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _address.dispose();
    _unfit.dispose();
    _sickness.dispose();
    _signature.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final rows = await widget.appointments.list();
      final visits = [
        for (final row in rows)
          if (row.patientId.isNotEmpty &&
              (row.status == 'scheduled' || row.status == 'completed'))
            row,
      ];
      if (!mounted) {
        return;
      }
      setState(() {
        _visits = visits;
        _error = null;
      });
    } on AppointmentException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _error = error.message);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  int get _days {
    final from = _from;
    final until = _until;
    if (from == null || until == null || until.isBefore(from)) {
      return 0;
    }
    return until.difference(from).inDays + 1;
  }

  Future<void> _pickDate({required bool start}) async {
    final now = DateTime.now();
    final initial = start ? (_from ?? now) : (_until ?? _from ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      if (start) {
        _from = DateTime(picked.year, picked.month, picked.day);
      } else {
        _until = DateTime(picked.year, picked.month, picked.day);
      }
    });
  }

  String _iso(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  Future<void> _submit() async {
    if (_saving) {
      return;
    }
    final appointmentId = _appointmentId;
    final from = _from;
    final until = _until;
    if (appointmentId == null || appointmentId.isEmpty) {
      _snack('Choose an appointed patient.');
      return;
    }
    if (from == null) {
      _snack('Enter the start date.');
      return;
    }
    if (until == null) {
      _snack('Enter the end date.');
      return;
    }
    if (until.isBefore(from)) {
      _snack('The end date must be on or after the start date.');
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.api.issue(
        appointmentId: appointmentId,
        patientAddress: _address.text,
        unfitFor: _unfit.text,
        validFrom: _iso(from),
        validTo: _iso(until),
        summary: _sickness.text,
        signature: _signature.text,
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } on SickLeaveException catch (error) {
      if (!mounted) {
        return;
      }
      _snack(error.message);
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(localizeMessage(context.l10n, message))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final selected = _appointmentId;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.issueCertificate)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(localizeMessage(l10n, _error!)))
          : _visits.isEmpty
          ? Center(child: Text(l10n.noAppointedPatients))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selected,
                  decoration: InputDecoration(
                    labelText: l10n.selectAppointment,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    for (final visit in _visits)
                      DropdownMenuItem(
                        value: visit.id,
                        child: Text(
                          '${visit.patientName ?? l10n.unknown} · ${certificateDate(visit.scheduledAt)}',
                        ),
                      ),
                  ],
                  onChanged: (value) => setState(() => _appointmentId = value),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _address,
                  decoration: InputDecoration(
                    labelText: l10n.patientAddress,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _unfit,
                  decoration: InputDecoration(
                    labelText: l10n.unfitFor,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _pickDate(start: true),
                        child: Text(
                          _from == null
                              ? l10n.sickFrom
                              : '${l10n.sickFrom} ${_iso(_from!)}',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _pickDate(start: false),
                        child: Text(
                          _until == null
                              ? l10n.sickUntil
                              : '${l10n.sickUntil} ${_iso(_until!)}',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('${l10n.numberOfDays} ${_days == 0 ? '-' : '$_days'}'),
                const SizedBox(height: 12),
                TextField(
                  controller: _sickness,
                  minLines: 2,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: l10n.sickness,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _signature,
                  decoration: InputDecoration(
                    labelText: l10n.doctorSignature,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _saving ? null : _submit,
                  child: Text(l10n.issueCertificate),
                ),
              ],
            ),
    );
  }
}

class _CertificatePage extends StatelessWidget {
  const _CertificatePage({required this.certificate});

  final SickLeaveCertificate certificate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(certificate.certificateNumber),
        actions: [
          IconButton(
            tooltip: l10n.downloadCertificate,
            onPressed: () => downloadCertificate(certificate),
            icon: const Icon(Icons.download_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _CertificateSheet(certificate: certificate),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => downloadCertificate(certificate),
            icon: const Icon(Icons.download_outlined),
            label: Text(l10n.downloadCertificate),
          ),
        ],
      ),
    );
  }
}

class _CertificateSheet extends StatelessWidget {
  const _CertificateSheet({required this.certificate});

  final SickLeaveCertificate certificate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.appTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.sickCertTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n.referenceNumber} ${certificate.certificateNumber}',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(l10n.toWhom),
            const SizedBox(height: 16),
            _Field(label: l10n.certifyDoctor, value: certificate.doctor.fullName),
            _Field(label: l10n.herebyCertify, value: certificate.patient.fullName),
            _Field(label: l10n.patientAddress, value: certificate.patientAddress),
            _Field(label: l10n.unfitFor, value: certificate.unfitFor),
            _Field(
              label: l10n.sickFrom,
              value: certificateDate(certificate.validFrom),
            ),
            _Field(
              label: l10n.sickUntil,
              value: certificateDate(certificate.validTo),
            ),
            _Field(label: l10n.numberOfDays, value: '${certificate.dayCount}'),
            _Field(label: l10n.sickness, value: certificate.summary),
            const SizedBox(height: 12),
            _Field(
              label: l10n.dateOfIssue,
              value: certificateDate(certificate.issuedOn),
            ),
            _Field(label: l10n.doctorSignature, value: certificate.signature),
            _Field(label: l10n.licenceNumber, value: certificate.doctor.licenseNumber),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final shown = value.trim().isEmpty ? '-' : value.trim();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: shown),
          ],
        ),
      ),
    );
  }
}
