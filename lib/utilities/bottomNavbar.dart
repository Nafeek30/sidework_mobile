import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';
import 'package:sidework_mobile/app_view/bookings.dart';
import 'package:sidework_mobile/app_view/historyScreen.dart';
import 'package:sidework_mobile/app_view/homePage.dart';
import 'package:sidework_mobile/app_view/profiles.dart';

class BottomNavbar extends StatefulWidget {
  final int currentIndex;

  const BottomNavbar({super.key, required this.currentIndex});

  @override
  State<StatefulWidget> createState() {
    return BottomNavbarState();
  }
}

class BottomNavbarState extends State<BottomNavbar> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavyBar(
      selectedIndex: _currentIndex,
      showElevation: true,
      itemCornerRadius: 24,
      curve: Curves.easeIn,
      onItemSelected: (index) {
        setState(() => _currentIndex = index);
        if (_currentIndex == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const HomePage(),
            ),
          );
        } else if (_currentIndex == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const Bookings(),
            ),
          );
        } else if (_currentIndex == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const Profiles(),
            ),
          );
        } else if (_currentIndex == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HistoryScreen(),
            ),
          );
        }
      },
      items: <BottomNavyBarItem>[
        BottomNavyBarItem(
          icon: const Icon(Icons.apps),
          title: const Text('Home'),
          activeColor: Colors.red,
          textAlign: TextAlign.center,
        ),
        BottomNavyBarItem(
          icon: const Icon(Icons.message),
          title: const Text('Bookings'),
          activeColor: Colors.pink,
          textAlign: TextAlign.center,
        ),
        BottomNavyBarItem(
          icon: const Icon(Icons.people),
          title: const Text('Profile'),
          activeColor: Colors.purpleAccent,
          textAlign: TextAlign.center,
        ),
        BottomNavyBarItem(
          icon: const Icon(Icons.history),
          title: const Text('History'),
          activeColor: Colors.blue,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
