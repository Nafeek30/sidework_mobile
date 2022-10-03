import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sidework_mobile/utilities/constants.dart';
import 'package:sidework_mobile/utilities/customFormTextFields.dart';

class PersonalProfile extends StatefulWidget {
  const PersonalProfile({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PersonalProfileState();
  }
}

class PersonalProfileState extends State<PersonalProfile> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController addressOneController = TextEditingController();
  TextEditingController addressTwoController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController zipController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  bool finishLoading = false;

  @override
  void initState() {
    super.initState();
    getInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return finishLoading
        ? SingleChildScrollView(
            child: Column(
              children: [
                CustomFormTextFields(
                  controller: firstNameController,
                  hintTitle: 'First Name',
                ),
                CustomFormTextFields(
                  controller: lastNameController,
                  hintTitle: 'Last Name',
                ),
                CustomFormTextFields(
                  controller: addressOneController,
                  hintTitle: 'Address line 1',
                ),
                CustomFormTextFields(
                  controller: addressTwoController,
                  hintTitle: 'Address line 2',
                ),
                CustomFormTextFields(
                  controller: cityController,
                  hintTitle: 'City',
                ),
                CustomFormTextFields(
                  controller: stateController,
                  hintTitle: 'State',
                ),
                CustomFormTextFields(
                  controller: zipController,
                  hintTitle: 'Zip code',
                ),
                CustomFormTextFields(
                  controller: phoneController,
                  hintTitle: 'Phone number',
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Constants.sideworkButtonGreen,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    savePersonalProfile(
                      firstNameController.text,
                      lastNameController.text,
                      addressOneController.text,
                      addressTwoController.text,
                      cityController.text,
                      stateController.text,
                      zipController.text,
                      phoneController.text,
                      FirebaseAuth.instance.currentUser!.email.toString(),
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }

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

  getInitialData() async {
    FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((user) {
      setState(() {
        firstNameController.text = user.data()!['firstName'];
        lastNameController.text = user.data()!['lastName'];
        addressOneController.text = user.data()!['addressOne'];
        addressTwoController.text = user.data()!['addressTwo'];
        cityController.text = user.data()!['city'];
        stateController.text = user.data()!['state'];
        zipController.text = user.data()!['zip'];
        phoneController.text = user.data()!['phoneNumber'];
        finishLoading = true;
      });
    });
  }
}
