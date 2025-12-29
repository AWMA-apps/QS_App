import 'dart:ui';

import 'package:flutter/material.dart';

class Util {
  String dbName(String url){
    return Uri.parse(url).host.split(".").first;
  }

  Color getAvatarColor(String name) {
    final List<Color> colors = [
      Colors.red, Colors.blue, Colors.green,
      Colors.orange, Colors.purple, Colors.teal,
      Colors.pink, Colors.indigo,
    ];

    // Use the absolute value of the name's hashcode to pick an index
    final int index = ("${name[0]}$name").hashCode.abs() % colors.length;
    return colors[index];
  }
}