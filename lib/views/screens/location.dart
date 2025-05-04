import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc; // Aliasing the 'location' package
import 'package:geocoding/geocoding.dart'; // 'geocoding' package

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapControllers;
  loc.LocationData? _currentLocations;
  final loc.Location _locationServices = loc.Location(); // Using the alias here
  String address = 'Fetching address...';

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    try {
      bool _serviceEnabled = await _locationServices.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await _locationServices.requestService();
        if (!_serviceEnabled) {
          return;
        }
      }

      loc.PermissionStatus _permissionGranted = await _locationServices.hasPermission();
      if (_permissionGranted == loc.PermissionStatus.denied) {
        _permissionGranted = await _locationServices.requestPermission();
        if (_permissionGranted != loc.PermissionStatus.granted) {
          return;
        }
      }

      // Get current location
      _currentLocations = await _locationServices.getLocation();

      if (_currentLocations != null) {
        _getAddressFromLatLng(
            _currentLocations!.latitude!,
            _currentLocations!.longitude!
        );
      }

      setState(() {});
    } catch (e) {
      print('Could not get location: $e');
    }
  }

  Future<void> _getAddressFromLatLng(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          address = '${place.name}, ${place.locality}, ${place.administrativeArea}';
        });
      }
    } catch (e) {
      print('Could not get address: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('')),
      body: _currentLocations == null
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                mapControllers = controller;
                mapControllers.animateCamera(
                  CameraUpdate.newLatLng(
                    LatLng(_currentLocations!.latitude!, _currentLocations!.longitude!),
                  ),
                );
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(_currentLocations!.latitude!, _currentLocations!.longitude!),
                zoom: 18.0,
              ),
              markers: {
                Marker(
                  markerId: MarkerId('current_location'),
                  position: LatLng(_currentLocations!.latitude!, _currentLocations!.longitude!),
                  infoWindow: InfoWindow(title: 'Your Location', snippet: address),
                ),
              },
              circles: {
                Circle(
                  circleId: CircleId('current_location'),
                  center: LatLng(_currentLocations!.latitude!, _currentLocations!.longitude!),
                  radius: 15,
                  fillColor: Colors.blue.withOpacity(0.3),
                  strokeColor: Colors.blue,
                  strokeWidth: 1,
                ),
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('📍 Address: $address', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}





//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
//
// class MapScreen extends StatefulWidget {
//   const MapScreen({super.key});
//
//   @override
//   State<MapScreen> createState() => _MapScreenState();
// }
//
// class _MapScreenState extends State<MapScreen> {
//
//   LatLng myLatLng = LatLng(19.9245158,102.1850679);
//   String address = 'Faculty of Engineering,';
//
//   Future<void> setMarker(LatLng value) async {
//     myLatLng = value;
//
//     List<Placemark> result = await placemarkFromCoordinates(value.latitude, value.longitude);
//
//     if (result.isNotEmpty) {
//       address = '${result[0].name}, ${result[0].locality}, ${result[0].administrativeArea}';
//     }
//
//     setState(() {});
//     Fluttertoast.showToast(msg: '📍 $address');
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//
//       ),
//       body: GoogleMap(
//       initialCameraPosition: CameraPosition(
//         target: myLatLng,
//         zoom: 17, // Adjust zoom level as needed
//       ),
//       markers: {
//         Marker(
//           infoWindow: InfoWindow(title: address),
//           position: myLatLng,
//           draggable: true,
//           markerId: MarkerId('1'),
//           onDragEnd: (value) {
//             print(value);
//             setMarker(value);
//           },
//         ),
//       },
//       circles: {
//         Circle(
//           circleId: CircleId('circle1'),
//           center: myLatLng,
//           radius: 100,
//           fillColor: Colors.blue.withOpacity(0.3),
//           strokeColor: Colors.blue,
//           strokeWidth: 1,
//         ),
//       },
//       onTap: (value) {
//         setMarker(value);
//       },
//     ),
//     );
//   }
// }
