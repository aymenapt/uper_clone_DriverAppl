import 'package:flutter/material.dart';

import '../app_manager/color_manager/colormanager.dart';



Widget Defaultbutton({
  required functon,
  Color color = Colors.blue,
  Color textcolor = white,
  required String text,
  double border = 10.0,
  double fontsize = 18,
  required double height,
  required double width,
  bool isloading = false,
}) {
  return Container(
    width: width,
    height: height,
    child: ElevatedButton(
      onPressed: functon,
      child: isloading
          ? CircularProgressIndicator(
              color: white,
            )
          : Text(
              text,
              style: TextStyle(
                color: textcolor,
                fontSize: fontsize,
                fontFamily: 'Cairo',
              ),
            ),
      style: ElevatedButton.styleFrom(
        primary: color,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(border))),
      ),
    ),
  );
}
