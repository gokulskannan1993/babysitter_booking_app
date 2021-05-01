import 'dart:async';

import 'package:babysitter_booking_app/screens/constants.dart';
import 'package:babysitter_booking_app/screens/widgets/custom_large_textfield.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class Target extends ChangeNotifier {
  LatLng _center = LatLng(21.1456, 78.3394);

  void changeCenter(LatLng l) {
    _center = l;
    notifyListeners();
  }
}

class MapScreen extends StatefulWidget {
  static String routeName = "map_screen";
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController mapController;
  Completer<GoogleMapController> _controller = Completer();

  BitmapDescriptor sourceIcon, desitinationIcon;
  Set<Marker> _markers = Set<Marker>();
  LatLng currentLocation;
  LatLng destinationLocation;

  @override
  void initState() {
    super.initState();
  }

  setInitialLocation() {}

  setDestLocation() {}

  Widget button(Function function, IconData icon) {
    return FloatingActionButton(
      onPressed: function,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      backgroundColor: kSecondaryColor,
      child: Icon(
        icon,
        size: 36,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 15),
            child: GoogleMap(
              onMapCreated: (GoogleMapController c) {
                mapController = c;
              },
              initialCameraPosition: CameraPosition(
                  target: LatLng(324.3423434, 434.4141), zoom: 11),
              mapType: MapType.normal,
            ),
          ),
        ],
      ),
    );
  }
}
