// import 'package:flutter/material.dart';
// import 'package:spotlight/polyline.dart';
// import 'package:spotlight/heroSection.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:geolocator/geolocator.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';

// //import 'cacheTile.dart';
// double? currentLatitude; //to be used b other modules
// double? currentLongitude;
// int index = index_;
// //index_ from heroscreen
// String? amenity;

// class MapScreen extends StatelessWidget {
//   const MapScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: mapScreen(),
//     );
//   }
// }

// class mapScreen extends StatefulWidget {
//   const mapScreen({super.key});

//   @override
//   _mapScreenState createState() => _mapScreenState();
// }

// class _mapScreenState extends State<mapScreen>
//     with SingleTickerProviderStateMixin {
//   List<dynamic> amenities = [];
//   bool isLoadingMap = true; // Loading state for the map
//   bool isLoadingAmenities = true; // Loading state for the amenities list

//   double? radius = 5000;
//   double sliverAppBarHeight = 0;
//   double expandedHeight = 50;
//   double? collapsedHeight;
//   int index = index_;

//   //MapController mapController = MapController();

//   late AnimationController _animationController;
//   late Animation<LatLng> _animation;
//   late MapController mapController;

//   @override
//   void initState() {
//     super.initState();
//     mapController = MapController();
//     // _getCurrentLocation();
//     //_getCurrentLocation();
//     isLoadingMap = false;
//     fetchAmenities();

//     // Initialize AnimationController for smooth map transition
//     _animationController = AnimationController(
//       duration: Duration(seconds: 2),
//       vsync: this,
//     );
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   void _chooseAmenity() {
//     print("Indexx is : $index");
//     switch (index) {
//       case 1:
//         amenity = "[amenity=hospital]";
//         break;
//       case 2:
//         amenity = "[amenity=police]";
//         break;
//       case 3:
//         amenity = "[amenity=bus_station]";
//         break;
//       case 4:
//         amenity = "[railway=station]";
//         break;
//       default:
//         amenity = "[aminety=cafe]";
//     }
//   }

//   Future<void> _getCurrentLocation() async {
//     print("geting current location");
//     LocationPermission permission = await Geolocator.requestPermission();
//     if (permission == LocationPermission.always ||
//         permission == LocationPermission.whileInUse) {
//       Position position = await Geolocator.getCurrentPosition(
//           // ignore: deprecated_member_use
//           desiredAccuracy: LocationAccuracy.high);
//       setState(() {
//         print("set state");
//         currentLatitude = position.latitude;
//         currentLongitude = position.longitude;
//         isLoadingMap = false; // Map loading complete
//       });
//       fetchAmenities(); //as per index_ value from heroscreen
//     }
//   }

//   Future<String> getAddress(double latitude, double longitude) async {
//     final String url =
//         'https://api.openrouteservice.org/geocode/reverse?api_key=5b3ce3597851110001cf6248abe0b9e0629e4f4a8fd74d7440734534&point.lon=$longitude&point.lat=$latitude&layers=address';

//     try {
//       final response = await http.get(Uri.parse(url));
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['features'] != null && data['features'].isNotEmpty) {
//           final address =
//               data['features'][0]['properties']['label'] ?? 'Address not found';
//           return address;
//         } else {
//           return 'Address not found';
//         }
//       } else {
//         return 'Failed to get address';
//       }
//     } catch (e) {
//       return 'Error fetching address';
//     }
//   }

//   Future<void> fetchAmenities() async {
//     if (currentLatitude == null || currentLongitude == null) return;

//     _chooseAmenity();

//     print("inside fetch ainety");
//     //amenity = "hospital"; // Example amenity
//     final String url =
//         "https://overpass-api.de/api/interpreter?data=[out:json];node$amenity(around:$radius,$currentLatitude,$currentLongitude);out;";
//     print(url);

//     try {
//       final response = await http.get(Uri.parse(url));
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         print(data);
//         List<Map<String, dynamic>> fetchedAmenities = [];

//         for (var amenity in data['elements']) {
//           print("inside foor loop");
//           final double amenityLat = amenity['lat'];
//           final double amenityLon = amenity['lon'];
//           String address = await getAddress(amenityLat, amenityLon);

//           fetchedAmenities.add({
//             'name': amenity['tags']?['name'] ?? 'Unnamed Place',
//             'lat': amenityLat,
//             'lon': amenityLon,
//             'address': address,
//           });
//         }

//         setState(() {
//           amenities = fetchedAmenities;
//           isLoadingAmenities = false; // Amenities loading complete
//         });
//       }
//     } catch (e) {
//       setState(() {
//         isLoadingAmenities = false;
//       });
//     }
//   }

//   final ScrollController _scrollController = ScrollController();
//   void _resetScrollPosition() {
//     _scrollController.animateTo(
//       0.0,
//       duration: Duration(milliseconds: 500),
//       curve: Curves.easeOut,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     double screenHeight = MediaQuery.of(context).size.height;

//     return Scaffold(
//       backgroundColor: Color(0xffc450af),
//       // appBar: AppBar(
//       //   title: Text('Nearby Amenities'),
//       //   backgroundColor: Colors.deepPurpleAccent,
//       // ),
//       body: CustomScrollView(
//         controller: _scrollController,
//         slivers: [
//           SliverAppBar(
//             expandedHeight: screenHeight / 2, // Maximum height
//             collapsedHeight: screenHeight / 4, // Minimum height
//             pinned: true,
//             floating: true,
//             flexibleSpace: LayoutBuilder(
//               builder: (BuildContext context, BoxConstraints constraints) {
//                 sliverAppBarHeight = constraints.biggest.height;

//                 double mapHeight = screenHeight / 1.7;
//                 // if (sliverAppBarHeight > screenHeight / 3) {
//                 //   mapHeight = screenHeight / 2;
//                 // } else if (sliverAppBarHeight > screenHeight / 4) {
//                 //   mapHeight = screenHeight / 3;
//                 // } else {
//                 //   mapHeight = screenHeight / 4;
//                 // }

//                 return SizedBox(
//                   height: mapHeight,
//                   child: isLoadingMap
//                       ? Center(child: CircularProgressIndicator())
//                       : FlutterMap(
//                           mapController: mapController,
//                           options: MapOptions(
//                             center: LatLng(currentLatitude!, currentLongitude!),
//                             zoom: 13.0,
//                             rotation: 0,
//                           ),
//                           children: [
//                             TileLayer(
//                               urlTemplate:
//                                   "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
//                               // "https://c.tile.openstreetmap.org/{z}/{x}/{y}.png",
//                               // subdomains: ['a', 'b', 'c'],
//                               // urlTemplate:
//                               //     'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token=pk.eyJ1IjoidmlwaW4tYWRpIiwiYSI6ImNtNW5rNnh2cDA1bWkyanFycmJ1OXhlcWEifQ.7V9rc6HJYbV5jEe6vld05Q',

//                               // additionalOptions: {
//                               //   'accessToken':
//                               //       'pk.eyJ1IjoidmlwaW4tYWRpIiwiYSI6ImNtNW5rNnh2cDA1bWkyanFycmJ1OXhlcWEifQ.7V9rc6HJYbV5jEe6vld05Q',
//                               //   'id':
//                               //       'mapbox/streets-v11', // Use the desired Mapbox style ID
//                               // }, //
//                             ),
//                             MarkerLayer(
//                               markers: [
//                                 Marker(
//                                   width: 80.0,
//                                   height: 80.0,
//                                   point: LatLng(
//                                       currentLatitude!, currentLongitude!),
//                                   builder: (ctx) => Icon(
//                                     Icons.location_on,
//                                     color: Colors.red,
//                                     size: 40,
//                                   ),
//                                 ),
//                                 ...amenities.map((amenity) {
//                                   final amenityLat = amenity['lat'];
//                                   final amenityLon = amenity['lon'];

//                                   return Marker(
//                                     width: 80.0,
//                                     height: 80.0,
//                                     point: LatLng(amenityLat, amenityLon),
//                                     builder: (ctx) => GestureDetector(
//                                       child: Container(
//                                         child: Icon(
//                                           Icons.place,
//                                           color: Colors.blueAccent,
//                                           size: 40,
//                                         ),
//                                       ),
//                                       onTap: () {
//                                         final LatLng startCoordinate = LatLng(
//                                             currentLatitude!,
//                                             currentLongitude!);
//                                         final LatLng endCoordinate = LatLng(
//                                             amenity['lat'], amenity['lon']);

//                                         // Navigate to MapScreen with both coordinates
//                                         Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder: (context) => PolyLine(
//                                               startPoint: startCoordinate,
//                                               endPoint: endCoordinate,
//                                             ),
//                                           ),
//                                         );
//                                       },
//                                     ),
//                                   );
//                                 }),
//                               ],
//                             ),
//                           ],
//                         ),
//                 );
//               },
//             ),
//           ),
//           SliverList(
//             delegate: SliverChildBuilderDelegate(
//               (BuildContext context, int index) {
//                 if (isLoadingAmenities) {
//                   return Center(child: CircularProgressIndicator());
//                 }

//                 if (amenities.isEmpty) {
//                   return Center(child: Text('No amenities found.'));
//                 }

//                 final amenity = amenities[index];

//                 return ListTile(
//                   title: Text(
//                     amenity['name'] ?? 'Unnamed Place',
//                     style: TextStyle(color: Color(0xffffffff)),
//                   ),
//                   subtitle: Text(
//                     amenity['address'] ?? 'Address not found',
//                     style: TextStyle(color: Color(0xffffffff)),
//                   ),
//                   leading: Icon(Icons.place, color: Colors.blue),
//                   onTap: () {
//                     // Define startCoordinate (current location) and endCoordinate (selected hospital)
//                     final LatLng startCoordinate =
//                         LatLng(currentLatitude!, currentLongitude!);
//                     final LatLng endCoordinate =
//                         LatLng(amenity['lat'], amenity['lon']);

//                     // Navigate to MapScreen with both coordinates
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => PolyLine(
//                           startPoint: startCoordinate,
//                           endPoint: endCoordinate,
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//               childCount: isLoadingAmenities
//                   ? 1 // Show a single loading widget
//                   : amenities.length,
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           _resetScrollPosition();
//           if (currentLatitude != null && currentLongitude != null) {
//             mapController.moveAndRotate(
//                 LatLng(currentLatitude!, currentLongitude!), 13.0, 0);
//           } else {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text("Current location is not available.")),
//             );
//           }
//         },
//         child: Icon(Icons.arrow_upward),
//       ),
//     );
//   }
// } //instead of showing lat and lng under the hospitals names i need to the address to be displayed

// //instead of showing lat and lng under the hospitals names i need to the address to be displayed

// ///////////////////////////////
// // import 'package:flutter/material.dart';
// // import 'package:flutter_map/flutter_map.dart';
// // import 'package:latlong2/latlong.dart';

// // // Define custom LatLngTween class to animate LatLng values
// // class LatLngTween extends Tween<LatLng> {
// //   LatLngTween({required LatLng begin, required LatLng end})
// //       : super(begin: begin, end: end);

// //   @override
// //   LatLng lerp(double t) {
// //     // Interpolating between the begin and end values of LatLng
// //     return LatLng(
// //       begin.latitude + (end.latitude - begin.latitude) * t,
// //       begin.longitude + (end.longitude - begin.longitude) * t,
// //     );
// //   }
// // }

// // void main() {
// //   runApp(MyApp());
// // }

// // class MyApp extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       home: MapLocationPage(),
// //     );
// //   }
// // }

// // class MapLocationPage extends StatefulWidget {
// //   @override
// //   _MapLocationPageState createState() => _MapLocationPageState();
// // }

// // class _MapLocationPageState extends State<MapLocationPage> with TickerProviderStateMixin {
// //   final TextEditingController _latController = TextEditingController();
// //   final TextEditingController _lngController = TextEditingController();
// //   MapController _mapController = MapController();

// //   // Current position and destination
// //   LatLng _currentPosition = LatLng(37.7749, -122.4194); // Default to San Francisco
// //   LatLng _destinationPosition = LatLng(37.7749, -122.4194); // Default position

// //   // Animation Controller
// //   late AnimationController _animationController;
// //   late Animation<LatLng> _positionAnimation;
// //   late Animation<double> _zoomAnimation;

// //   @override
// //   void initState() {
// //     super.initState();
// //     // Initialize the animation controller
// //     _animationController = AnimationController(
// //       duration: Duration(seconds: 2), // Animation duration
// //       vsync: this,
// //     );
// //   }

// //   // Function to update position smoothly with animation
// //   void _updatePosition() {
// //     // Parse input coordinates
// //     double lat = double.tryParse(_latController.text) ?? _currentPosition.latitude;
// //     double lng = double.tryParse(_lngController.text) ?? _currentPosition.longitude;
// //     setState(() {
// //       _destinationPosition = LatLng(lat, lng);
// //     });

// //     // Define the position animation and zoom animation
// //     _positionAnimation = LatLngTween(begin: _currentPosition, end: _destinationPosition).animate(
// //       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
// //     );

// //     _zoomAnimation = Tween<double>(begin: 14.0, end: 14.0).animate(
// //       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
// //     );

// //     // Start the animation
// //     _animationController.forward();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text('Flutter Map Example')),
// //       body: Column(
// //         children: [
// //           // Input fields for latitude and longitude
// //           Padding(
// //             padding: const EdgeInsets.all(8.0),
// //             child: Row(
// //               children: [
// //                 Expanded(
// //                   child: TextField(
// //                     controller: _latController,
// //                     keyboardType: TextInputType.number,
// //                     decoration: InputDecoration(labelText: 'Latitude'),
// //                   ),
// //                 ),
// //                 SizedBox(width: 8),
// //                 Expanded(
// //                   child: TextField(
// //                     controller: _lngController,
// //                     keyboardType: TextInputType.number,
// //                     decoration: InputDecoration(labelText: 'Longitude'),
// //                   ),
// //                 ),
// //                 IconButton(
// //                   icon: Icon(Icons.search),
// //                   onPressed: _updatePosition,
// //                 )
// //               ],
// //             ),
// //           ),

// //           // Flutter Map
// //           Expanded(
// //             child: AnimatedBuilder(
// //               animation: _animationController,
// //               builder: (context, child) {
// //                 // Update the map's position and zoom based on the animation values
// //                 _mapController.move(_positionAnimation.value, _zoomAnimation.value);
// //                 return FlutterMap(
// //                   mapController: _mapController,
// //                   options: MapOptions(
// //                     center: _currentPosition,
// //                     zoom: 14.0,
// //                     maxZoom: 18.0,
// //                     minZoom: 2.0,
// //                   ),
// //                   children: [
// //                     TileLayer(
// //                       urlTemplate:
// //                           "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
// //                       subdomains: ['a', 'b', 'c'],
// //                     ),
// //                     MarkerLayer(
// //                       markers: [
// //                         Marker(
// //                           width: 80.0,
// //                           height: 80.0,
// //                           point: _destinationPosition,
// //                           builder: (ctx) => Icon(
// //                             Icons.location_on,
// //                             color: Colors.red,
// //                             size: 40,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ],
// //                 );
// //               },
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   @override
// //   void dispose() {
// //     _animationController.dispose();
// //     super.dispose();
// //   }
// // }
