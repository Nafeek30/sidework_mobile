import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sidework_mobile/utilities/constants.dart';

class PersonalBookings extends StatefulWidget {
  const PersonalBookings({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PersonalBookingsState();
  }
}

class PersonalBookingsState extends State<PersonalBookings> {
  bool finishLoading = false;
  List allPesonalBookings = [];

  @override
  void initState() {
    super.initState();
    getInitialData();
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
                itemCount: allPesonalBookings.length,
                itemBuilder: (BuildContext context, int index) {
                  return Material(
                    elevation: 8,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Constants.sideworkBlue,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Constants.lightTextColor,
                          ),
                        ),
                      ),
                      title: Text(
                          '${allPesonalBookings[index]['handymanFirstName']} ${allPesonalBookings[index]['handymanLastName']}'),
                      subtitle: Text(
                        'Confirmation Status: ${allPesonalBookings[index]['bookingConfirmed'] ? 'Confirmed' : 'Pending'}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: allPesonalBookings[index]['bookingConfirmed']
                              ? Constants.sideworkGreen
                              : Constants.darkTextColor,
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
          .where('clientEmail',
              isEqualTo: FirebaseAuth.instance.currentUser!.email)
          .get()
          .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          allPesonalBookings.add(doc);
        }
        setState(() {
          if (allPesonalBookings.isNotEmpty) {
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
}
