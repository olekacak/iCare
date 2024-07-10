import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_maps_webservice/directions.dart' as directions_pkg show GoogleMapsDirections, TravelMode, Location;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class GoogleMapPage extends StatefulWidget {
  @override
  _GoogleMapPageState createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  GoogleMapController? mapController;
  final LatLng initialCameraPosition = const LatLng(2.328365, 102.292882);
  PermissionStatus _permissionStatus = PermissionStatus.denied;
  final TextEditingController _searchController = TextEditingController();
  LatLng? _destination;
  Set<Polyline> _polylines = {};
  final String apiKey = 'AIzaSyCfVFVYBC6wTOY7fMcoPwtLidl_Wf-KFSk';

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.location.request();
    setState(() {
      _permissionStatus = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Maps Demo'),
      ),
      body: Stack(
        children: [
          _buildMap(),
          Positioned(
            top: 16.0,
            left: 16.0,
            right: 16.0,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search destination',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => _searchDestination(_searchController.text),
                ),
              ),
              onSubmitted: _searchDestination,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    if (_permissionStatus == PermissionStatus.granted) {
      return GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: initialCameraPosition,
          zoom: 15.0,
        ),
        myLocationEnabled: true,
        polylines: _polylines,
      );
    } else {
      return Center(
        child: _permissionStatus == PermissionStatus.denied
            ? Text('Permission denied')
            : _permissionStatus == PermissionStatus.permanentlyDenied
            ? Text('Permission permanently denied. Please enable it in settings.')
            : CircularProgressIndicator(),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  Future<void> _searchDestination(String query) async {
    print('Searching for destination: $query');
    try {
      final places = await _getPlaces(query);
      if (places.isNotEmpty) {
        final selectedPlace = places.first;
        final destination = LatLng(selectedPlace.geometry!.location.lat, selectedPlace.geometry!.location.lng);
        setState(() {
          _destination = destination;
        });
        print('Destination found: $_destination');
        await _showRoutes();
      } else {
        _showErrorDialog('No results found for your search.');
      }
    } catch (e) {
      _showErrorDialog('An error occurred while searching for the destination.');
      print('Error in _searchDestination: $e');
    }
  }

  Future<void> _showRoutes() async {
    if (mapController == null || _destination == null) {
      return;
    }

    try {
      final currentCameraPosition = await mapController!.getLatLng(ScreenCoordinate(x: 0, y: 0));
      print('Current camera position: ${currentCameraPosition.latitude}, ${currentCameraPosition.longitude}');

      final directions = directions_pkg.GoogleMapsDirections(apiKey: apiKey);
      final response = await directions.directionsWithLocation(
        directions_pkg.Location(
          lat: currentCameraPosition.latitude,
          lng: currentCameraPosition.longitude,
        ),
        directions_pkg.Location(
          lat: _destination!.latitude,
          lng: _destination!.longitude,
        ),
        travelMode: directions_pkg.TravelMode.driving,
      );

      // Print the entire response for debugging
      print('Directions API response: ${response.toJson()}');

      if (response.status == 'OK' && response.routes.isNotEmpty) {
        final route = response.routes.first;

        if (route.overviewPolyline?.points != null) {
          final points = route.overviewPolyline!.points;
          final polylinePoints = PolylinePoints().decodePolyline(points);

          // Create a new set with the updated polyline
          Set<Polyline> newPolylines = {};
          newPolylines.add(
            Polyline(
              polylineId: PolylineId('route'),
              points: polylinePoints.map((point) => LatLng(point.latitude, point.longitude)).toList(),
              width: 5,
              color: Colors.blue,
            ),
          );

          setState(() {
            _polylines = newPolylines; // Update _polylines with the new set
          });
        } else {
          print('No polyline points found in the route.');
          _showErrorDialog('No polyline points found in the route.');
        }
      } else {
        print('Failed to fetch directions: ${response.errorMessage}');
        _showErrorDialog('Failed to fetch directions. Please try again.');
      }
    } catch (e) {
      _showErrorDialog('An error occurred while fetching directions.');
      print('Error in _showRoutes: $e');
    }
  }


  Future<List<PlacesSearchResult>> _getPlaces(String query) async {
    final places = GoogleMapsPlaces(apiKey: apiKey);
    final response = await places.searchByText(query);

    if (response.status == 'OK') {
      print('Places search response: ${response.results}');
      return response.results;
    } else {
      print('Failed to fetch places: ${response.errorMessage}');
      throw Exception('Failed to fetch places');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
