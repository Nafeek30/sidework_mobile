import 'package:flutter/material.dart';
import 'dart:ui';

/// This class creates a reusable width and height based on the
/// window size of the device.
class Adapt {
  static MediaQueryData queryData = MediaQueryData.fromWindow(window);
  static Size screenSize = queryData.size;
  static double width = screenSize.width;
  static double height = screenSize.height;

  /// This method takes in a value: [percent] and converts it into
  /// a percentage of the screen based on the screen's width.
  /// Returns double width (in percentage of the screen width)
  double widthPercent(percent) {
    double result = (percent * screenSize.width) / 100;
    return result;
  }

  /// This method takes in a value: [percent] and converts it into
  /// a percentage of the screen based on the screen's height.
  /// Returns double height (in percentage of the screen height)
  double heightPercent(percent) {
    double result = (percent * screenSize.height) / 100;
    return result;
  }
}
