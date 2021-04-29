import 'package:babysitter_booking_app/screens/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  static String routeName = "map_screen";
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController mapController;

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
                setState(() {
                  mapController = c;
                });
              },
              initialCameraPosition:
                  CameraPosition(target: LatLng(21.1456, 78.3394), zoom: 11),
              mapType: MapType.normal,
            ),
          ),
        ],
      ),
    );
  }
}
