import 'dart:async';

import 'package:drivres_app/buisnis_logic/notifications_system/push_notifications_system.dart';
import 'package:drivres_app/presetation/buttou_manager/buttomn_%C3%B9anager.dart';
import 'package:drivres_app/presetation/widgets/progress_dialogue/progress_dialogue.dart';
import 'package:drivres_app/presetation/widgets/toast_widget/toast_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../apikeys/streambuilder.dart';
import '../../../../buisnis_logic/authntication_provider/authentication_logic.dart';
import '../../../../buisnis_logic/maps_provider/maps_provider.dart';
import '../../../app_manager/color_manager/colormanager.dart';
import '../../../app_manager/text_manager/textmanager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Completer<GoogleMapController> _googleMapController =
      Completer<GoogleMapController>();

  GoogleMapController? _newGoogleController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  Position? userCurrentPosition;

  Future<void> initializeLocationAndMap() async {
    // Check if location permission is allowed
    bool isEnabled =
        Provider.of<MapsProvider>(context, listen: false).isEnabeld;

    if (isEnabled) {
      // Obtain and set user's current position
      Position cPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      Provider.of<NotificationsSystem>(context, listen: false)
          .driverCurrentPosition = cPosition;

      Provider.of<MapsProvider>(context, listen: false).currentPosition =
          cPosition;
      userCurrentPosition = cPosition;
      LatLng latLngPosition = LatLng(cPosition.latitude, cPosition.longitude);

      CameraPosition cameraPosition =
          CameraPosition(target: latLngPosition, zoom: 14);

      if (_newGoogleController != null) {
        // Wait for the map to fully initialize before animating the camera
        _newGoogleController!.animateCamera(
          CameraUpdate.newCameraPosition(cameraPosition),
        );
      }

      print("Longitude: ${latLngPosition.longitude}");
      print("Latitude: ${latLngPosition.latitude}");
    } else {
      // Handle permission not granted case
    }
  }

  googleBlackTheme() {
    _newGoogleController!.setMapStyle('''
                    [
                      {
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#242f3e"
                          }
                        ]
                      },
                      {
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#746855"
                          }
                        ]
                      },
                      {
                        "elementType": "labels.text.stroke",
                        "stylers": [
                          {
                            "color": "#242f3e"
                          }
                        ]
                      },
                      {
                        "featureType": "administrative.locality",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "poi",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "poi.park",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#263c3f"
                          }
                        ]
                      },
                      {
                        "featureType": "poi.park",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#6b9a76"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#38414e"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "geometry.stroke",
                        "stylers": [
                          {
                            "color": "#212a37"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#9ca5b3"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#746855"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "geometry.stroke",
                        "stylers": [
                          {
                            "color": "#1f2835"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#f3d19c"
                          }
                        ]
                      },
                      {
                        "featureType": "transit",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#2f3948"
                          }
                        ]
                      },
                      {
                        "featureType": "transit.station",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#17263c"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#515c6d"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "labels.text.stroke",
                        "stylers": [
                          {
                            "color": "#17263c"
                          }
                        ]
                      }
                    ]
                ''');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializeLocationAndMap();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        body: Stack(children: [
      GoogleMap(
        initialCameraPosition: _kGooglePlex,
        mapType: MapType.normal,
        myLocationEnabled: true,
        onMapCreated: (controller) {
          _googleMapController.complete(controller);
          _newGoogleController = controller;

          googleBlackTheme();
        },
      ),
      Provider.of<AuthService>(context).driverStatus == "Offline"
          ? Container(
              height: height,
              color: black54,
            )
          : Container(),
      Positioned(
        left: width * 0.3,
        top: height * 0.2,
        child: Provider.of<AuthService>(context).driverStatus == "Offline"
            ? Defaultbutton(
                functon: () async {
                  await Provider.of<MapsProvider>(context, listen: false)
                      .driverIsOnlineNow(userCurrentPosition!);

                  updateDriverPosition();

                  Provider.of<AuthService>(context, listen: false)
                      .changeDriverStatus();

                  Provider.of<AuthService>(context, listen: false)
                      .retriveCurrentOlineDriver();

                  showtoast("you are online now");
                },
                text: "You are offline",
                height: height * 0.07,
                width: width * 0.4,
                color: gris)
            : Container(),
      ),
      Provider.of<AuthService>(context).driverStatus == "Online"
          ? Positioned(
              top: height * 0.04,
              left: width * 0.4,
              right: width * 0.4,
              child: GestureDetector(
                onTap: () {
                  Provider.of<MapsProvider>(context, listen: false)
                      .driverIsOfflineNow();
                  Provider.of<AuthService>(context, listen: false)
                      .changeDriverStatus();

                  // Navigator.of(context).pop();
                },
                child: Container(
                  height: height * 0.04,
                  width: width * 0.1,
                  decoration: BoxDecoration(
                      color: gris, borderRadius: BorderRadius.circular(18)),
                  child: const Icon(
                    Icons.phonelink_ring_outlined,
                    color: white,
                  ),
                ),
              ),
            )
          : Container()
    ]));
  }

  updateDriverPosition() {
    streamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      userCurrentPosition = position;
      Provider.of<MapsProvider>(context, listen: false).currentPosition =
          userCurrentPosition;
      if (Provider.of<AuthService>(context, listen: false).driverStatus ==
          "Online") {
        Geofire.setLocation(FirebaseAuth.instance.currentUser!.uid,
            userCurrentPosition!.latitude, userCurrentPosition!.longitude);
      }
    });

    LatLng latLng =
        LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);

    _newGoogleController!.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: latLng, zoom: 14)));
  }
}
