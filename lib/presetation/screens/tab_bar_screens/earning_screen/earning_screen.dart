import 'package:flutter/material.dart';

import '../../../app_manager/color_manager/colormanager.dart';
import '../../../app_manager/text_manager/textmanager.dart';

class EarinigScreen extends StatelessWidget {
  const EarinigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: MyDefaultTextStyle(text: "earning", height: 18,color: black),),
    );
  }
}