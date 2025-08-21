import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  static const LatLng _initialPosition = LatLng(-6.200000, 106.816666); // Default to Jakarta
  final List<Marker> _markers = [];
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    // Initialize markers
    _markers.addAll([
      Marker(
        point: const LatLng(-6.197, 106.814),
        width: 80,
        height: 80,
        child: GestureDetector(
          onTap: () {
            // Handle marker tap
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Toko Sembako Maju')));
          },
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.store, color: Colors.blue, size: 30),
              Text('Toko Sembako Maju', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
      Marker(
        point: const LatLng(-6.205, 106.820),
        width: 80,
        height: 80,
        child: GestureDetector(
          onTap: () {
            // Handle marker tap
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Toko Sejahtera')));
          },
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.store, color: Colors.blue, size: 30),
              Text('Toko Sejahtera', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
      Marker(
        point: const LatLng(-6.195, 106.810),
        width: 80,
        height: 80,
        child: GestureDetector(
          onTap: () {
            // Handle marker tap
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Warung Makan Enak')));
          },
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.store, color: Colors.blue, size: 30),
              Text('Warung Makan Enak', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(initialCenter: _initialPosition, initialZoom: 8.0),
          children: [
            TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.example.salesman_mobile'),
            MarkerLayer(markers: _markers),
          ],
        ),
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Cari toko terdekat...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey[400]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: () {
              // Center map on user's location
              // In a real app, you would get the user's actual location here
              _mapController.move(_initialPosition, 12.0);
            },
            child: const Icon(Icons.my_location),
          ),
        ),
      ],
    );
  }
}
