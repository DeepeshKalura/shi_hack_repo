import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../utils/secrets.dart';

class TrialScreen extends StatefulWidget {
  const TrialScreen({super.key});

  @override
  State<TrialScreen> createState() => _TrialScreenState();
}

class _TrialScreenState extends State<TrialScreen> {
  final Completer<GoogleMapController> _controller = Completer();

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;
  void setCustomMarkerIcon() {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, "assets/Pin_source.png")
        .then(
      (icon) {
        sourceIcon = icon;
      },
    );
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, "assets/Pin_destination.png")
        .then(
      (icon) {
        destinationIcon = icon;
      },
    );
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, "assets/Badge.png")
        .then(
      (icon) {
        currentLocationIcon = icon;
      },
    );
  }

  static const LatLng source = LatLng(30.058208, 78.227443);
  static const LatLng destination = LatLng(30.288914, 77.998807);
  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;
  void getCurrentLocation() async {
    Location location = Location();
    location.getLocation().then(
      (location) {
        currentLocation = location;
      },
    );
    GoogleMapController googleMapController = await _controller.future;
    location.onLocationChanged.listen(
      (newLoc) {
        currentLocation = newLoc;
        googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              zoom: 13.5,
              target: LatLng(
                newLoc.latitude!,
                newLoc.longitude!,
              ),
            ),
          ),
        );
        developer.log(
          "currentLocation: $currentLocation"
          "\n Get the current location",
          name: "TrialScreen",
        );
        setState(() {});
      },
    );
  }

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey, // ? I make a screts.dart inside utils folder and put my googleApiKey there
      // PointLatLng(currentLocation!.latitude!, currentLocation!.longitude!),
      // PointLatLng(destinationLatLong!.latitude, destinationLatLong!.longitude),
      PointLatLng(source.latitude, source.longitude),
      PointLatLng(destination.latitude, destination.longitude),
    );
    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        );
      }
      developer.log(
        "polylineCoordinates: $polylineCoordinates"
        "\n Get the polyline coordinates",
        name: "TrialScreen",
      );
      setState(() {});
    } else {
      developer.log(
        "result.points is empty",
        name: "TrialScreen",
      );
    }
  }

  @override
  void initState() {
    getCurrentLocation();
    getPolyPoints();
    setCustomMarkerIcon();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF7B61FF),
        automaticallyImplyLeading: false,
        // bottom: PreferredSize(
        //   preferredSize: const Size.fromHeight(50),
        //   child: Column(
        //     children: [
        //       Row(
        //         children: [
        //           const Padding(
        //             padding: EdgeInsets.only(left: 20, right: 20),
        //             child: Text(
        //               'Map View',
        //               style: TextStyle(
        //                 color: Colors.white,
        //                 fontSize: 20,
        //               ),
        //             ),
        //           ),
        //           Container(
        //             width: MediaQuery.of(context).size.width * 0.7,
        //             padding: const EdgeInsets.only(left: 20, right: 20),
        //             child: const TextField(
        //               decoration: InputDecoration(
        //                 hintText: "Search",
        //                 // iconColor: Colors.white,
        //                 hintStyle: TextStyle(
        //                   color: Colors.white,
        //                 ),
        //                 prefixIcon: Icon(Icons.search, color: Colors.white),

        //                 border: OutlineInputBorder(
        //                   borderRadius: BorderRadius.all(
        //                     Radius.circular(50),
        //                   ),
        //                 ),
        //               ),
        //             ),
        //           ),
        //         ],
        //       ),
        //     ],
        //   ),
        // ),

        title: const Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage("assets/Avatar.png"),
            ),
            SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hi, User",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
                Text(
                  "Deepesh Kalura",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ],
        ),
        toolbarHeight: 80,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(10),
          ),
        ),
      ),
      body: currentLocation == null
          ? const Center(
              child: Text("Loading......"),
            )
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  currentLocation!.latitude!,
                  currentLocation!.longitude!,
                ),
                zoom: 13.5,
              ),
              markers: {
                Marker(
                  icon: currentLocationIcon,
                  markerId: const MarkerId("currentLocation"),
                  position: LatLng(
                    currentLocation!.latitude!,
                    currentLocation!.longitude!,
                  ),
                ),
                Marker(
                  markerId: const MarkerId("source"),
                  position: source,
                  icon: sourceIcon,
                ),
                Marker(
                  markerId: const MarkerId("destination"),
                  position: destination,
                  icon: destinationIcon,
                ),
              },
              onMapCreated: (mapController) {
                _controller.complete(mapController);
              },
              polylines: {
                Polyline(
                  polylineId: const PolylineId("route"),
                  points: polylineCoordinates,
                  color: const Color(0xFF7B61FF),
                  width: 6,
                ),
              },
            ),
    );
  }
}
