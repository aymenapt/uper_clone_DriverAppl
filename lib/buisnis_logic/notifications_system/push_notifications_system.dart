import 'package:drivres_app/buisnis_logic/authntication_provider/authentication_logic.dart';
import 'package:drivres_app/data/driver_model/driver_model.dart';
import 'package:drivres_app/data/ride_request_model/ride_request_model.dart';
import 'package:drivres_app/presetation/widgets/notification_dialogue/notification_dialogue.dart';
import 'package:drivres_app/presetation/widgets/toast_widget/toast_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '../../presetation/screens/ride_map_screen/ride_map_screen.dart';

class NotificationsSystem with ChangeNotifier {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer();

  String? rideRequestID;
  DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

  Position? driverCurrentPosition;

  // instane of RideRequest model

  RideRequest rideRequest = RideRequest();
  String? reqID = "";

  Future intializeNotifications(BuildContext context) async {
    //1.Background notifications
    // when the app on the background and  open directely from the push notification

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
      // display request ride and user informations

      print("this is requestID :");
      print(remoteMessage!.data["rideRequestID"]);
      rideRequestID = remoteMessage.data["rideRequestID"];
      fetchRideRequestData(context);
      notifyListeners();
    });

    //2.Foreground notifications
    // when the app is open and recive notification

    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
      // display request ride and user informations
      print("this is requestID :");
      print(remoteMessage!.data["rideRequestID"]);
      rideRequestID = remoteMessage.data["rideRequestID"];
      fetchRideRequestData(context);
      notifyListeners();
    });

    //3.Terminated notifications
    // when the app is completely closed and open directely from the push notification

    firebaseMessaging.getInitialMessage().then((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        // display request ride and user informations
        print("this is requestID :");
        print(remoteMessage.data["rideRequestID"]);
        rideRequestID = remoteMessage.data["rideRequestID"];
        fetchRideRequestData(context);
        notifyListeners();
      }
    });
  }

  Future getAngGenerateTokens() async {
    String? token = await firebaseMessaging.getToken();

    print("FCM :");
    print(token);

    FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("driversToken")
        .set(token);

    firebaseMessaging.subscribeToTopic('divers');
    firebaseMessaging.subscribeToTopic('users');
  }

  // fetch ride request data from firebase using ride requst ID

  Future<void> fetchRideRequestData(BuildContext context) async {
    DatabaseEvent dataSnapshot = await databaseReference
        .child("all ride requests")
        .child(rideRequestID!)
        .once();

    if (dataSnapshot.snapshot.value != null) {
      assetsAudioPlayer.open(Audio("assets/music/music_notification.mp3"));
      // Data found for the specified ID.
      double originlat =
          (dataSnapshot.snapshot.value! as Map)["original"]["latitude"];

      double originlng =
          (dataSnapshot.snapshot.value! as Map)["original"]["longitude"];

      double destinationlat =
          (dataSnapshot.snapshot.value! as Map)["destination"]["latitude"];

      double destinationlng =
          (dataSnapshot.snapshot.value! as Map)["destination"]["longitude"];

      rideRequest.destinationLatLng = LatLng(destinationlat, destinationlng);
      rideRequest.originLatLng = LatLng(originlat, originlng);
      rideRequest.destinationName =
          (dataSnapshot.snapshot.value! as Map)["destinationName"];

      rideRequest.userpositionName =
          (dataSnapshot.snapshot.value! as Map)["currentpositionName"];

      rideRequest.userEmail = (dataSnapshot.snapshot.value! as Map)["email"];
      rideRequest.userName = (dataSnapshot.snapshot.value! as Map)["username"];
      rideRequest.userPhone = (dataSnapshot.snapshot.value! as Map)["phone"];
      notifyListeners();

      showDialog(
          context: context,
          builder: (context) {
            return NotificationDialogue(
              rideRequest: rideRequest,
            );
          });
      print(rideRequest.originLatLng);
    } else {
      // Data not found.
    }
  }

  // accept ride request function

  acceptRideRequest(BuildContext context) {
    FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("newRideStatus")
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) {
        reqID = snap.snapshot.value.toString();
        print('hi this');
        print(snap.snapshot.value.toString());
        notifyListeners();
        print('hello this');
        print(rideRequestID);

        if (rideRequestID == snap.snapshot.value.toString()) {
          FirebaseDatabase.instance
              .ref()
              .child("drivers")
              .child(FirebaseAuth.instance.currentUser!.uid)
              .child("newRideStatus")
              .set("accept");
              Navigator.push(
                          context,
                          PageTransition(
                              curve: Curves.easeIn,
                              duration: const Duration(milliseconds: 550),
                              type: PageTransitionType.leftToRight,
                              child: const RideMapScreen()));

          print(snap.snapshot.value.toString());
        } else {
          showtoast("this ride request dosn't exist");
        }
      } else {
        showtoast("this driver dosn't exist");
      }
    });
  }

  // this function to save online driver information to ride requst when he accept it

  saveDriverInfo(BuildContext context) {
    DatabaseReference driverReference = FirebaseDatabase.instance
        .ref()
        .child("all ride requests")
        .child(rideRequestID.toString());

    Driver driver = Provider.of<AuthService>(context, listen: false).driver;

    driverReference.child("status").set("accepted");

    Map driverLocation = {
      'latitude': driverCurrentPosition!.latitude,
      'longitude': driverCurrentPosition!.longitude
    };

    driverReference.child('driverName').set(driver.driverName);
    driverReference.child('driverEmail').set(driver.email);
    driverReference.child('driverPhone').set(driver.phone);
    driverReference.child('carColor').set(driver.carColor);
    driverReference.child('CarNum').set(driver.carNumber);
    driverReference.child('driverID').set(driver.uid);
    driverReference.child('driverLocation').set(driverLocation);

  

    saveRideHistory();
  }

  saveRideHistory() {
    DatabaseReference rideHistoryReference = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("rideHistory");

    rideHistoryReference.child(rideRequestID.toString()).set("true");
  }
}
