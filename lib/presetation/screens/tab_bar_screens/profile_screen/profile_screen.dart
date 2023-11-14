import 'package:drivres_app/buisnis_logic/authntication_provider/authentication_logic.dart';
import 'package:drivres_app/presetation/screens/authentication_screens/login_screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '../../../app_manager/color_manager/colormanager.dart';
import '../../../app_manager/text_manager/textmanager.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Provider.of<AuthService>(context, listen: false).logOut();

          Navigator.pushReplacement(
              context,
              PageTransition(
                  type: PageTransitionType.leftToRight,
                  child: const LoginScreen()));
        },
      ),
      body: Center(
        child: MyDefaultTextStyle(text: "profile", height: 18, color: black),
      ),
    );
  }
}
