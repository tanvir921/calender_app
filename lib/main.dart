import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

void main() {
  runApp(CalendarApp());
}

class CalendarApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendar',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: CalendarScreen(),
    );
  }
}

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime currentDate = DateTime.now();
  Map<String, dynamic> data = {};

  List<String> months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];

  List<String> days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

  @override
  void initState() {
    super.initState();
    loadCalendar('A');
  }

  void loadCalendar(String category) async {
    final res = await fetchCalendarData(category);
    setState(() {
      data = res;
    });
  }

 Future<Map<String, dynamic>> fetchCalendarData(String category) async {
  final response = await http.get(Uri.parse('https://calendar.sohojbazar.com/api/calendar?category=$category'));
  
  if (response.statusCode == 200) {
    //print(response.body);
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load calendar data');
  }
}

  void previousMonth() {
    setState(() {
      currentDate = DateTime(currentDate.year, currentDate.month - 1);
    });
  }

  void nextMonth() {
    setState(() {
      currentDate = DateTime(currentDate.year, currentDate.month + 1);
    });
  }

  void jumpToDate(int year, int month) {
    setState(() {
      currentDate = DateTime(year, month);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ['A', 'B', 'C', 'D'].map((category) {
                return ElevatedButton(
                  onPressed: () => loadCalendar(category),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: data['category'] == category ? Colors.red : Colors.green,
                  ),
                  child: Text(category),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Text(
              "${months[currentDate.month - 1]} ${currentDate.year}",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left),
                  onPressed: previousMonth,
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right),
                  onPressed: nextMonth,
                ),
              ],
            ),
            Table(
              children: [
                TableRow(
                  children: days.map((day) => Center(child: Text(day))).toList(),
                ),
                ...generateCalendar(),
              ],
            ),
            SizedBox(height: 20),
            DropdownButton<int>(
              value: currentDate.month,
              items: List.generate(12, (index) {
                return DropdownMenuItem(
                  value: index + 1,
                  child: Text(months[index]),
                );
              }),
              onChanged: (month) {
                if (month != null) {
                  jumpToDate(currentDate.year, month);
                }
              },
            ),
            DropdownButton<int>(
              value: currentDate.year,
              items: List.generate(10, (index) {
                return DropdownMenuItem(
                  value: DateTime.now().year + index,
                  child: Text((DateTime.now().year + index).toString()),
                );
              }),
              onChanged: (year) {
                if (year != null) {
                  jumpToDate(year, currentDate.month);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

 List<TableRow> generateCalendar() {
  List<TableRow> rows = [];
  int daysInMonth = DateTime(currentDate.year, currentDate.month + 1, 0).day;
  int firstDay = DateTime(currentDate.year, currentDate.month, 1).weekday % 7; // Adjusting firstDay calculation

  int date = 1;
  for (int i = 0; i < 6; i++) {
    List<Widget> cells = [];
    for (int j = 0; j < 7; j++) {
      if (i == 0 && j < firstDay) {
        cells.add(Container()); // Empty cell
      } else if (date > daysInMonth) {
        cells.add(Container()); // Empty cell
      } else {
        String shift = '';
        bool isHoliday = false;
        if (data.containsKey(months[currentDate.month - 1]) && data[months[currentDate.month - 1]].containsKey(date.toString())) {
          shift = data[months[currentDate.month - 1]][date.toString()]['shift'];
          isHoliday = data[months[currentDate.month - 1]][date.toString()]['is_holiday'];
        }

        Widget cellWidget;
        if (isHoliday) {
          cellWidget = Icon(Icons.local_hospital, color: Colors.red); // Holiday indicator
        } else if (shift == 'Morning') {
          cellWidget = Icon(Icons.wb_sunny, color: Colors.orange); // Morning shift icon
        } else if (shift == 'Night') {
          cellWidget = Icon(Icons.nights_stay, color: Colors.blue); // Night shift icon
        } else {
          cellWidget = Text(date.toString()); // Regular date
        }

        cells.add(
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: cellWidget,
            ),
          ),
        );
        date++;
      }
    }
    rows.add(TableRow(children: cells));
  }
  return rows;
}




}
