import 'package:drivres_app/presetation/screens/authentication_screens/car_detail_screen/car_detail_screen.dart';
import 'package:drivres_app/presetation/screens/authentication_screens/signUp_screen/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '../../../../buisnis_logic/authntication_provider/authentication_logic.dart';
import '../../../app_manager/color_manager/colormanager.dart';
import '../../../app_manager/text_field_manager/text_field_manager.dart';
import '../../../app_manager/text_manager/textmanager.dart';
import '../../../buttou_manager/buttomn_ùanager.dart';
import '../../../widgets/progress_dialogue/progress_dialogue.dart';
import '../../../widgets/toast_widget/toast_widget.dart';
import '../../main_screen/mainScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  bool isloading = false;
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: maincolor,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                child: SvgPicture.asset("assets/images/32440879_7960186.svg"),
                height: height * 0.35,
                width: width,
                padding: EdgeInsets.all(height * 0.03),
                decoration: const BoxDecoration(
                    color: white,
                    borderRadius:
                        BorderRadius.only(bottomLeft: Radius.circular(68))),
              ),
              SizedBox(
                height: height * 0.03,
              ),
              Container(
                child: MyDefaultTextStyle(
                    text: "Login",
                    height: height * 0.04,
                    color: white,
                    bold: true),
              ),
              SizedBox(
                height: height * 0.03,
              ),
              MyTextForm(
                  controller: email,
                  hinttext: "email",
                  icon: Icons.email,
                  height: height * 0.07,
                  width: width * 0.85),
              SizedBox(
                height: height * 0.02,
              ),
              MyTextForm(
                  controller: password,
                  hinttext: "password",
                  icon: Icons.key,
                  height: height * 0.07,
                  width: width * 0.85,
                  issecure: true),
              SizedBox(
                height: height * 0.02,
              ),
              Defaultbutton(
                  functon: () async {
                    showDialog(
                      context: context,
                      builder: (ctx) =>
                          ProgressDialogue(message: "Please wait"),
                    );
                    try {
                      await Provider.of<AuthService>(context, listen: false)
                          .login(
                              email: email.text,
                              password: password.text,
                              context: context);
                    } catch (e) {
                      Navigator.of(context).pop();
                      showtoast("message$e");
                    }
                  },
                  text: "Login",
                  height: height * 0.07,
                  width: width * 0.7,
                  isloading: isloading,
                  color: const Color.fromARGB(255, 2, 162, 180)),
              TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        PageTransition(
                            curve: Curves.easeIn,
                            duration: const Duration(milliseconds: 550),
                            type: PageTransitionType.leftToRight,
                            child: const SignUpScreen()));
                  },
                  child: MyDefaultTextStyle(
                      text: "you don't have account ?",
                      height: height * 0.018,
                      color: white))
            ],
          ),
        ),
      ),
    );
  }
}
