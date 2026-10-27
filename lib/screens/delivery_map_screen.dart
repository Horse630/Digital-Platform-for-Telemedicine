import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../language/ui_text.dart';

/// A map of Hong Kong for the Medication delivery tile.
///
/// Tiles come from OpenStreetMap. This screen does not create an order,
/// read the deliveries collection, or call the Hong Kong Vector Map API.
class DeliveryMapScreen extends StatelessWidget {
  const DeliveryMapScreen({super.key});

  static const _hongKong = LatLng(22.35, 114.15);
  static final _bounds = LatLngBounds(
    const LatLng(22.13, 113.82),
    const LatLng(22.58, 114.45),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.medicationDelivery)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(l10n.deliveryMapHint),
          ),
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _hongKong,
                initialZoom: 11,
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
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'digital_platform_for_telemedicine',
                ),
                const RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution('OpenStreetMap contributors'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
