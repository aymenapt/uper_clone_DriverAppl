import 'package:drivres_app/buisnis_logic/notifications_system/push_notifications_system.dart';
import 'package:drivres_app/presetation/app_manager/color_manager/colormanager.dart';
import 'package:drivres_app/presetation/app_manager/text_manager/textmanager.dart';
import 'package:drivres_app/presetation/screens/tab_bar_screens/earning_screen/earning_screen.dart';
import 'package:drivres_app/presetation/screens/tab_bar_screens/home_screen/home_screen.dart';
import 'package:drivres_app/presetation/screens/tab_bar_screens/profile_screen/profile_screen.dart';
import 'package:drivres_app/presetation/screens/tab_bar_screens/rating_screen/rating_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int selectedItem = 0;
  TabController? _tabController;
  void selectItem(int index) {
    setState(() {
      selectedItem = index;
      _tabController!.index = selectedItem;
    });
  }

  regestreTokens() async {
    await Provider.of<NotificationsSystem>(context, listen: false)
        .intializeNotifications(context);

    await Provider.of<NotificationsSystem>(context, listen: false)
        .getAngGenerateTokens();
  }

  @override
  void initState() {
    regestreTokens();
    _tabController = TabController(length: 4, vsync: this);
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            HomeScreen(),
            EarinigScreen(),
            RatingScreen(),
            ProfileScreen()
          ]),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.credit_card), label: "earning"),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: "rating"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "profile")
        ],
        selectedItemColor: maincolor,
        unselectedItemColor: Colors.black38,
        currentIndex: selectedItem,
        onTap: (value) => selectItem(value),
      ),
    );
  }
}
