import 'dart:convert';

import 'package:calender_app/calender_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CalendarProvider extends ChangeNotifier {
  Calender? _calender;

  Calender? get calender => _calender;

  Future<void> getCalendarData(String cat) async {
    final apiUrl = 'https://calendar.sohojbazar.com/api/calendar?category=D';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        print(response.body);
        final Map<String, dynamic> responseData = json.decode(response.body);
        _calender = Calender.fromJson(responseData);
        notifyListeners();
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      
    }
  }
}
