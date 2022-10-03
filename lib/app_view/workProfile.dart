import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sidework_mobile/utilities/constants.dart';
import 'package:sidework_mobile/utilities/customFormTextFields.dart';

class WorkProfile extends StatefulWidget {
  const WorkProfile({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return WorkProfileState();
  }
}

class WorkProfileState extends State<WorkProfile> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController zipController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController hourlyRateController = TextEditingController();
  TextEditingController tagsController = TextEditingController();

  List<String> tags = [
    'Plumber',
    'Mechanic',
    'Mover',
    'Pest Control',
    'Yard Work',
  ];
  String selectedValue = '';
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
                CustomFormTextFields(
                  controller: hourlyRateController,
                  hintTitle: 'Hourly rate',
                ),
                DropdownButton<String>(
                  hint: const Text('Please choose a tag'),
                  value: selectedValue,
                  onChanged: (val) {
                    setState(() {
                      selectedValue = val!;
                      tagsController.text = val;
                    });
                  },
                  items: tags.map((tag) {
                    return DropdownMenuItem<String>(
                      value: tag,
                      child: Text(tag),
                    );
                  }).toList(),
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
                    saveWorkProfile(
                      firstNameController.text,
                      lastNameController.text,
                      cityController.text,
                      stateController.text,
                      zipController.text,
                      phoneController.text,
                      hourlyRateController.text,
                      tagsController.text,
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

  getInitialData() async {
    FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((user) {
      setState(() {
        firstNameController.text = user.data()!['firstName'];
        lastNameController.text = user.data()!['lastName'];
        cityController.text = user.data()!['city'];
        stateController.text = user.data()!['state'];
        zipController.text = user.data()!['zip'];
        phoneController.text = user.data()!['phoneNumber'];
        hourlyRateController.text = user.data()!['hourlyRate'];
        tagsController.text = user.data()!['tags'];
        selectedValue = user.data()!['tags'];
        finishLoading = true;
      });
    });
  }
}
