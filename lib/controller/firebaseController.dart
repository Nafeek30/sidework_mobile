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
