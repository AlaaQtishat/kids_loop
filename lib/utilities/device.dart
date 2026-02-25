import 'package:flutter/material.dart';

class Device {
  static final screenHeight = (BuildContext context) =>
      MediaQuery.of(context).size.height;
  static final ScreenWidth = (BuildContext context) =>
      MediaQuery.of(context).size.width;
}
