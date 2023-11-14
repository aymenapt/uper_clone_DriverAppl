import 'package:drivres_app/buisnis_logic/maps_provider/maps_provider.dart';
import 'package:drivres_app/buisnis_logic/notifications_system/push_notifications_system.dart';
import 'package:drivres_app/presetation/app_manager/color_manager/colormanager.dart';
import 'package:drivres_app/presetation/screens/authentication_screens/car_detail_screen/car_detail_screen.dart';
import 'package:drivres_app/presetation/screens/splachscreen/splachscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'buisnis_logic/authntication_provider/authentication_logic.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp();
  runApp(
    
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider<MapsProvider>(create: (_) => MapsProvider()),
        ChangeNotifierProvider<NotificationsSystem>(create: (_) => NotificationsSystem()),
      ],
      child: MyApp(
        child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(backgroundColor: maincolor),
        useMaterial3: true,
      ),
      home: const SplachScreen(),
      )),
    ));
}

class MyApp extends StatefulWidget {
  final Widget? child;

  const MyApp({super.key, this.child});

  static void restartApp(BuildContext context) {
    context.findRootAncestorStateOfType<_MyAppState>()!.restartApp();
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(key: key, child: widget.child!);
  }
}
