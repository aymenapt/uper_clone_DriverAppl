import 'dart:async';

import 'package:drivres_app/buisnis_logic/maps_provider/maps_provider.dart';
import 'package:drivres_app/presetation/screens/authentication_screens/signUp_screen/signup_screen.dart';
import 'package:drivres_app/presetation/screens/main_screen/mainScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app_manager/color_manager/colormanager.dart';
import '../../app_manager/text_manager/textmanager.dart';

class SplachScreen extends StatefulWidget {
  const SplachScreen({Key? key}) : super(key: key);

  @override
  State<SplachScreen> createState() => _SplachScreenState();
}

class _SplachScreenState extends State<SplachScreen> {
  void getPermission() async {
    await Provider.of<MapsProvider>(context, listen: false)
        .checkIfLocationPermissionAllowed();
  }

  void pagenavigate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('id')??'';

    if (id.isNotEmpty) {
      Navigator.pushReplacement(
          context,
          PageTransition(
              type: PageTransitionType.leftToRight, child: const MainScreen()));
    } else if (id.isEmpty) {
      Navigator.pushReplacement(
          context,
          PageTransition(
              type: PageTransitionType.theme, child: const SignUpScreen()));
    }
  }

  @override
  void initState() {
    getPermission();
    // TODO: implement initState
    Timer(const Duration(milliseconds: 3000), () {
      pagenavigate();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: maincolor,
      extendBody: true,
      body: SafeArea(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: height * 0.3,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: height * 0.04),
                    height: height * 0.03,
                    width: width * 0.03,
                    decoration:
                        BoxDecoration(color: white, shape: BoxShape.circle),
                  ),
                  SizedBox(
                    width: width * 0.02,
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: MyDefaultTextStyle(
                        text: "Driver", height: height * 0.06, bold: true),
                  ),
                ],
              ),
              SizedBox(
                height: height * 0.38,
              ),
              Container(
                  alignment: Alignment.center,
                  child: Text(
                    'made by',
                    style: TextStyle(
                        color: white,
                        fontSize: height * 0.018,
                        fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  )),
              SizedBox(
                height: height * 0.009,
              ),
              Container(
                  alignment: Alignment.center,
                  child: Text(
                    'Aymen Academy',
                    style: TextStyle(
                        color: white,
                        fontSize: height * 0.019,
                        fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center,
                  ))
            ]),
      ),
    );
  }
}
