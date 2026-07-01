import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Full-screen map picker. Returns `(latitude, longitude)` record or null.
Future<(double, double)?> showLocationPickerSheet(
  BuildContext context, {
  required double initialLat,
  required double initialLng,
}) {
  return Navigator.of(context).push<(double, double)>(
    MaterialPageRoute<(double, double)>(
      fullscreenDialog: true,
      builder: (ctx) => _LocationPickerPage(
        initialLat: initialLat,
        initialLng: initialLng,
      ),
    ),
  );
}

class _LocationPickerPage extends StatefulWidget {
  const _LocationPickerPage({
    required this.initialLat,
    required this.initialLng,
  });
  final double initialLat;
  final double initialLng;

  @override
  State<_LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<_LocationPickerPage> {
  late double _lat;
  late double _lng;

  @override
  void initState() {
    super.initState();
    _lat = widget.initialLat;
    _lng = widget.initialLng;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choisir la position'),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context, (_lat, _lng)),
            icon: const Icon(Icons.check_rounded),
            label: const Text('Confirmer'),
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(widget.initialLat, widget.initialLng),
              initialZoom: 15,
              onPositionChanged: (camera, hasGesture) {
                _lat = camera.center.latitude;
                _lng = camera.center.longitude;
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.urban.alert',
              ),
            ],
          ),

          // Fixed crosshair pin
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_pin,
                size: 48,
                color: scheme.primary,
              ),
              // Offset the visual bottom of the icon to the true center
              const SizedBox(height: 48),
            ],
          ),

          // Instruction banner at bottom
          Positioned(
            bottom: 24,
            child: Material(
              color: scheme.surface.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
              elevation: 4,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Déplacez la carte pour positionner l\'épingle',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
