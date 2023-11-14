import 'package:drivres_app/presetation/app_manager/color_manager/colormanager.dart';
import 'package:drivres_app/presetation/app_manager/text_manager/textmanager.dart';
import 'package:flutter/material.dart';

class ProgressDialogue extends StatelessWidget {
  final String message;

  const ProgressDialogue({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.only(left: 30),
        height: 90,
        width: 80,
        decoration: BoxDecoration(
            color: white, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(maincolor),
            ),
            const SizedBox(
              width: 30,
            ),
            MyDefaultTextStyle(text: message, height: 16, color: black)
          ],
        ),
      ),
    );
  }
}
