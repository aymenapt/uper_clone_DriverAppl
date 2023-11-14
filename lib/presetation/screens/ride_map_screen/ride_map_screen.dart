import 'dart:async';

import 'package:drivres_app/buisnis_logic/maps_provider/maps_provider.dart';
import 'package:drivres_app/buisnis_logic/notifications_system/push_notifications_system.dart';
import 'package:drivres_app/presetation/app_manager/color_manager/colormanager.dart';
import 'package:drivres_app/presetation/buttou_manager/buttomn_%C3%B9anager.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../app_manager/text_manager/textmanager.dart';

class RideMapScreen extends StatefulWidget {
  const RideMapScreen({super.key});

  @override
  State<RideMapScreen> createState() => _RideMapScreenState();
}

class _RideMapScreenState extends State<RideMapScreen> {
  final Completer<GoogleMapController> _googleMapController =
      Completer<GoogleMapController>();

  GoogleMapController? newGoogleMapController;
  var geoLocator = Geolocator();
  Position? driverCurrentPosition;

  StreamSubscription? streamSubscription;
  BitmapDescriptor? activeDriverIcon;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  saveDriverToRideRequst() {
    Provider.of<NotificationsSystem>(context, listen: false)
        .saveDriverInfo(context);
  }

  void intialGoogleMap() async {
    driverCurrentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    LatLng latLngPosition = LatLng(
        driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 14);

    if (newGoogleMapController != null) {
      // Wait for the map to fully initialize before animating the camera
      newGoogleMapController!.animateCamera(
        CameraUpdate.newCameraPosition(cameraPosition),
      );
    }

    await Provider.of<MapsProvider>(context, listen: false)
        .drawpolilines(context);
  }

  void googleBlackTheme() {
    newGoogleMapController!.setMapStyle('''
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

  bool status = false;

  @override
  void initState() {
    // TODO: implement initState

    saveDriverToRideRequst();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: maincolor,
        child: const Icon(
          Icons.arrow_drop_up_rounded,
          color: white,
        ),
        onPressed: () {
          showModalBottomSheet(
              context: context,
              builder: (ctx) {
                return Container(
                  height: height * 0.45,
                  decoration: const BoxDecoration(
                      color: white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(18),
                          topRight: Radius.circular(18))),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: MyDefaultTextStyle(
                              text: "Ride Information",
                              height: height * 0.03,
                              bold: true,
                              color: black),
                        ),
                        SizedBox(
                          height: height * 0.03,
                        ),
                        Row(
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: width * 0.02),
                              child: Icon(
                                Icons.person,
                                size: height * 0.04,
                                color: maincolor,
                              ),
                            ),
                            SizedBox(
                              width: width * 0.04,
                            ),
                            MyDefaultTextStyle(
                                text: Provider.of<NotificationsSystem>(context,
                                        listen: false)
                                    .rideRequest
                                    .userName
                                    .toString(),
                                height: height * 0.018,
                                color: black),
                          ],
                        ),
                        SizedBox(
                          height: height * 0.015,
                        ),
                        Row(
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: width * 0.02),
                              child: Icon(
                                Icons.phone,
                                size: height * 0.04,
                                color: maincolor,
                              ),
                            ),
                            SizedBox(
                              width: width * 0.04,
                            ),
                            MyDefaultTextStyle(
                                text: Provider.of<NotificationsSystem>(context,
                                        listen: false)
                                    .rideRequest
                                    .userPhone
                                    .toString(),
                                height: height * 0.018,
                                color: black),
                          ],
                        ),
                        SizedBox(
                          height: height * 0.015,
                        ),
                        Row(
                          children: [
                            Container(
                              height: height * 0.045,
                              margin: EdgeInsets.only(
                                  left: width * 0.01,
                                  right: width * 0.02,
                                  bottom: height * 0.01),
                              child: Image.asset("assets/images/origin.png"),
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(
                                  left: width * 0.01,
                                  right: width * 0.02,
                                ),
                                child: MyDefaultTextStyle(
                                    text: Provider.of<NotificationsSystem>(
                                            context,
                                            listen: false)
                                        .rideRequest
                                        .userpositionName
                                        .toString(),
                                    height: height * 0.018,
                                    color: black),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: height * 0.015,
                        ),
                        Row(
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                  left: width * 0.01,
                                  right: width * 0.02,
                                  bottom: height * 0.02),
                              height: height * 0.04,
                              child:
                                  Image.asset("assets/images/destination.png"),
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(
                                    left: width * 0.01,
                                    right: width * 0.02,
                                    bottom: height * 0.01),
                                child: MyDefaultTextStyle(
                                    text: Provider.of<NotificationsSystem>(
                                            context,
                                            listen: false)
                                        .rideRequest
                                        .destinationName
                                        .toString(),
                                    height: height * 0.018,
                                    color: black),
                              ),
                            ),
                          ],
                        ),
                        Defaultbutton(
                            functon: () {},
                            text: "Arrived",
                            height: height * 0.06,
                            width: width * 0.35,
                            color: maincolor)
                      ]),
                );
              });
        },
      ),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: GoogleMap(
        initialCameraPosition: _kGooglePlex,
        mapType: MapType.normal,
        zoomControlsEnabled: true,
        zoomGesturesEnabled: true,
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
        polylines: Provider.of<MapsProvider>(context).polyLineSet,
        markers: Provider.of<MapsProvider>(
          context,
        ).markerSet,
        circles: Provider.of<MapsProvider>(context).circleSet,
        onMapCreated: (controller) async {
          _googleMapController.complete(controller);
          setState(() {
            newGoogleMapController = controller;
          });
          googleBlackTheme();
          intialGoogleMap();
          updateDriverPosition();
        },
      ),
    );
  }

  updateDriverPosition() {
    streamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      driverCurrentPosition = position;

      if (activeDriverIcon == null) {
        ImageConfiguration imageConfiguration =
            createLocalImageConfiguration(context, size: const Size(2, 2));

        BitmapDescriptor.fromAssetImage(
                imageConfiguration, "assets/images/car.png")
            .then((value) {
          setState(() {
            activeDriverIcon = value;
          });
        });
      }

      LatLng driverlatlng = LatLng(
          driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

      Marker liveDriverMarker = Marker(
          markerId: const MarkerId("driverPosition"),
          infoWindow: const InfoWindow(
              title: "your Current Position", snippet: "Current Position"),
          position: driverlatlng,
          icon: activeDriverIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan));

      LatLng latLng = LatLng(
          driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

      setState(() {
        CameraPosition divercameraPosition =
            CameraPosition(target: latLng, zoom: 16);

        newGoogleMapController!
            .animateCamera(CameraUpdate.newCameraPosition(divercameraPosition));

        Provider.of<MapsProvider>(context, listen: false).markerSet.removeWhere(
            (element) => element.markerId.value == "driverPosition");

        Provider.of<MapsProvider>(context, listen: false)
            .markerSet
            .add(liveDriverMarker);
      });
    });
  }
}
