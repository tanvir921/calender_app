import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class Constants {
  static const String appName = "Calendar App";
  static const String morningShiftColorKey = "morningShiftColor";
  static const String nightShiftColorKey = "nightShiftColor";
  static Color morningShiftColor = Color(0xFF2697FF);
  static  Color nightShiftColor = Color(0xff484b5c);
   static bool showHolidays = false;

  static List<Color> predefinedColors = [
    Color(0xff4caf50),
    Color(0xff2697ff),
    Color(0xfff44336),
    Color(0xff484b5c),
  ];

  static Future<void> loadMorningShiftColor() async {
    final prefs = await SharedPreferences.getInstance();
    int? colorValue = prefs.getInt(morningShiftColorKey);
    if (colorValue != null) {
      Color loadedColor = Color(colorValue);
      if (predefinedColors.contains(loadedColor)) {
        morningShiftColor = loadedColor;
      } else {
        morningShiftColor = Color(0xFF2697FF);  // Reset to default if not in predefined list
      }
    } else {
      morningShiftColor = Color(0xFF2697FF);  // Set to default if no color saved
    }
  }

  static Future<void> saveMorningShiftColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(morningShiftColorKey, color.value);
  }


  static Future<void> loadNightShiftColor() async {
    final prefs = await SharedPreferences.getInstance();
    int? colorValue = prefs.getInt(nightShiftColorKey);
    if (colorValue != null) {
      Color loadedColor = Color(colorValue);
      if (predefinedColors.contains(loadedColor)) {
        nightShiftColor = loadedColor;
      } else {
        nightShiftColor = Color(0xff484b5c);  // Reset to default if not in predefined list
      }
    } else {
      nightShiftColor = Color(0xff484b5c);  // Set to default if no color saved
    }
  }

  static Future<void> saveNightShiftColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(nightShiftColorKey, color.value);
  }

  static Future<void> loadShowHolidays() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    showHolidays = prefs.getBool('showHolidays') ?? false;
  }

  static Future<void> saveShowHolidays(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showHolidays', value);
    showHolidays = value;
  }

  
}
