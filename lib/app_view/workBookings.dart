import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sidework_mobile/app_view/chatScreen.dart';
import 'package:sidework_mobile/utilities/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WorkBookings extends StatefulWidget {
  const WorkBookings({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return WorkBookingsState();
  }
}

class WorkBookingsState extends State<WorkBookings> {
  bool finishLoading = false;
  List allWorkBookings = [];
  String? finalToken = "";

  @override
  void initState() {
    super.initState();
    getInitialData();
    requestPermission();
    FirebaseMessaging.instance.subscribeToTopic("Animal");
  }

  @override
  Widget build(BuildContext context) {
    return finishLoading
        ? Container(
            margin: const EdgeInsets.only(
              top: 16,
            ),
            child: SingleChildScrollView(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: allWorkBookings.length,
                itemBuilder: (BuildContext context, int index) {
                  return Material(
                    elevation: 8,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              clientEmail: allWorkBookings[index]
                                  ['clientEmail'],
                              handymanEmail: allWorkBookings[index]
                                  ['handymanEmail'],
                              firstName: allWorkBookings[index]
                                  ['clientFirstName'],
                              lastName: allWorkBookings[index]
                                  ['clientLastName'],
                            ),
                          ),
                        );
                      },
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Constants.sideworkPurple,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Constants.lightTextColor,
                            ),
                          ),
                        ),
                        title: Text(
                          '${allWorkBookings[index]['clientFirstName']} ${allWorkBookings[index]['clientLastName']}',
                        ),
                        subtitle: Text(
                          '${allWorkBookings[index]['clientCity']}, ${allWorkBookings[index]['clientState']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Constants.darkTextColor,
                          ),
                        ),
                        trailing: allWorkBookings[index]['bookingConfirmed']
                            ? ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Constants.sideworkButtonOrange,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 6),
                                  textStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPressed: () {
                                  goToClientNotification(
                                      allWorkBookings[index]['clientEmail']);
                                },
                                child: const Text('Go to client'),
                              )
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Constants.sideworkButtonOrange,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  textStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPressed: () {
                                  acceptBooking(allWorkBookings[index].id,
                                      allWorkBookings[index]['clientEmail']);
                                },
                                child: const Text('Accept'),
                              ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider(
                    thickness: 2,
                  );
                },
              ),
            ),
          )
        : Center(
            child: Container(
              margin: const EdgeInsets.only(
                top: 16,
              ),
              child: const Text('No bookings found'),
            ),
          );
  }

  getInitialData() async {
    try {
      FirebaseFirestore.instance
          .collection("bookings")
          .where('handymanEmail',
              isEqualTo: FirebaseAuth.instance.currentUser!.email)
          .get()
          .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          allWorkBookings.add(doc);
        }
        setState(() {
          if (allWorkBookings.isNotEmpty) {
            finishLoading = true;
          }
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

  acceptBooking(String bookingId, String clientEmail) {
    var data = {
      "bookingConfirmed": true,
    };
    try {
      FirebaseFirestore.instance
          .collection("bookings")
          .doc(bookingId)
          .set(
            data,
            SetOptions(merge: true),
          )
          .then((value) {
        FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: clientEmail)
            .get()
            .then((querySnapshot) {
          for (var doc in querySnapshot.docs) {
            sendPushMessage(
              'Booking approved!',
              'Your booking has been approved.',
              doc.data()['fcmToken'],
            );
          }
          allWorkBookings.clear();
          getInitialData();
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

  goToClientNotification(String clientEmail) {
    try {
      FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: clientEmail)
          .get()
          .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          print(doc.id);
          sendPushMessage(
            'On the way!',
            'Get ready, your handyman is on the way.',
            doc['fcmToken'],
          );
          Fluttertoast.showToast(
            msg: 'Notification sent',
            backgroundColor: Constants.sideworkBlue,
            textColor: Constants.lightTextColor,
          );
        }
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        backgroundColor: Constants.sideworkBlue,
        textColor: Constants.lightTextColor,
      );
    }
  }

  /// FCM code
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

  void sendPushMessage(String title, String body, String? clientToken) async {
    print(clientToken);
    try {
      await http
          .post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAAR7AhksE:APA91bGKMfGwzp1oArtStPoU8xQbwwmAiLQQrlaY3-NkYC5sllpePRJ7RN3piBOE2HxTTUQwA6t2tpj9-sW8LNCrw2TpEj17u5f4iKd_4Pii2pNYigsBNhvJ1G0PjTan213y21OgzrWk',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{'body': body, 'title': title},
            'priority': 'high',
            "to": '$clientToken',
            "content_available": true,
          },
        ),
      )
          .then((value) {
        print('noti sent');
      });
    } catch (e) {
      print("error push notification");
    }
  }
}
