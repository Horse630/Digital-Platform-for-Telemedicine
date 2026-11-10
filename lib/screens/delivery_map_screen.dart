import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_vector_tiles/flutter_map_vector_tiles.dart' as vt;
import 'package:latlong2/latlong.dart';

import '../language/language_settings.dart';
import '../language/ui_text.dart';
import '../services/auth_service.dart';
import '../services/public_facilities.dart';
import 'delivery_orders.dart';

/// A map of Hong Kong for the Medication delivery tile.
///
/// The teal pin is the medicine headquarters at Hong Kong Baptist University,
/// Kowloon Tong. Blue pins are public family medicine clinics and red pins are
/// Hospital Authority hospitals and institutions. Light mode uses the colorful
/// OpenFreeMap Bright style. Dark mode uses the OpenFreeMap Dark style, so the
/// map follows the app theme. This screen does not create an order or call the
/// Hong Kong Vector Map API.
class DeliveryMapScreen extends StatefulWidget {
  const DeliveryMapScreen({super.key, this.user, this.authService});

  final SignedInUser? user;
  final AuthService? authService;

  /// Ho Sin Hang Campus, Kowloon Tong.
  static const headquarters = LatLng(22.3379, 114.1820);

  static const clinicColor = Color(0xFF1565C0);
  static const hospitalColor = Color(0xFFC62828);

  /// Colorful light basemap. OpenFreeMap serves it with no API key.
  static const brightStyle = 'https://tiles.openfreemap.org/styles/bright';

  /// Dark basemap used when the app is in dark mode.
  static const darkStyle = 'https://tiles.openfreemap.org/styles/dark';

  @override
  State<DeliveryMapScreen> createState() => _DeliveryMapScreenState();
}

class _DeliveryMapScreenState extends State<DeliveryMapScreen> {
  static final _bounds = LatLngBounds(
    const LatLng(22.13, 113.82),
    const LatLng(22.58, 114.45),
  );

  List<PublicFacility> _facilities = const [];
  PublicFacility? _selected;
  vt.Style? _style;
  bool? _styleIsDark;
  int _styleRequest = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final dark = Theme.of(context).brightness == Brightness.dark;
    if (_styleIsDark == dark) {
      return;
    }
    _styleIsDark = dark;
    _loadStyle(dark);
  }

  @override
  void dispose() {
    _style?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final facilities = await PublicFacilities.load();
    if (!mounted) {
      return;
    }
    setState(() => _facilities = facilities);
  }

  Future<void> _loadStyle(bool dark) async {
    final request = ++_styleRequest;
    final uri = dark ? DeliveryMapScreen.darkStyle : DeliveryMapScreen.brightStyle;
    try {
      final style = await vt.StyleReader(uri: uri).read();
      if (!mounted || request != _styleRequest) {
        style.dispose();
        return;
      }
      final previous = _style;
      setState(() => _style = style);
      previous?.dispose();
    } catch (_) {
      // The pins stay visible on the plain background.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final languageCode = LanguageSettings.codeFor(LanguageScope.of(context).locale);
    final selected = _selected;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.medicationDelivery)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(l10n.deliveryMapHint),
          ),
          if (widget.user != null && widget.authService != null)
            DeliveryOrdersPanel(
              authService: widget.authService!,
              user: widget.user!,
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ColoredBox(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: FlutterMap(
              options: MapOptions(
                initialCenter: DeliveryMapScreen.headquarters,
                initialZoom: 15,
                minZoom: 10,
                maxZoom: 18,
                cameraConstraint: CameraConstraint.containCenter(
                  bounds: _bounds,
                ),
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.drag |
                      InteractiveFlag.pinchZoom |
                      InteractiveFlag.doubleTapZoom |
                      InteractiveFlag.scrollWheelZoom |
                      InteractiveFlag.flingAnimation,
                ),
              ),
              children: [
                if (_style != null)
                  vt.VectorTileLayer(
                    theme: _style!.theme,
                    tileProviders: _style!.providers,
                    rasterSources: _style!.rasterSources,
                    sprites: _style!.sprites,
                    glyphs: _style!.glyphs,
                  ),
                MarkerLayer(
                  markers: [
                    for (final facility in _facilities)
                      Marker(
                        point: LatLng(facility.latitude, facility.longitude),
                        width: 36,
                        height: 36,
                        alignment: Alignment.bottomCenter,
                        child: GestureDetector(
                          onTap: () => setState(() => _selected = facility),
                          child: Icon(
                            Icons.location_on,
                            color: facility.isHospital
                                ? DeliveryMapScreen.hospitalColor
                                : DeliveryMapScreen.clinicColor,
                            size: 32,
                          ),
                        ),
                      ),
                    Marker(
                      point: DeliveryMapScreen.headquarters,
                      width: 240,
                      height: 88,
                      alignment: Alignment.bottomCenter,
                      child: _HeadquartersPin(
                        key: const Key('deliveryHeadquarters'),
                        label: l10n.deliveryHeadquarters,
                      ),
                    ),
                  ],
                ),
                RichAttributionWidget(
                  attributions: [
                    for (final credit in _credits)
                      TextSourceAttribution(credit),
                  ],
                ),
              ],
            ),
                ),
              ),
            ),
          ),
          if (selected != null)
            _FacilityCard(
              facility: selected,
              languageCode: languageCode,
              onClose: () => setState(() => _selected = null),
            ),
        ],
      ),
    );
  }

  List<String> get _credits {
    final fromStyle = _style?.attributions
        .map((credit) => credit.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();
    if (fromStyle != null && fromStyle.isNotEmpty) {
      return fromStyle;
    }
    return const ['OpenFreeMap', 'OpenStreetMap contributors'];
  }
}

class _FacilityCard extends StatelessWidget {
  const _FacilityCard({
    required this.facility,
    required this.languageCode,
    required this.onClose,
  });

  final PublicFacility facility;
  final String languageCode;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hours = facility.hoursFor(languageCode);
    return Material(
      elevation: 6,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 220),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      facility.nameFor(languageCode),
                      key: const Key('facilityName'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              Text(
                facility.isHospital ? l10n.publicHospital : l10n.publicClinic,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.openingHours,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(hours.isEmpty ? l10n.hoursNotListed : hours),
              if (facility.isHospital) ...[
                const SizedBox(height: 8),
                Text(
                  facility.accidentEmergency
                      ? l10n.accidentEmergencyYes
                      : l10n.accidentEmergencyNo,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _HeadquartersPin extends StatelessWidget {
  const _HeadquartersPin({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Material(
          color: scheme.surface,
          elevation: 2,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        Icon(Icons.location_pin, color: scheme.primary, size: 36),
      ],
    );
  }
}
