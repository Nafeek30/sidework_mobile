import 'package:firebase_auth/firebase_auth.dart';
import 'package:sidework_mobile/landing_view/loginPage.dart';
import 'package:sidework_mobile/utilities/constants.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.sideworkBlue,
        leading: Container(),
        title: const Text(
          'Home',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const LoginPage()));
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
      body: Center(
        child: Text(
            'Mobile Home Page - ${FirebaseAuth.instance.currentUser!.email}'),
      ),
    );
  }
}
