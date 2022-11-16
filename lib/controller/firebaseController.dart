import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sidework_mobile/app_view/homePage.dart';
import 'package:sidework_mobile/utilities/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseController {
  static const USERCOLLECTION = 'users';

  /// Function to sign a user up
  Future signUpUser(TextEditingController email, TextEditingController password,
      BuildContext context) async {
    /// Check if email and password field are empty
    if (email.text == '' || password.text == '' || password.text.length < 6) {
      Fluttertoast.showToast(
        msg: "Email or password is incorrect.",
        backgroundColor: Constants.sideworkBlue,
        textColor: Constants.lightTextColor,
      );
    } else if (!email.text.contains('.') || !email.text.contains('@')) {
      /// Check if email contains '.' AND '@'
      Fluttertoast.showToast(
        msg: "Email address is not valid.",
      );
    } else {
      try {
        /// Create new account and send verification email to the user
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: email.text,
          password: password.text,
        )
            .then((auth) {
          return Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const HomePage(),
            ),
          );
        });
      } catch (e) {
        Fluttertoast.showToast(
          msg: e.toString(),
        );
      }
    }
  }

  /// Function to log in a user
  Future loginUser(TextEditingController email, TextEditingController password,
      BuildContext context) async {
    /// Check if email and password field are empty
    if (email.text == '' || password.text == '' || password.text.length < 6) {
      Fluttertoast.showToast(
        msg: "Email or password is incorrect.",
        backgroundColor: Constants.sideworkBlue,
        textColor: Constants.lightTextColor,
      );
    } else if (!email.text.contains('.') || !email.text.contains('@')) {
      /// Check if email contains '.' AND '@'
      Fluttertoast.showToast(
        msg: "Email address is not valid.",
      );
    } else {
      try {
        /// Log user in
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(
          email: email.text,
          password: password.text,
        )
            .then((auth) {
          return Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const HomePage(),
            ),
          );
        });
      } catch (e) {
        Fluttertoast.showToast(
          msg: e.toString(),
        );
      }
    }
  }
}

/// Function to save personal profile data
savePersonalProfile(
    String firstName,
    String lastName,
    String addressOne,
    String addressTwo,
    String city,
    String state,
    String zip,
    String phoneNumber,
    String email) async {
  var data = {
    "firstName": firstName,
    "lastName": lastName,
    "addressOne": addressOne,
    "addressTwo": addressTwo,
    "city": city,
    "state": state,
    "zip": zip,
    "phoneNumber": phoneNumber,
    "email": email,
    "isAdmin": false,
    "isBanned": false,
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
      Fluttertoast.showToast(
        msg: "Changes saved.",
        backgroundColor: Constants.sideworkBlue,
        textColor: Constants.lightTextColor,
      );
    });
  } catch (e) {
    Fluttertoast.showToast(
      msg: e.toString(),
      backgroundColor: Constants.sideworkBlue,
      textColor: Constants.lightTextColor,
    );
  }
}

/// Function to save work profile data
saveWorkProfile(
    String firstName,
    String lastName,
    String city,
    String state,
    String zip,
    String phoneNumber,
    String hourlyRate,
    String tags,
    String email) async {
  var data = {
    "firstName": firstName,
    "lastName": lastName,
    "city": city,
    "state": state,
    "zip": zip,
    "phoneNumber": phoneNumber,
    "hourlyRate": hourlyRate,
    "tags": tags,
    "email": email,
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
      Fluttertoast.showToast(
        msg: "Changes saved.",
        backgroundColor: Constants.sideworkBlue,
        textColor: Constants.lightTextColor,
      );
    });
  } catch (e) {
    Fluttertoast.showToast(
      msg: e.toString(),
      backgroundColor: Constants.sideworkBlue,
      textColor: Constants.lightTextColor,
    );
  }
}

/// Function to create a new booking
Future<void> saveBooking(
    String description, String handymanEmail, BuildContext context) async {
  try {
    await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: handymanEmail)
        .get()
        .then((querySnapshot) {
      FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((clientUser) {
        var handyman = querySnapshot.docs.first;

        var data = {
          "handymanEmail": handyman.data()['email'],
          "handymanFirstName": handyman.data()['firstName'],
          "handymanLastName": handyman.data()['lastName'],
          "clientEmail": clientUser.data()!['email'],
          "clientFirstName": clientUser.data()!['firstName'],
          "clientLastName": clientUser.data()!['lastName'],
          "clientAddressOne": clientUser.data()!['addressOne'],
          "clientAddressTwo": clientUser.data()!['addressTwo'],
          "clientCity": clientUser.data()!['city'],
          "clientState": clientUser.data()!['state'],
          "clientZip": clientUser.data()!['zip'],
          "clientPhoneNumber": clientUser.data()!['phoneNumber'],
          "handymanPhoneNumber": handyman.data()['phoneNumber'],
          "clientDescription": description,
          "rating": 0.0,
          "totalPrice": 0.0,
          "bookingConfirmed": false,
          "bookingPaid": false,
          "bookingIds": [clientUser.data()!['email'], handyman.data()['email']],
          "problems": false,
          "timestamp": DateTime.now().millisecondsSinceEpoch,
        };
        FirebaseFirestore.instance
            .collection('bookings')
            .doc()
            .set(
              data,
              SetOptions(merge: true),
            )
            .then((value) {
          Fluttertoast.showToast(
            msg: "Booking sent!",
            backgroundColor: Constants.sideworkBlue,
            textColor: Constants.lightTextColor,
          );
          Navigator.pop(context);
        });
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
