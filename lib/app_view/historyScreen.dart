import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sidework_mobile/utilities/bottomNavbar.dart';
import 'package:sidework_mobile/utilities/constants.dart';

class HistoryScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HistoryScreenState();
  }
}

class HistoryScreenState extends State<HistoryScreen> {
  List allBookingsHistory = [];

  @override
  void initState() {
    super.initState();
    getInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.sideworkBlue,
        centerTitle: true,
        leading: Container(),
        title: const Text(
          'History',
          style: TextStyle(
            color: Constants.lightTextColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: ListView.separated(
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            return Material(
              elevation: 8,
              child: GestureDetector(
                onTap: () {},
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
                    'Charge amount: \$${allBookingsHistory[index].data()['totalPrice']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Constants.sideworkGreen,
                    ),
                  ),
                  subtitle: Text(
                    'Handyman: ${allBookingsHistory[index].data()['handymanFirstName']} ${allBookingsHistory[index].data()['handymanLastName']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Constants.darkTextColor,
                    ),
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Constants.sideworkButtonOrange,
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      addProblem(
                          allBookingsHistory[index].id,
                          allBookingsHistory[index].data()['clientEmail'],
                          allBookingsHistory[index].data()['handymanEmail']);
                    },
                    child: const Text('Report Problem'),
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return const SizedBox(
              height: 4,
            );
          },
          itemCount: allBookingsHistory.length,
        ),
      ),
      bottomNavigationBar: const BottomNavbar(
        currentIndex: 3,
      ),
    );
  }

  Future<void> getInitialData() async {
    try {
      FirebaseFirestore.instance
          .collection('bookings')
          .where('bookingIds',
              arrayContains: FirebaseAuth.instance.currentUser!.email)
          .get()
          .then((snapshot) {
        setState(() {
          allBookingsHistory = snapshot.docs;
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

  Future<void> addProblem(
      String bookingId, String clientEmail, String handymanEmail) async {
    try {
      FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({"problems": true}).then((bookingVal) {
        FirebaseFirestore.instance.collection('tickets').doc().set(
          {
            "bookingId": bookingId,
            "reportedBy": FirebaseAuth.instance.currentUser!.email,
            "otherPerson":
                FirebaseAuth.instance.currentUser!.email == clientEmail
                    ? handymanEmail
                    : clientEmail,
          },
          SetOptions(merge: true),
        ).then((ticketsVal) {
          Fluttertoast.showToast(
            msg: "Booking reported. Wait for an admin to contact you.",
            backgroundColor: Constants.sideworkBlue,
            textColor: Constants.lightTextColor,
          );
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
