import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/reminder_provider.dart';
import '../utils/app_theme.dart';
import '../services/location_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _mapController = MapController();
  LatLng _center = const LatLng(13.0827, 80.2707); // default: Chennai

  @override
  void initState() {
    super.initState();
    _centerOnUser();
  }

  Future<void> _centerOnUser() async {
    final pos = await LocationService.instance.getCurrentPosition();
    if (pos != null && mounted) {
      setState(() => _center = LatLng(pos.latitude, pos.longitude));
      _mapController.move(_center, 14);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reminders = context.watch<ReminderProvider>().active.where((r) => r.latitude != null && r.longitude != null);

    return Scaffold(
      appBar: AppBar(title: const Text('Map')),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(initialCenter: _center, initialZoom: 13),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.smartspot.app',
          ),
          MarkerLayer(
            markers: [
              for (final r in reminders)
                Marker(
                  point: LatLng(r.latitude!, r.longitude!),
                  width: 40,
                  height: 40,
                  child: Icon(Icons.location_on, color: AppTheme.primary, size: 36),
                ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _centerOnUser,
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }
}
