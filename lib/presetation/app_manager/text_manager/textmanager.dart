
import 'package:flutter/material.dart';

import '../color_manager/colormanager.dart';





Widget MyDefaultTextStyle({
  required String text,
  Color color = white,
  required double height ,
  bool bold =false,

 
}) {
  return Text(
    text,
    
    style:TextStyle(
      
     color: color,
     fontSize: height,
     fontFamily:  'Cairo',
     fontWeight: bold?FontWeight.bold:FontWeight.normal
  ));
}
