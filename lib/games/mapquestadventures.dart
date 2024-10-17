import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

// Enum to represent different map types
enum MapType { normal, satellite, terrain, outdoor }

class MapQuestAdventures extends StatefulWidget {
  const MapQuestAdventures({super.key});

  @override
  State<MapQuestAdventures> createState() => _MapQuestAdventuresState();
}

class _MapQuestAdventuresState extends State<MapQuestAdventures> {
  List<LatLng> travelPath = [];
  final MapController _mapController = MapController();
  LatLng? currentPosition; // Store the current position for marker
  bool followUser = true;  // Flag to toggle follow mode
  StreamSubscription<Position>? _positionStream;
  // Enum to represent different map types
  MapType _currentMapType = MapType.normal;
  List<Map<String, dynamic>> pois = [];
  double currentZoom = 13.0;  // Track the current zoom level
  bool loadingPOIs = false;  // Track if POIs are being loaded

  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  // Function to start location tracking
  Future<void> _startTracking() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Request permission to access location
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    // Start listening to the location stream
    _positionStream = Geolocator.getPositionStream().listen((Position position) {
      if (mounted) {  // Check if the widget is still mounted
        setState(() {
          LatLng newPosition = LatLng(position.latitude, position.longitude);
          travelPath.add(newPosition);
          currentPosition = newPosition;
          if (followUser) {
            _mapController.move(newPosition, _mapController.camera.zoom);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    // Cancel the position stream when the widget is disposed
    _positionStream?.cancel();
    super.dispose();
  }

  // Function to switch map views based on selected map type
  String _getTileLayerUrl(MapType mapType) {
    switch (mapType) {
      case MapType.satellite:
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
      case MapType.terrain:
        return 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png'; // OpenTopoMap for Terrain
      case MapType.outdoor:
        return 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png'; // CartoDB Positron for Outdoor
      case MapType.normal:
      default:
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    }
  }

  // Calculate the map bounds (north, south, east, and west) based on current position and zoom
  LatLngBounds getMapBounds(LatLng center, double zoom) {
    const double worldWidth = 256.0; // World width in pixels at zoom level 0
    const double earthCircumference = 40075016.686; // Earth's circumference in meters

    double pixelSize = earthCircumference / (worldWidth * (1 << zoom.toInt())); // Pixel size in meters
    double halfHeightInMeters = (MediaQuery.of(context).size.height / 2) * pixelSize;
    double halfWidthInMeters = (MediaQuery.of(context).size.width / 2) * pixelSize;

    LatLng northEast = _offsetPosition(center, halfWidthInMeters, halfHeightInMeters);
    LatLng southWest = _offsetPosition(center, -halfWidthInMeters, -halfHeightInMeters);

    return LatLngBounds(southWest, northEast);
  }

  // Calculate the offset position based on distance in meters (dx, dy)
  LatLng _offsetPosition(LatLng position, double dx, double dy) {
    double latOffset = dy / 111320; // Latitude offset per meter
    double lngOffset = dx / (111320 * (1 / math.cos(position.latitude * math.pi / 180))); // Longitude offset per meter

    return LatLng(position.latitude + latOffset, position.longitude + lngOffset);
  }

  // Function to fetch POIs from OpenStreetMap when zoomed in
  Future<void> fetchPOIs(double zoomLevel, LatLngBounds bounds) async {
    if (loadingPOIs || zoomLevel < 14) return;  // Only fetch POIs if zoom is >= 14 and not already loading
    setState(() {
      loadingPOIs = true;  // Start loading POIs
    });

    final String overpassUrl = 'https://overpass-api.de/api/interpreter?data=[out:json];node[amenity](${bounds.south},${bounds.west},${bounds.north},${bounds.east});out;';
    
    try {
      final response = await http.get(Uri.parse(overpassUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<Map<String, dynamic>> newPOIs = [];

        for (var element in data['elements']) {
          if (element.containsKey('lat') && element.containsKey('lon')) {
            newPOIs.add({
              'lat': element['lat'],
              'lon': element['lon'],
              'name': element['tags']['name'] ?? 'Unnamed Place',
              'type': element['tags']['amenity'] ?? 'Unknown',
            });
          }
        }

        setState(() {
          pois = newPOIs;
          loadingPOIs = false;  // Done loading POIs
        });
      } else {
        log('Failed to load POIs');
        setState(() {
          loadingPOIs = false;
        });
      }
    } catch (e) {
      log('Error fetching POIs: $e');
      setState(() {
        loadingPOIs = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Map'),
        actions: [
          // Buttons to switch between map types
          TextButton(
            onPressed: () {
              setState(() {
                _currentMapType = MapType.satellite;
              });
            },
            child: Text(
              'Satellite',
              style: TextStyle(
                color: _currentMapType == MapType.satellite ? Colors.green : Colors.grey,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _currentMapType = MapType.terrain;
              });
            },
            child: Text(
              'Terrain',
              style: TextStyle(
                color: _currentMapType == MapType.terrain ? Colors.green : Colors.grey,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _currentMapType = MapType.normal;
              });
            },
            child: Text(
              'Normal',
              style: TextStyle(
                color: _currentMapType == MapType.normal ? Colors.green : Colors.grey,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _currentMapType = MapType.outdoor;
              });
            },
            child: Text(
              'Outdoor',
              style: TextStyle(
                color: _currentMapType == MapType.outdoor ? Colors.green : Colors.grey,
              ),
            ),
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: travelPath.isNotEmpty ? travelPath.last : const LatLng(51.5, -0.09),
          initialZoom: currentZoom,
          onPositionChanged: (position, hasGesture) {
            if (hasGesture) {
              setState(() {
                currentZoom = position.zoom;
              });

              if (currentZoom >= 16.0) {
                LatLngBounds bounds = getMapBounds(position.center, currentZoom);
                fetchPOIs(currentZoom, bounds);  // Fetch POIs only if zoom level >= 14
              } else {
                // Clear POIs when zoomed out below 14
                setState(() {
                  pois.clear();
                });
              }
            }
          }
        ),
        children: [
          TileLayer(
            urlTemplate: _getTileLayerUrl(_currentMapType),
          ),
          PolylineLayer(
            polylines: [
              Polyline(points: travelPath, strokeWidth: 4.0, color: Colors.blue),
            ],
          ),
          // Add markers for POIs
          MarkerLayer(
            markers: pois.map((poi) {
              return Marker(
                point: LatLng(poi['lat'], poi['lon']),
                child: GestureDetector(
                  onTap: () {
                    // Show a dialog with POI details on tap
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(poi['name']),
                        content: Text('Type: ${poi['type']}'),
                      ),
                    );
                  },
                  child: const Icon(Icons.location_on, color: Colors.red, size: 30),
                ),
              );
            }).toList(),
          ),
          if (currentPosition != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: currentPosition!,
                  child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                ),
              ],
            ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  followUser = !followUser;
                  if (followUser && currentPosition != null) {
                    _mapController.move(currentPosition!, _mapController.camera.zoom);
                  }
                });
              },
              backgroundColor: followUser ? Colors.blue : Colors.grey,
              child: Icon(followUser ? Icons.gps_fixed : Icons.gps_off, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}