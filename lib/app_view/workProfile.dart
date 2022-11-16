import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sidework_mobile/controller/firebaseController.dart';
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
  String? selectedValue;
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
                  maxLines: 1,
                  controller: firstNameController,
                  hintTitle: 'First Name',
                ),
                CustomFormTextFields(
                  maxLines: 1,
                  controller: lastNameController,
                  hintTitle: 'Last Name',
                ),
                CustomFormTextFields(
                  maxLines: 1,
                  controller: cityController,
                  hintTitle: 'City',
                ),
                CustomFormTextFields(
                  maxLines: 1,
                  controller: stateController,
                  hintTitle: 'State',
                ),
                CustomFormTextFields(
                  maxLines: 1,
                  controller: zipController,
                  hintTitle: 'Zip code',
                ),
                CustomFormTextFields(
                  maxLines: 1,
                  controller: phoneController,
                  hintTitle: 'Phone number',
                ),
                CustomFormTextFields(
                  maxLines: 1,
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

  getInitialData() async {
    FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((user) {
      setState(() {
        firstNameController.text = user.data()?['firstName'] ?? '';
        lastNameController.text = user.data()?['lastName'] ?? '';
        cityController.text = user.data()?['city'] ?? '';
        stateController.text = user.data()?['state'] ?? '';
        zipController.text = user.data()?['zip'] ?? '';
        phoneController.text = user.data()?['phoneNumber'] ?? '';
        hourlyRateController.text = user.data()?['hourlyRate'] ?? '';
        tagsController.text = user.data()?['tags'] ?? '';
        selectedValue = user.data()?['tags'];
        finishLoading = true;
      });
    });
  }
}
