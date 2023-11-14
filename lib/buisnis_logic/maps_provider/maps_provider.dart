import 'dart:async';
import 'dart:convert';

import 'package:drivres_app/buisnis_logic/notifications_system/push_notifications_system.dart';
import 'package:drivres_app/data/dirction_details_models/dirction_details_models.dart';
import 'package:drivres_app/data/ride_request_model/ride_request_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../apikeys/apikeys.dart';
import '../../apikeys/streambuilder.dart';
import '../../presetation/app_manager/color_manager/colormanager.dart';

class MapsProvider with ChangeNotifier {
  bool isEnabeld = false;

  Position? currentPosition;

  // set of points tp draw polilines on map
  Set<Polyline> polyLineSet = {};

  // set of markers on map
  Set<Marker> markerSet = {};
  // set of circles on map
  Set<Circle> circleSet = {};

  List<LatLng> pLineCordinatesList = [];
  late LatLngBounds boundsLatLng;
  // instance of direction deatils

  DirectionDetail directionDetail = DirectionDetail();

  LocationPermission? _locationPermission;

  Future<bool> checkIfLocationPermissionAllowed() async {
    isEnabeld = await Geolocator.isLocationServiceEnabled();

    if (!isEnabeld) {
      isEnabeld = false;
      notifyListeners();
      return false;
    }

    _locationPermission = await Geolocator.requestPermission();

    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();

      if (_locationPermission == LocationPermission.denied) {
        isEnabeld = false;
        notifyListeners();
        return false;
      }
    }

    if (_locationPermission == LocationPermission.deniedForever) {
      isEnabeld = false;
      notifyListeners();
    }
    isEnabeld = true;
    notifyListeners();
    return true;
  }

  driverIsOnlineNow(Position currentPosition) async {
    Geofire.initialize("activeDrivers");

    Position newPostition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    currentPosition = newPostition;

    Geofire.setLocation(FirebaseAuth.instance.currentUser!.uid,
        currentPosition.latitude, currentPosition.longitude);

    DatabaseReference databaseReference = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("newRideStatus");

    databaseReference.onValue.listen((event) {});

    notifyListeners();
  }

  driverIsOfflineNow() {
    Geofire.removeLocation(FirebaseAuth.instance.currentUser!.uid);

    DatabaseReference? databaseReference = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("newRideStatus");

    databaseReference.onDisconnect();
    databaseReference.remove();

    databaseReference = null;
  }

  // get direction polilines from driver position to user position(distination)

  Future<void> getDirections(
      LatLng originalPosition, LatLng distinationPosition) async {
    String baseUrl =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${originalPosition.latitude},${originalPosition.longitude}&destination=${distinationPosition.latitude},${distinationPosition.longitude}&key=$apiKey";

    try {
      final res = await http.get(Uri.parse(baseUrl));

      if (res.statusCode == 200) {
        final data = json.decode(res.body);

        directionDetail.distance_text =
            data["routes"][0]["legs"][0]["distance"]["text"];

        directionDetail.distance_value =
            data["routes"][0]["legs"][0]["distance"]["value"];

        directionDetail.duration_text =
            data["routes"][0]["legs"][0]["duration"]["text"];

        directionDetail.duration_value =
            data["routes"][0]["legs"][0]["duration"]["value"];

        directionDetail.points =
            data["routes"][0]["overview_polyline"]["points"];

        notifyListeners();

        print("points is : ${directionDetail.points}");
      } else {
        throw "response error";
      }
    } catch (error) {
      print(error);
    }
  }

  drawpolilines(BuildContext context) async {
    RideRequest rideRequest =
        Provider.of<NotificationsSystem>(context, listen: false).rideRequest;

    LatLng originLatLng = rideRequest.originLatLng ?? const LatLng(20, 20);
    LatLng distinationLatLng =
        rideRequest.destinationLatLng ?? const LatLng(20, 20);

    await getDirections(originLatLng, distinationLatLng);

    polyLineSet.clear();
    pLineCordinatesList.clear();

    if (directionDetail.points != null) {
      PolylinePoints polylinePoints = PolylinePoints();

      List<PointLatLng> decodepolyLineList =
          polylinePoints.decodePolyline(directionDetail.points ?? "");

      if (decodepolyLineList.isNotEmpty) {
        for (var pointLatLng in decodepolyLineList) {
          pLineCordinatesList
              .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
        }

        Polyline polyline = Polyline(
            polylineId: const PolylineId("PolylineID"),
            color: maincolor,
            jointType: JointType.round,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            points: pLineCordinatesList,
            geodesic: true);

        polyLineSet.add(polyline);

        notifyListeners();

        if (originLatLng.latitude > distinationLatLng.latitude &&
            originLatLng.longitude > distinationLatLng.longitude) {
          boundsLatLng = LatLngBounds(
              southwest: distinationLatLng, northeast: originLatLng);
        } else if (originLatLng.longitude > distinationLatLng.longitude) {
          boundsLatLng = LatLngBounds(
            southwest:
                LatLng(originLatLng.latitude, distinationLatLng.longitude),
            northeast:
                LatLng(distinationLatLng.latitude, originLatLng.longitude),
          );
        } else if (originLatLng.latitude > distinationLatLng.latitude) {
          boundsLatLng = LatLngBounds(
            southwest:
                LatLng(distinationLatLng.latitude, originLatLng.longitude),
            northeast:
                LatLng(originLatLng.latitude, distinationLatLng.longitude),
          );
        } else {
          boundsLatLng = LatLngBounds(
              southwest: originLatLng, northeast: distinationLatLng);
        }

        notifyListeners();

        Marker distinationMarker = Marker(
          markerId: const MarkerId("DistinationID"),
          infoWindow: InfoWindow(
              title: rideRequest.destinationName, snippet: "destination"),
          position: distinationLatLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        );

        markerSet.add(distinationMarker);
        notifyListeners();

        Circle originCircle = Circle(
          circleId: const CircleId("originID"),
          fillColor: Colors.green,
          radius: 12,
          strokeWidth: 3,
          strokeColor: Colors.white,
          center: originLatLng,
        );

        Circle destinationCircle = Circle(
          circleId: const CircleId("DistinationID"),
          fillColor: Colors.green,
          radius: 12,
          strokeWidth: 3,
          strokeColor: Colors.red,
          center: distinationLatLng,
        );

        circleSet.add(originCircle);
        circleSet.add(destinationCircle);
        notifyListeners();
      }
    }
  }

  // this method to pause driver live position updates

  void pauseLiveLovation() {
    streamSubscription!.pause();
    Geofire.removeLocation(FirebaseAuth.instance.currentUser!.uid.toString());
  }

  void resumeLivePosition() {
    streamSubscription!.resume();

    Geofire.setLocation(FirebaseAuth.instance.currentUser!.uid.toString(),
        currentPosition!.latitude, currentPosition!.longitude);
  }
}
