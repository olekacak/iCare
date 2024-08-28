import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_maps_webservice/directions.dart' as directions_pkg;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:url_launcher/url_launcher.dart';

class GoogleMapPage extends StatefulWidget {
  final LatLng? destination; // Add this line

  GoogleMapPage({this.destination}); // Modify the constructor

  @override
  _GoogleMapPageState createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  GoogleMapController? mapController;
  LatLng? _currentLocation;
  LatLng initialCameraPosition = const LatLng(2.328365, 102.292882); // Default initial position
  PermissionStatus _permissionStatus = PermissionStatus.denied;
  final TextEditingController _searchController = TextEditingController();
  LatLng? _destination;
  List<directions_pkg.Route> _routes = [];
  Set<Polyline> _polylines = {};
  final String apiKey = 'AIzaSyCfVFVYBC6wTOY7fMcoPwtLidl_Wf-KFSk'; // Replace with your API key

  bool _showNavigationButton = false;
  String _routeDuration = '';
  String _routeDistance = '';

  @override
  void initState() {
    super.initState();
    _checkPermission();
    _getCurrentLocation();

    // Use initial destination if provided
    if (widget.destination != null) {
      setState(() {
        _destination = widget.destination;
        _showNavigationButton = true; // Show navigation button if destination is set
      });
      _showRoutes(); // Calculate and display routes for the initial destination
    }
  }

  Future<void> _checkPermission() async {
    final status = await Permission.location.request();
    setState(() {
      _permissionStatus = status;
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your App Title'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.location_searching), // Icon for returning to current location
            onPressed: () {
              if (_currentLocation != null && mapController != null) {
                mapController!.animateCamera(CameraUpdate.newLatLngZoom(_currentLocation!, 15.0));
              }
            },
          ),
          if (_showNavigationButton) // Conditionally add the button
            IconButton(
              icon: Icon(Icons.navigation),
              onPressed: () {
                // Navigate based on _destination
                // Example: Navigator.pushNamed(context, '/destination_page');
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          _buildMap(),
          Positioned(
            top: 1.0,
            left: 18.0,
            right: 65.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
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
                      ),
                    ],
                  ),
                ),
                if (_permissionStatus == PermissionStatus.denied ||
                    _permissionStatus == PermissionStatus.permanentlyDenied)
                  Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      _permissionStatus == PermissionStatus.denied
                          ? 'Permission denied'
                          : 'Permission permanently denied. Please enable it in settings.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    if (_permissionStatus == PermissionStatus.granted && _currentLocation != null) {
      return GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _currentLocation!,
          zoom: 15.0,
        ),
        myLocationEnabled: true,
        polylines: _polylines,
        onTap: (LatLng latLng) {
          setState(() {
            _destination = latLng;

            _showNavigationButton = true; // Show navigation button when destination is set
            _polylines.clear(); // Clear existing polylines
          });
          _showRoutes(); // Calculate and display routes for the tapped location
        },
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
      final predictions = await _getPlaces(query);
      if (predictions.isNotEmpty) {
        _showPlacesList(predictions);
      } else {
        _showErrorDialog('No results found for your search.');
      }
    } catch (e) {
      _showErrorDialog('An error occurred while searching for the destination.');
      print('Error in _searchDestination: $e');
    }
  }

  void _showPlacesList(List<Prediction> predictions) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView.builder(
          itemCount: predictions.length,
          itemBuilder: (context, index) {
            final prediction = predictions[index];
            return ListTile(
              title: Text(prediction.description ?? 'Unnamed place'),
              onTap: () {
                Navigator.pop(context); // Close the search modal sheet
                _selectPlace(prediction);
              },
            );
          },
        );
      },
    );
  }

  void _selectPlace(Prediction prediction) async {
    try {
      final details = await _getPlaceDetails(prediction.placeId!);
      if (details.geometry != null && details.geometry!.location != null) {
        final destination = LatLng(
          details.geometry!.location!.lat,
          details.geometry!.location!.lng,
        );
        print('Selected destination: $destination'); // Add debug output
        setState(() {
          _destination = destination;
          _showNavigationButton = true; // Show navigation button when destination is set
        });
        _showRoutes(); // Calculate and display routes for the selected location
      } else {
        _showErrorDialog('Place details are incomplete.');
      }
    } catch (e) {
      _showErrorDialog('Error fetching place details: $e');
    }
  }

  void _showRoutes() async {
    if (mapController == null || _destination == null || _currentLocation == null) {
      return;
    }

    try {
      final directions = directions_pkg.GoogleMapsDirections(apiKey: apiKey);
      final response = await directions.directionsWithLocation(
        directions_pkg.Location(
          lat: _currentLocation!.latitude,
          lng: _currentLocation!.longitude,
        ),
        directions_pkg.Location(
          lat: _destination!.latitude,
          lng: _destination!.longitude,
        ),
        travelMode: directions_pkg.TravelMode.driving,
        alternatives: true, // Request alternative routes
      );

      if (response.status == 'OK' && response.routes.isNotEmpty) {
        setState(() {
          _routes = response.routes;
          _polylines.clear(); // Clear existing polylines
          _showRouteSelectionPanel();
          _showNavigationButton = true; // Show navigation button
        });
      } else {
        print('Failed to fetch directions: ${response.errorMessage}');
        _showErrorDialog('Failed to fetch directions. Please try again.');
      }
    } catch (e) {
      _showErrorDialog('An error occurred while fetching directions.');
      print('Error in _showRoutes: $e');
    }
  }


  void _showRouteSelectionPanel() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView.builder(
          itemCount: _routes.length,
          itemBuilder: (context, index) {
            final route = _routes[index];
            final leg = route.legs.first;
            final distance = leg.distance?.text ?? '';
            final duration = leg.duration?.text ?? '';

            return ListTile(
              title: Text('Route ${index + 1}'),
              subtitle: Text('Distance: $distance, Duration: $duration'),
              onTap: () {
                Navigator.pop(context); // Close the route selection panel
                _displayRoute(route);
              },
            );
          },
        );
      },
    );
  }

  void _displayRoute(directions_pkg.Route route) {
    setState(() {
      _polylines.clear(); // Clear existing polylines

      if (route.overviewPolyline?.points != null) {
        final points = route.overviewPolyline!.points;
        final polylinePoints = PolylinePoints().decodePolyline(points);

        _polylines.add(Polyline(
          polylineId: PolylineId('${route.hashCode}'), // Unique ID for each route
          points: polylinePoints.map((point) => LatLng(point.latitude, point.longitude)).toList(),
          width: 5,
          color: Colors.blue,
        ));

        final leg = route.legs.first;
        _routeDuration = leg.duration?.text ?? '';
        _routeDistance = leg.distance?.text ?? '';
        _showNavigationButton = true; // Show navigation button
        _showNavigationBottomSheet(_routeDuration, _routeDistance);
      } else {
        _showErrorDialog('No valid route found.');
      }
    });
  }

  Future<PlaceDetails> _getPlaceDetails(String placeId) async {
    final places = GoogleMapsPlaces(apiKey: apiKey);
    final response = await places.getDetailsByPlaceId(placeId);

    if (response.status == 'OK') {
      return response.result!;
    } else {
      throw Exception('Failed to fetch place details');
    }
  }

  Future<List<Prediction>> _getPlaces(String query) async {
    final places = GoogleMapsPlaces(apiKey: apiKey);
    final response = await places.autocomplete(query, types: ['geocode']);

    if (response.status == 'OK') {
      print('Places autocomplete response: ${response.predictions}');
      return response.predictions;
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

  void _showNavigationBottomSheet(String durationText, String distanceText) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Start Navigation'),
              onTap: () {
                Navigator.pop(context); // Close the navigation modal sheet
                _startNavigation();
              },
            ),
            ListTile(
              title: Text('Cancel'),
              onTap: () {
                Navigator.pop(context); // Close the navigation modal sheet
                setState(() {
                  _destination = null;
                  _showNavigationButton = false;
                  _polylines.clear();
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Route duration: $durationText'),
                  Text('Route distance: $distanceText'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _startNavigation() async {
    if (_destination == null) {
      print('Selected destination: $_destination');
      _showErrorDialog('Destination is not set.');
      return;
    }

    final googleUrl = 'https://www.google.com/maps/dir/?api=1&destination=${_destination!.latitude},${_destination!.longitude}';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      _showErrorDialog('Could not launch Google Maps.');
    }
  }
}
