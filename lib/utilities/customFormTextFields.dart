import 'package:flutter/material.dart';
import 'package:sidework_mobile/utilities/constants.dart';

class CustomFormTextFields extends StatefulWidget {
  final TextEditingController controller;
  final String hintTitle;
  const CustomFormTextFields(
      {Key? key, required this.controller, required this.hintTitle})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CustomFormTextFieldsState();
  }
}

class CustomFormTextFieldsState extends State<CustomFormTextFields> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Constants.lightTextColor,
          border: Border.all(color: Constants.darkTextColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: TextField(
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: widget.hintTitle,
            ),
            controller: widget.controller,
          ),
        ),
      ),
    );
  }
}
