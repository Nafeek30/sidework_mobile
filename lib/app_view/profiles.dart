import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sidework_mobile/app_view/personalProfile.dart';
import 'package:sidework_mobile/app_view/workProfile.dart';
import 'package:sidework_mobile/landing_view/loginPage.dart';
import 'package:sidework_mobile/utilities/bottomNavbar.dart';
import 'package:sidework_mobile/utilities/constants.dart';

class Profiles extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ProfilesState();
  }
}

class ProfilesState extends State<Profiles> {
  int currentProfile = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.sideworkBlue,
        leading: Container(),
        title: const Text(
          'Profiles',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginPage(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              primary: Constants.sideworkBlue,
            ),
            child: const Text(
              'Logout',
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 12,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Constants.sideworkBlue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        currentProfile = 0;
                      });
                    },
                    child: const Text('Personal'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Constants.sideworkBlue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        currentProfile = 1;
                      });
                    },
                    child: const Text('Professional'),
                  ),
                ],
              ),
              currentProfile == 0
                  ? const PersonalProfile()
                  : const WorkProfile(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavbar(
        currentIndex: 2,
      ),
    );
  }
}
