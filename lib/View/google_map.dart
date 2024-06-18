import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class GoogleMapPage extends StatefulWidget {
  @override
  _GoogleMapPageState createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  late GoogleMapController mapController;
  final LatLng initialCameraPosition = const LatLng(37.422, -122.084);
  late PermissionStatus _permissionStatus = PermissionStatus.denied; // Initialize with a default value

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
      body: _buildMap(), // Removed the appBar here
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
}
