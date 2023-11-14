
import 'package:drivres_app/presetation/app_manager/color_manager/colormanager.dart';
import 'package:fluttertoast/fluttertoast.dart';



showtoast(var error){
Fluttertoast.showToast(
        msg: '$error',
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 3,
        backgroundColor: maincolor,
        textColor: white,
        fontSize: 16.0,

    );
}