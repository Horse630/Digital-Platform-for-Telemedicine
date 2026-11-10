import 'package:flutter/material.dart';

import '../language/ui_text.dart';
import '../services/appointment_api.dart';
import '../services/auth_service.dart';
import '../services/delivery_api.dart';

/// Medicine orders for the signed-in person.
///
/// A doctor creates an order for a booked visit. The destination is the
/// patient's saved address. Status moves from preparing to in transit to
/// delivered. This panel does not call a courier.
class DeliveryOrdersPanel extends StatefulWidget {
  const DeliveryOrdersPanel({
    super.key,
    required this.authService,
    required this.user,
  });

  final AuthService authService;
  final SignedInUser user;

  @override
  State<DeliveryOrdersPanel> createState() => _DeliveryOrdersPanelState();
}

class _DeliveryOrdersPanelState extends State<DeliveryOrdersPanel> {
  late final DeliveryApi _deliveries = DeliveryApi(
    authService: widget.authService,
    token: widget.user.token,
  );
  late final AppointmentApi _appointments = AppointmentApi(
    authService: widget.authService,
    token: widget.user.token,
  );
  final _name = TextEditingController();
  final _quantity = TextEditingController(text: '1');
  List<DeliveryRecord> _orders = const [];
  List<AppointmentRecord> _visits = const [];
  String? _appointmentId;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _name.dispose();
    _quantity.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final orders = await _deliveries.list();
      final visits = widget.user.role == 'doctor'
          ? await _appointments.list()
          : const <AppointmentRecord>[];
      if (!mounted) {
        return;
      }
      setState(() {
        _orders = orders;
        _visits = visits
            .where(
              (item) =>
                  item.status == 'scheduled' || item.status == 'completed',
            )
            .toList();
        _appointmentId ??= _visits.isEmpty ? null : _visits.first.id;
        _error = null;
      });
    } on DeliveryException catch (error) {
      if (mounted) {
        setState(() => _error = error.message);
      }
    } on AppointmentException catch (error) {
      if (mounted) {
        setState(() => _error = error.message);
      }
    }
  }

  Future<void> _create() async {
    final appointmentId = _appointmentId;
    final quantity = int.tryParse(_quantity.text.trim());
    if (appointmentId == null || quantity == null) {
      return;
    }
    try {
      await _deliveries.create(
        appointmentId: appointmentId,
        medicationName: _name.text.trim(),
        quantity: quantity,
      );
      _name.clear();
      await _load();
    } on DeliveryException catch (error) {
      if (mounted) {
        setState(() => _error = error.message);
      }
    }
  }

  Future<void> _advance(DeliveryRecord order) async {
    try {
      await _deliveries.advance(order.id);
      await _load();
    } on DeliveryException catch (error) {
      if (mounted) {
        setState(() => _error = error.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.deliveryOrders, style: Theme.of(context).textTheme.titleSmall),
          if (_error != null)
            Text(
              localizeMessage(l10n, _error!),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          if (widget.user.role == 'doctor' && _visits.isNotEmpty) ...[
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _appointmentId,
              items: [
                for (final visit in _visits)
                  DropdownMenuItem(
                    value: visit.id,
                    child: Text(visit.patientName ?? visit.reason),
                  ),
              ],
              onChanged: (value) => setState(() => _appointmentId = value),
            ),
            TextField(
              controller: _name,
              decoration: InputDecoration(labelText: l10n.medicineName),
            ),
            TextField(
              controller: _quantity,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.quantity),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton(
                onPressed: _create,
                child: Text(l10n.saveDelivery),
              ),
            ),
          ],
          if (_orders.isEmpty)
            Text(l10n.noDeliveryOrders)
          else
            for (final order in _orders)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('${order.medicationName} × ${order.quantity}'),
                subtitle: Text('${order.status} · ${order.destination}'),
                trailing: widget.user.role == 'doctor' && order.status != 'delivered'
                    ? TextButton(
                        onPressed: () => _advance(order),
                        child: Text(l10n.advanceDelivery),
                      )
                    : null,
              ),
        ],
      ),
    );
  }
}
