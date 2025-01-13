import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:location/location.dart';
import 'package:spotlight/appColor.dart';

const String apiKey =
    '5b3ce3597851110001cf6248f55d7a31499e40848c6848d7de8fa6248';
const String baseUrl =
    'https://api.openrouteservice.org/v2/directions/driving-car';

class PolyLine extends StatefulWidget {
  LatLng startPoint;
  final LatLng endPoint;

  PolyLine({Key? key, required this.startPoint, required this.endPoint})
      : super(key: key);

  @override
  _PolyLineState createState() => _PolyLineState();
}

class _PolyLineState extends State<PolyLine> {
  late MapController _mapController;
  List<LatLng> points = [];
  Location _location = Location();
  late LatLng _currentStartPoint;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _currentStartPoint = widget.startPoint;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getCoordinates(_currentStartPoint, widget.endPoint);
    });

    _location.onLocationChanged.listen((LocationData loc) {
      if (mounted)
        (setState(() {
          _currentStartPoint = LatLng(loc.latitude!, loc.longitude!);
        }));
    });
  }

  Future<void> getCoordinates(LatLng start, LatLng end) async {
    var response = await http.get(getRouteUrl(start, end));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      List listOfPoints = data['features'][0]['geometry']['coordinates'];
      setState(() {
        points = listOfPoints
            .map((p) => LatLng(p[1].toDouble(), p[0].toDouble()))
            .toList();
        Future.delayed(Duration(milliseconds: 100), () {
          _fitBounds();
        });
        //FocusManager.instance.primaryFocus?.unfocus();
      });
    } else {
      print("Failed to fetch route data");
    }
  }

  Uri getRouteUrl(LatLng start, LatLng end) {
    return Uri.parse(
        '$baseUrl?api_key=$apiKey&start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}');
  }

  void _fitBounds() {
    _mapController.rotate(0);
    LatLngBounds bounds = LatLngBounds(_currentStartPoint, widget.endPoint);
    _mapController.fitBounds(
      bounds,
      options: FitBoundsOptions(padding: EdgeInsets.all(100.0)),
    );
    //_mapController.rotate(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Route to Amenity",
          style: TextStyle(color: const Color.fromARGB(221, 253, 243, 243)),
        ),
        backgroundColor: AppColors.darkpurple,
      ),
      body: Stack(children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            maxZoom: 19,
            minZoom: 1,
            zoom: 5.0,
            center: _currentStartPoint,
          ),
          children: [
            TileLayer(
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              minZoom: 1,
              maxZoom: 19.0,
            ),
            PolylineLayer(
              polylines: [
                Polyline(
                  points: points,
                  color: AppColors.polyline,
                  strokeWidth: 5,
                  strokeCap: StrokeCap.round,
                ),
              ],
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: _currentStartPoint,
                  builder: (context) => Icon(
                    Icons.location_on,
                    color: const Color.fromARGB(255, 240, 11, 11),
                    size: 40,
                  ),
                ),
                Marker(
                  point: widget.endPoint,
                  builder: (context) => Icon(
                    Icons.location_on,
                    color: Color.fromARGB(255, 11, 126, 192),
                    size: 40,
                  ),
                ),
              ],
            ),
          ],
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _fitBounds();
        },
        child: Icon(Icons.arrow_upward),
      ),
    );
  }
}
