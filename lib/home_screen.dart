import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:calender_app/constants.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    _loadSettingsAndCalendar();
  }

  Future<void> _loadSettingsAndCalendar() async {
    await Constants
        .loadMorningShiftColor(); // Load the saved morning shift color
    await Constants.loadNightShiftColor(); // Load the saved night shift color
    loadCalendar('A');
  }

  void loadCalendar(String category) async {
    final res = await fetchCalendarData(category);
    setState(() {
      data = res;
      data['category'] = category; // Set the category here
    });
  }

  Future<Map<String, dynamic>> fetchCalendarData(String category) async {
    final response = await http.get(Uri.parse(
        'https://calendar.sohojbazar.com/api/calendar?category=$category'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load calendar data');
    }
  }

  void previousMonth() {
    setState(() {
      if (currentDate.year == 2024 && currentDate.month == 1) {
        // Stay in January 2024
        currentDate = DateTime(2024, 1);
      } else {
        // Move to the previous month
        currentDate = DateTime(currentDate.year, currentDate.month - 1);
      }
    });
  }

  void nextMonth() {
    setState(() {
      if (currentDate.year == 2024 && currentDate.month == 12) {
        // Stay in December 2024
        currentDate = DateTime(2024, 12);
      } else {
        // Move to the next month
        currentDate = DateTime(currentDate.year, currentDate.month + 1);
      }
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
        title: const Text('Mewshift'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ['A', 'B', 'C', 'D'].map((category) {
                return GestureDetector(
                  onTap: () {
                    loadCalendar(category);
                  },
                  child: Container(
                    height: 30,
                    width: 60,
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: data['category'] == category
                          ? Colors.purple
                          : Colors.white,
                      border: Border.all(
                        color: data['category'] == category
                            ? Colors.purple
                            : Colors.black,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: Text(
                        category,
                        style: TextStyle(
                          color: data['category'] == category
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: previousMonth,
                ),
                Text(
                  "${months[currentDate.month - 1]} ${currentDate.year}",
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: nextMonth,
                ),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            Table(
              children: [
                TableRow(
                  children:
                      days.map((day) => Center(child: Text(day))).toList(),
                ),
                ...generateCalendar(),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 130,
              margin: EdgeInsets.only(left: 5, right: 5),
              decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(
                          'https://3c5239fcccdc41677a03-1135555c8dfc8b32dc5b4bc9765d8ae5.ssl.cf1.rackcdn.com/22-11-22-BANS-advertising-banner-1025x325-riot.jpg'))),
            )
          ],
        ),
      ),
    );
  }

  List<TableRow> generateCalendar() {
    List<TableRow> rows = [];
    int daysInMonth = DateTime(currentDate.year, currentDate.month + 1, 0).day;
    int firstDay = DateTime(currentDate.year, currentDate.month, 1).weekday %
        7; // Adjusting firstDay calculation

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
          if (data.containsKey(months[currentDate.month - 1]) &&
              data[months[currentDate.month - 1]]
                  .containsKey(date.toString())) {
            shift =
                data[months[currentDate.month - 1]][date.toString()]['shift'];
            isHoliday = data[months[currentDate.month - 1]][date.toString()]
                ['is_holiday'];
          }

          Widget cellWidget;
          if (isHoliday) {
            cellWidget = Container(
              margin: EdgeInsets.all(2),
              height: 40,
              width: 40,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.yellow,
                    size: 15,
                  ),
                  Text(
                    date.toString(),
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            );
          } else if (shift == 'Morning') {
            cellWidget = Container(
              margin: EdgeInsets.all(2),
              height: 40,
              width: double.infinity,
              color: Constants.morningShiftColor.withOpacity(0.5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.wb_sunny,
                    color: Colors.orange,
                    size: 15,
                  ),
                  Text(
                    date.toString(),
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            );
          } else if (shift == 'Night') {
            cellWidget = Container(
              margin: EdgeInsets.all(2),
              height: 40,
              width: double.infinity,
              color: Constants.nightShiftColor.withOpacity(0.5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.nights_stay,
                    color: Colors.blue,
                    size: 15,
                  ),
                  Text(
                    date.toString(),
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            );
          } else {
            cellWidget = Container(
              margin: EdgeInsets.all(2),
              height: 40,
              width: 40,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 20,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                    ],
                  ),
                  Text(
                    date.toString(),
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            );
          }

          cells.add(Container(
            margin: EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: isHoliday&& ? Colors.red : Colors.grey,
                width: isHoliday ? 2 : 2,
              ),

              //borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: cellWidget,
            ),
          ));
          date++;
        }
      }
      rows.add(TableRow(children: cells));
    }
    return rows;
  }
}
