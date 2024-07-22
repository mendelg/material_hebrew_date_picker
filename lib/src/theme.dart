import 'package:flutter/material.dart';

class HebrewDatePickerTheme {
  final Color primaryColor;
  final Color onPrimaryColor;
  final Color surfaceColor;
  final Color onSurfaceColor;
  final Color disabledColor;
  final Color selectedColor;
  final Color todayColor;
  final TextStyle headerTextStyle;
  final TextStyle bodyTextStyle;
  final TextStyle weekdayTextStyle;

  const HebrewDatePickerTheme({
    this.primaryColor = Colors.blue,
    this.onPrimaryColor = Colors.white,
    this.surfaceColor = Colors.white,
    this.onSurfaceColor = Colors.black87,
    this.disabledColor = Colors.grey,
    this.selectedColor = Colors.blue,
    this.todayColor = Colors.orange,
    this.headerTextStyle =
        const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    this.bodyTextStyle = const TextStyle(fontSize: 14),
    this.weekdayTextStyle =
        const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
  });
}
