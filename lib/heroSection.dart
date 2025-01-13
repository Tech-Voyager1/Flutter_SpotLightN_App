import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:spotlight/appColor.dart';
import 'package:spotlight/home.dart';
import 'polyline.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Global variables for current location
double? currentLatitude;
double? currentLongitude;
int index_ = 0; // Global index to store the selected index from HeroSection

// Class for fetching and managing current location
class LocationService {
  Position? _currentPosition;

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasAskedPermission = prefs.getBool('hasAskedPermission') ?? false;

    if (!hasAskedPermission) {
      // Check the current permission status
      LocationPermission permission = await Geolocator.checkPermission();

      // permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        // Save that permission was asked to avoid asking again
        await prefs.setBool('hasAskedPermission', true);
        if (permission == LocationPermission.denied) {
          return Future.error('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied');
        return Future.error('Location permissions are permanently denied');
      }
    }
    _currentPosition = await Geolocator.getCurrentPosition();
    return _currentPosition!;
  }

  Future<LatLng> getCurrentLatLng() async {
    if (_currentPosition == null) {
      _currentPosition = await getCurrentLocation();
    }
    return LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
  }
}

// HeroSection Widget to display grid items
class HeroSection extends StatefulWidget {
  const HeroSection({Key? key}) : super(key: key);

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 0.0, left: 8, right: 8),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 12.0,
          mainAxisExtent: 210, //height of container
        ),
        itemCount: 6,
        itemBuilder: (_, index) {
          String imagePath;
          String label;

          switch (index) {
            case 0:
              imagePath = "asset/icons/hospital2.png";
              label = "Hospital";
              break;
            case 1:
              imagePath = "asset/icons/police.png";
              label = "Police Station";
              break;
            case 2:
              imagePath = "asset/icons/bus.png";
              label = "Bus Stand";
              break;
            case 3:
              imagePath = "asset/icons/train.png";
              label = "Railway Station";
              break;
            case 4:
              imagePath = "asset/icons/cafe.png";
              label = "Cafe";
              break;
            case 5:
              imagePath = "asset/icons/atm.png";
              label = "ATM";
              break;
            default:
              imagePath = "asset/icons/cafe.png";
              label = "ATM";
          }

          return GestureDetector(
            onTap: () {
              index_ = index + 1;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MapScreen(), //MapScreen
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.all(0),
              child: Container(
                margin: EdgeInsets.only(top: 20, left: 10, right: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.liteblue, //Color(0xffdcd0bb),
                    boxShadow: [
                      BoxShadow(color: Color(0xff000000), blurRadius: 3)
                    ]),
                child: Column(children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8.0),
                      topRight: Radius.circular(8.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          right: 8.0, left: 8, top: 25, bottom: 15),
                      child: Image.asset(
                        imagePath,
                        filterQuality: FilterQuality.high,
                        height: 70,
                        width: 70,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: Color(0xff000000),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                ]),
              ),
            ),
          );
        },
      ),
    );
  }
}

// MapScreen to display map and amenities
class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<dynamic> amenities = [];
  bool isLoadingMap = true; // Loading state for the map
  bool isLoadingAmenities = false; // Loading state for the amenities list

  double? radius = 5000;
  late MapController mapController;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    print("inside getcurrent location");
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      print(4);
      Position position = await Geolocator.getCurrentPosition();
      print(6);
      if (mounted) {}
      setState(() {
        currentLatitude = position.latitude;
        currentLongitude = position.longitude;
        isLoadingMap = false;
      });
      fetchAmenities();
    }
  }

  Future<void> fetchAmenities() async {
    if (currentLatitude == null || currentLongitude == null) return;
    String? amenity;
    if (index_ == 3) radius = 10000;
    if (index_ <= 5) {
      amenity = _chooseAmenity();
    }
    if (index_ == 7) {
      final String url =
          "https://overpass-api.de/api/interpreter?data=[out:json];node[amenity=restaurant](around:$radius,$currentLatitude,$currentLongitude);out;";
    }
    final String url =
        "https://overpass-api.de/api/interpreter?data=[out:json];node$amenity(around:$radius,$currentLatitude,$currentLongitude);out;";
    if (index_ == 3) radius = 5000;
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<Map<String, dynamic>> fetchedAmenities = [];
        print("hiii");
        int value = 1;

        for (var amenity in data['elements']) {
          double amenityLat = amenity['lat'];
          double amenityLon = amenity['lon'];
          String address = await getAddress(amenityLat, amenityLon);
          String amenityName = amenity['tags']?['name'] ?? '';
          if (amenityName.isEmpty) {
            continue; // Skip unnamed places
          }
          if (amenities.any((a) => a['id'] == amenity['id'])) {
            continue; // Skip adding this amenity if it already exists
          }
          if (address == "Address not found") {
            print("add not found");
            continue;
          }

          fetchedAmenities.add({
            'name': amenity['tags']?['name'] ?? 'Unnamed Place',
            'lat': amenityLat,
            'lon': amenityLon,
            'address': address,
          });

          // Update state immediately after fetching each amenity
          if (mounted) {
            setState(() {
              amenities.add(fetchedAmenities.last);
            });
          }

          print(amenities);

          value++;
          if (value >= 11) break; // Limit to 10 amenities
        }
        if (index_ == 5) {
          index_ = 7;
          fetchAmenities();
          index_ = 5;
        }
        if (radius! <= 8000) {
          if (fetchedAmenities.isEmpty) {
            print("object");
            if (mounted) {
              setState(() {
                radius = (radius! + 2000);
              });
            }

            await fetchAmenities();
            radius = 5000;
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingAmenities = false;
        });
      }
      ;
    }
  }

  String _chooseAmenity() {
    print('inside choose aminiety');
    switch (index_) {
      case 1:
        return "[amenity=hospital]";
      case 2:
        return "[amenity=police]";
      case 3:
        return "[amenity=bus_station]";
      case 4:
        return "[railway=station]";
      case 5:
        return "[amenity=cafe]";
      case 6:
        return "[amenity=atm]";
      default:
        return "[amenity=hospital]";
    }
  }

  Future<String> getAddress(double latitude, double longitude) async {
    final String url =
        'https://api.openrouteservice.org/geocode/reverse?api_key=5b3ce3597851110001cf62488e34416e86784f638c0e8b3b3b590686&point.lon=$longitude&point.lat=$latitude&layers=address';
    print(url);
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['features'] != null && data['features'].isNotEmpty) {
          final address =
              data['features'][0]['properties']['label'] ?? 'Address not found';
          return address;
        } else {
          return 'Address not found';
        }
      } else {
        return 'Failed to get address';
      }
    } catch (e) {
      return 'Error fetching address';
    }
  }

  final ScrollController _scrollController = ScrollController();
  void _resetScrollPosition() {
    _scrollController.animateTo(
      0.0,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 170, 80, 185),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: screenHeight / 2,
            collapsedHeight: screenHeight / 4,
            pinned: true,
            floating: true,
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                double mapHeight = screenHeight / 1.7;

                return SizedBox(
                  height: mapHeight,
                  child: isLoadingMap
                      ? Center(child: CircularProgressIndicator())
                      : FlutterMap(
                          mapController: mapController,
                          options: MapOptions(
                            center: LatLng(currentLatitude!, currentLongitude!),
                            zoom: 13.0,
                            maxZoom: 18,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  width: 80.0,
                                  height: 80.0,
                                  point: LatLng(
                                      currentLatitude!, currentLongitude!),
                                  builder: (ctx) => Icon(
                                    Icons.location_on,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                                ),
                                ...amenities.map((amenity) {
                                  final amenityLat = amenity['lat'];
                                  final amenityLon = amenity['lon'];

                                  return Marker(
                                    width: 80.0,
                                    height: 80.0,
                                    point: LatLng(amenityLat, amenityLon),
                                    builder: (ctx) => GestureDetector(
                                      child: Container(
                                        child: Icon(
                                          Icons.place,
                                          color: Colors.blueAccent,
                                          size: 40,
                                        ),
                                      ),
                                      onTap: () {
                                        final LatLng startCoordinate = LatLng(
                                            currentLatitude!,
                                            currentLongitude!);
                                        final LatLng endCoordinate = LatLng(
                                            amenity['lat'], amenity['lon']);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PolyLine(
                                              startPoint: startCoordinate,
                                              endPoint: endCoordinate,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ],
                        ),
                );
              },
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                if (isLoadingAmenities) {
                  return Center(child: CircularProgressIndicator());
                }

                if (amenities.isEmpty) {
                  return Center(child: Text('No amenities found.'));
                }

                final amenity = amenities[index];

                return ListTile(
                  title: Text(
                    amenity['name'] ?? 'Unnamed Place',
                    style: TextStyle(color: Color(0xffffffff)),
                  ),
                  subtitle: Text(
                    amenity['address'] ?? 'Address not found',
                    style: TextStyle(color: Color(0xffffffff)),
                  ),
                  leading: Icon(Icons.place, color: Colors.blue),
                  onTap: () {
                    final LatLng startCoordinate =
                        LatLng(currentLatitude!, currentLongitude!);
                    final LatLng endCoordinate =
                        LatLng(amenity['lat'], amenity['lon']);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PolyLine(
                          startPoint: startCoordinate,
                          endPoint: endCoordinate,
                        ),
                      ),
                    );
                  },
                );
              },
              childCount: amenities.length,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print(amenities.length);
          if (amenities.length != 0) {
            // _resetScrollPosition();
          }
          if (currentLatitude != null && currentLongitude != null) {
            mapController.moveAndRotate(
                LatLng(currentLatitude!, currentLongitude!), 13.0, 0);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Current location is not available.")),
            );
          }
        },
        child: Icon(Icons.arrow_upward),
      ),
    );
  }
}
