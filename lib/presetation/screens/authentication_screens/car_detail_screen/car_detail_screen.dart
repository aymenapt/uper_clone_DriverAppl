import 'package:drivres_app/presetation/screens/main_screen/mainScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:provider/provider.dart';

import '../../../../buisnis_logic/authntication_provider/authentication_logic.dart';
import '../../../app_manager/color_manager/colormanager.dart';
import '../../../app_manager/text_field_manager/text_field_manager.dart';
import '../../../app_manager/text_manager/textmanager.dart';
import '../../../buttou_manager/buttomn_ùanager.dart';
import '../../../widgets/progress_dialogue/progress_dialogue.dart';
import '../../../widgets/toast_widget/toast_widget.dart';

class CarDetailScreen extends StatefulWidget {
  const CarDetailScreen({super.key});

  @override
  State<CarDetailScreen> createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends State<CarDetailScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  TextEditingController carModel = TextEditingController();
  TextEditingController carNum = TextEditingController();
  TextEditingController carColor = TextEditingController();

  String selectedType = "";

  List<String> _caType = ["uber-go", "uber-x", "bike"];
  bool isloading = false;
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: maincolor,
      body:
        Form(
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
                      text: "Add your car",
                      height: height * 0.04,
                      color: white,
                      bold: true),
                ),
                SizedBox(
                  height: height * 0.03,
                ),
                MyTextForm(
                    controller: carModel,
                    hinttext: "car model",
                    icon: Icons.car_repair,
                    height: height * 0.07,
                    width: width * 0.85),
                SizedBox(
                  height: height * 0.02,
                ),
                MyTextForm(
                    controller: carNum,
                    hinttext: "car num",
                    icon: Icons.car_rental_outlined,
                    height: height * 0.07,
                    width: width * 0.85),
                SizedBox(
                  height: height * 0.02,
                ),
                MyTextForm(
                    controller: carColor,
                    hinttext: "car color",
                    icon: Icons.color_lens,
                    height: height * 0.07,
                    width: width * 0.85),
                SizedBox(
                  height: height * 0.02,
                ),
                Container(
                  margin: EdgeInsets.only(left: width * 0.1),
                  alignment: Alignment.centerLeft,
                  child: DropdownButton(
                      hint: MyDefaultTextStyle(
                          text: "select car type", height: height * 0.016),
                      items: _caType
                          .map((e) => DropdownMenuItem(
                              value: e,
                              child: MyDefaultTextStyle(
                                  text: e,
                                  height: height * 0.018,
                                  color: black)))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedType = value.toString();
                        });
                      }),
                ),
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
                            .saveCareDetail(
                                carModel: carModel.text,
                                carNum: carNum.text,
                                carColor: carColor.text,
                                carType: selectedType);

                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => MainScreen(),
                        ));
                      } catch (e) {
                        Navigator.of(context).pop();
                        showtoast("message$e");
                      }
                    },
                    text: "Save Now",
                    height: height * 0.07,
                    width: width * 0.7,
                    isloading: isloading,
                    color: Color.fromARGB(255, 2, 162, 180)),
              ],
            ),
          ),
        ),
      
    );
  }
}
