import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapScreens extends ConsumerWidget {
  const GoogleMapScreens({super.key});
static const  LatLng _pGooglePlex = LatLng(7.9702527,102.6233583);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: GoogleMap(initialCameraPosition: CameraPosition(target: _pGooglePlex,zoom: 13),),
    );
  }
}
