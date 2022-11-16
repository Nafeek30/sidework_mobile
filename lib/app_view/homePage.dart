import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sidework_mobile/controller/firebaseController.dart';
import 'package:sidework_mobile/landing_view/loginPage.dart';
import 'package:sidework_mobile/utilities/bottomNavbar.dart';
import 'package:sidework_mobile/utilities/constants.dart';
import 'package:flutter/material.dart';
import 'package:sidework_mobile/utilities/customFormTextFields.dart';
import 'package:flutter/foundation.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  String? finalToken = "";
  int homeScreenState = 0;
  String? selectedValue;
  List allHandyMen = [];
  List<String> tags = [
    'Plumber',
    'Mechanic',
    'Mover',
    'Pest Control',
    'Yard Work',
  ];

  @override
  void initState() {
    super.initState();
    requestPermission();
    FirebaseMessaging.instance.subscribeToTopic("sidework");
  }

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
        child: Column(
          children: [
            /// Search bar
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    hint: const Text('Search handymen'),
                    value: selectedValue,
                    onChanged: (val) {
                      setState(() {
                        selectedValue = val;
                        allHandyMen.clear();
                        homeScreenState = 0;
                        filteredHandyMen(val!);
                      });
                    },
                    items: tags.map((tag) {
                      return DropdownMenuItem<String>(
                        value: tag,
                        child: Text(tag),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

            /// Filtered list of handymen
            homeScreenState == 0
                ? Container(
                    margin: const EdgeInsets.only(top: 32),
                    child: const Text(
                      'Use search bar to find handymen',
                    ),
                  )
                : allHandyMen.isEmpty
                    ? Container(
                        margin: const EdgeInsets.only(top: 32),
                        child: const Text(
                          'No handymen found',
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: allHandyMen.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            title: Text(
                                '${allHandyMen[index]['firstName']} ${allHandyMen[index]['lastName']}'),
                            subtitle: Text(
                              '${allHandyMen[index]['tags']} | Hourly rate: ${allHandyMen[index]['hourlyRate']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            trailing: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Constants.sideworkButtonOrange,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                textStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: () async {
                                await showBookingForm(
                                    context, allHandyMen[index]['email']);
                              },
                              child: const Text('Book'),
                            ),
                          );
                        }),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavbar(
        currentIndex: 0,
      ),
    );
  }

  Future filteredHandyMen(String tag) async {
    try {
      FirebaseFirestore.instance
          .collection("users")
          .where('tags', isEqualTo: tag)
          .get()
          .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          allHandyMen.add(doc.data());
        }
        setState(() {
          homeScreenState = 1;
        });
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        backgroundColor: Constants.sideworkBlue,
        textColor: Constants.lightTextColor,
      );
    }
  }

  Future<void> showBookingForm(
      BuildContext context, String handymanEmail) async {
    TextEditingController descriptionController = TextEditingController();

    return await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: CustomFormTextFields(
              maxLines: 5,
              controller: descriptionController,
              hintTitle: 'Enter work description',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  await saveBooking(
                      descriptionController.text, handymanEmail, context);
                },
                child: const Text('Submit'),
              ),
            ],
          );
        });
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      getToken();
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  void getToken() async {
    await FirebaseMessaging.instance.getToken().then((token) {
      var data = {
        "fcmToken": token,
      };
      try {
        FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .set(
              data,
              SetOptions(merge: true),
            )
            .then((value) {
          setState(() {
            finalToken = token;
          });
        });
      } catch (e) {
        Fluttertoast.showToast(
          msg: e.toString(),
          backgroundColor: Constants.sideworkBlue,
          textColor: Constants.lightTextColor,
        );
      }
    });
  }
}
