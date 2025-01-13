// import 'package:flutter/material.dart';
// //import 'package:helloworld/main.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:geolocator/geolocator.dart'; // Import geolocator
// //import 'package:helloworld/gridview.dart'; //to use the index_ variable

// void main() => runApp(OverpassAPIApp());

// class OverpassAPIApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       home: OverpassAPIScreen(),
//     );
//   }
// }

// class OverpassAPIScreen extends StatefulWidget {
//   @override
//   _OverpassAPIScreenState createState() => _OverpassAPIScreenState();
// }

// class _OverpassAPIScreenState extends State<OverpassAPIScreen> {
//   List<dynamic> policeStations = [];
//   bool isLoading = true;
//   bool hasLocationPermission = false;
//   double? currentLatitude;
//   double? currentLongitude;
//   double? radius = 5000;

//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//   }

//   String? amenity;
//   void check_Amenity() {
//     switch (index_) {
//       case 1:
//         amenity = "hospital";
//         break;
//       case 2:
//         amenity = "police";
//         break;
//       case 3:
//         amenity = "bus_station";
//         break;
//       case 4:
//         amenity = "cafe";
//         break;
//       default:
//         amenity = "cafe";
//     }
//   }

//   // Function to get the current location
//   Future<void> _getCurrentLocation() async {
//     LocationPermission permission = await Geolocator.requestPermission();
//     if (permission == LocationPermission.always ||
//         permission == LocationPermission.whileInUse) {
//       setState(() {
//         hasLocationPermission = true;
//       });
//       Position position = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high);
//       setState(() {
//         currentLatitude = position.latitude;
//         currentLongitude = position.longitude;
//       });
//       fetchPoliceStations(); // Fetch data after getting location
//     } else {
//       setState(() {
//         hasLocationPermission = false;
//       });
//       print("Location permission denied");
//     }
//   }

//   // Fetch police stations using the current location
//   Future<void> fetchPoliceStations() async {
//     if (currentLatitude == null || currentLongitude == null) {
//       return; // Exit if location is not yet fetched
//     } else
//       check_Amenity();
//     final String url =
//         "https://overpass-api.de/api/interpreter?data=[out:json];node[amenity=$amenity](around:$radius,$currentLatitude,$currentLongitude);out;";
//     print(url);
//     try {
//       final response = await http.get(Uri.parse(url));
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         print(data);
//         setState(() {
//           policeStations = data['elements'] ?? [];
//           isLoading = false;
//         });
//       } else {
//         throw Exception("Failed to load data");
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//       print("Error: $e");
//     }
//   }

//   // Function to calculate the distance between two coordinates
//   double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
//     // Using Geolocator to calculate the distance between two coordinates in meters
//     return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Police Stations'),
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : policeStations.isEmpty
//               ? Center(child: Text('No police stations found.'))
//               : ListView.builder(
//                   itemCount: policeStations.length,
//                   itemBuilder: (context, index) {
//                     final station = policeStations[index];
//                     final stationLat = station['lat'];
//                     final stationLon = station['lon'];

//                     // Calculate the distance between the current location and the police station
//                     double distance = calculateDistance(
//                       currentLatitude!,
//                       currentLongitude!,
//                       stationLat,
//                       stationLon,
//                     );

//                     return ListTile(
//                       title:
//                           Text(station['tags']?['name'] ?? 'Unnamed Station'),
//                       subtitle: Text(
//                           "Latitude: ${station['lat']}, Longitude: ${station['lon']}\nDistance: ${distance.toStringAsFixed(2)} meters"),
//                       leading:
//                           Icon(Icons.local_police, color: Color(0xff7fb8e6)),
//                     );
//                   },
//                 ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Navigator.push(
//               context, MaterialPageRoute(builder: (context) => map()));
//         },
//         child: Icon(Icons.arrow_back),
//       ),
//     );
//   }
// }
