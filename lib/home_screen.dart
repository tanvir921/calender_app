import 'dart:convert';
import 'package:calender_app/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  DateTime currentDate = DateTime.now();
  Map<String, dynamic> data = {};
  int selectedYear = DateTime.now().year;
  String selectedCategory = 'A';

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

  List<int> years =
      List.generate(10, (index) => DateTime.now().year - 5 + index);

  @override
  void initState() {
    super.initState();
    _loadSettingsAndCalendar();
  }

  Future<void> _loadSettingsAndCalendar() async {
    await Constants
        .loadMorningShiftColor(); // Load the saved morning shift color
    await Constants.loadNightShiftColor(); // Load the saved night shift color
    await Constants.loadShowHolidays();
    loadCalendar(selectedCategory, selectedYear);
  }

  void loadCalendar(String category, int year) async {
    final res = await fetchCalendarData(category, year);
    setState(() {
      data = res;
      data['category'] = category; // Set the category here
    });
  }

  Future<Map<String, dynamic>> fetchCalendarData(
      String category, int year) async {
    final response = await http.get(Uri.parse(
        'https://mewshift.com/api/calendar?category=$category&year=$year'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load calendar data');
    }
  }

  void previousMonth() {
    setState(() {
      if (currentDate.month == 1) {
        // If current month is January, move to December of the previous year
        currentDate = DateTime(currentDate.year - 1, 12);
      } else {
        // Move to the previous month of the current year
        currentDate = DateTime(currentDate.year, currentDate.month - 1);
      }
      loadCalendar(selectedCategory, currentDate.year);
    });
  }

  void nextMonth() {
    setState(() {
      if (currentDate.month == 12) {
        // If current month is December, move to January of the next year
        currentDate = DateTime(currentDate.year + 1, 1);
      } else {
        // Move to the next month of the current year
        currentDate = DateTime(currentDate.year, currentDate.month + 1);
      }
      loadCalendar(selectedCategory, currentDate.year);
    });
  }

  void jumpToDate(int year, int month) {
    setState(() {
      currentDate = DateTime(year, month);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Add this line
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mewshift'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: ['A', 'B', 'C', 'D'].map((category) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = category;
                        loadCalendar(selectedCategory, selectedYear);
                      });
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
              const SizedBox(height: 20),
              DropdownButton<int>(
                value: selectedYear,
                items: years.map((year) {
                  return DropdownMenuItem<int>(
                    value: year,
                    child: Text(year.toString()),
                  );
                }).toList(),
                onChanged: (int? newYear) {
                  if (newYear != null) {
                    setState(() {
                      selectedYear = newYear;
                      currentDate = DateTime(selectedYear, currentDate.month);
                      loadCalendar(selectedCategory, selectedYear);
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 30),
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
                margin: const EdgeInsets.only(left: 5, right: 5),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(
                      'https://3c5239fcccdc41677a03-1135555c8dfc8b32dc5b4bc9765d8ae5.ssl.cf1.rackcdn.com/22-11-22-BANS-advertising-banner-1025x325-riot.jpg',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  List<TableRow> generateCalendar() {
    DateTime currentDate = this.currentDate;
    
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
              margin: const EdgeInsets.all(2),
              height: 40,
              width: 40,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.star,
                    color: Colors.yellow,
                    size: 15,
                  ),
                  Text(
                    date.toString(),
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          } else if (shift == 'Morning') {
            cellWidget = Container(
              margin: const EdgeInsets.all(2),
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
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          } else if (shift == 'Night') {
            cellWidget = Container(
              margin: const EdgeInsets.all(2),
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
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          } else {
            cellWidget = Container(
              margin: const EdgeInsets.all(2),
              height: 40,
              width: 40,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 15), // Empty space to align date
                  Text(
                    date.toString(),
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }

          cells.add(Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: currentDate.day == date
                    ? Colors.red
                    : Colors.grey,
                width: 2,
              ),
            ),
            child: Center(child: cellWidget),
          ));
          date++;
        }
      }
      rows.add(TableRow(children: cells));
    }
    return rows;
  }
}
