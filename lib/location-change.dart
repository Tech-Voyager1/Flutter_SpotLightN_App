import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

void main() {
  runApp(RealTimeMap());
}

class RealTimeMap extends StatefulWidget {
  @override
  _RealTimeMapState createState() => _RealTimeMapState();
}

class _RealTimeMapState extends State<RealTimeMap> {
  bool location_access = false;
  Location _location = Location();
  LatLng _currentLatLng = LatLng(0, 0);

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    if (!location_access) {
      // Check if location services are enabled
      _serviceEnabled = await _location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await _location.requestService();
        if (!_serviceEnabled) {
          return;
        }
      }

      // Check location permissions
      _permissionGranted = await _location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await _location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          return;
        }
      }

      // Get current location
      LocationData _locationData = await _location.getLocation();
      setState(() {
        _currentLatLng =
            LatLng(_locationData.latitude!, _locationData.longitude!);
        location_access = false;
        // Print current location to console
      });
    }

    // Start listening to location changes
    _location.onLocationChanged.listen((LocationData loc) {
      setState(() {
        _currentLatLng = LatLng(loc.latitude!, loc.longitude!);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // _getCurrentLocation();
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Real-Time Location"),
        ),
        body: FlutterMap(
          options: MapOptions(
            center: _currentLatLng,
            zoom: 4.0,
          ),
          children: [
            TileLayer(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c'],
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: _currentLatLng,
                  builder: (ctx) => Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
