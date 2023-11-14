import 'package:drivres_app/data/driver_model/driver_model.dart';
import 'package:drivres_app/presetation/widgets/toast_widget/toast_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../presetation/screens/main_screen/mainScreen.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Driver driver = Driver();

  String driverStatus = "Offline";

  Driver? _driver;

  String? _id = "";

  bool? isdriver;

  Future<void> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      final authResult = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (authResult != null) {
        _driver =
            Driver(uid: authResult.user!.uid, email: authResult.user!.email!);
        showtoast("Registration Successful");

        final SharedPreferences prefs = await SharedPreferences.getInstance();

        _id = _driver!.uid;

        prefs.setString("id", _id!);

        notifyListeners();

        Map<String, dynamic> driverMap = {
          "id": authResult.user!.uid,
          "name": name,
          "email": email,
          "phone": phone,
        };

        DatabaseReference driversRef =
            FirebaseDatabase.instance.ref().child("drivers");
        driversRef.child(authResult.user!.uid).set(driverMap).then((_) {
          // Data is successfully written to the database, notify listeners again.
          notifyListeners();
        }).catchError((error) {
          // Handle database write error here (e.g., show toast, log error, etc.).
          print("Error writing data to the database: $error");
          showtoast("Error writing data to the database: $error");
        });
      } else {
        showtoast("Error creating user");
      }
    } catch (e) {
      print('Error registering user: $e');

      throw e;
    }
  }

  Future<void> saveCareDetail({
    required String carModel,
    required String carNum,
    required String carColor,
    required String carType,
  }) async {
    try {
      Map<String, dynamic> carDetail = {
        "car_model": carModel,
        "car_num": carNum,
        "car_color": carColor,
        "car_type": carType
      };

      DatabaseReference driversRef =
          FirebaseDatabase.instance.ref().child("drivers");
      driversRef
          .child(FirebaseAuth.instance.currentUser!.uid)
          .child("cardetail")
          .set(carDetail)
          .then((_) {
        // Data is successfully written to the database, notify listeners again.
        notifyListeners();
      }).catchError((error) {
        // Handle database write error here (e.g., show toast, log error, etc.).
        print("Error writing data to the database: $error");
        showtoast("Error writing data to the database: $error");
      });
    } catch (error) {
      throw error;
    }
  }

  Future<void> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final authResult = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (authResult != null) {
        _driver =
            Driver(uid: authResult.user!.uid, email: authResult.user!.email!);

        print("hello :${authResult.user!.uid}");

        DatabaseReference driverRef =
            FirebaseDatabase.instance.ref().child("drivers");

        driverRef.child(authResult.user!.uid).once().then(
          (data) async {
            final snap = data.snapshot;

            if (snap.value != null) {
              Navigator.of(context).pop();

              Navigator.pushReplacement(
                  context,
                  PageTransition(
                      curve: Curves.easeIn,
                      duration: const Duration(milliseconds: 550),
                      type: PageTransitionType.leftToRight,
                      child: const MainScreen()));
              showtoast("login Successful");
              notifyListeners();

              final SharedPreferences prefs =
                  await SharedPreferences.getInstance();

              _id = _driver!.uid;

              prefs.setString("id", _id!);

              notifyListeners();
            } else {
              showtoast("You are not a user");
              Navigator.of(context).pop();
              logOut();

              notifyListeners();
            }
          },
        );
      }
    } catch (error) {
      print("message :$error");
      throw error;
    }
  }

  Future<void> logOut() async {
    _firebaseAuth.signOut();
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    _id = '';

    prefs.setString("id", _id!);
    notifyListeners();
  }

  changeDriverStatus() {
    if (driverStatus == "Online") {
      driverStatus = "Offline";
      notifyListeners();
    } else if (driverStatus == "Offline") {
      driverStatus = "Online";
      notifyListeners();
    }
  }
  // this methode for retrive current online driver information

  void retriveCurrentOlineDriver() {
    FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) {
        
        driver.email = (snap.snapshot.value as Map)['email'];
        driver.driverName =
            (snap.snapshot.value as Map)['name'];
        driver.phone = (snap.snapshot.value as Map)['phone'];
        driver.uid = (snap.snapshot.value as Map)['id'];
        driver.carColor = (snap.snapshot.value
            as Map)['cardetail']['car_color'];
        driver.carNumber = (snap.snapshot.value
            as Map)['cardetail']['car_num'];

        print(driver.carColor);
        print(driver.driverName);

        notifyListeners();
      }
    });
  }
}
