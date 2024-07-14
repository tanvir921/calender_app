import 'dart:convert';
import 'package:calender_app/about_screen.dart';
import 'package:calender_app/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

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
  Map<String, dynamic> adData = {};

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
      data = res['data'];
      data['category'] = category; // Set the category here
      adData = res['ads'];
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

  void launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void showDatePopup(String date, String month, String Year,) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Selected Date"),
          content: Text(" $month $date, $Year"),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Add this line
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mewshifts'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (builder) => AboutScreen())),
          )
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage('assets/images/bg.png'),
          fit: BoxFit.cover,
          opacity: 0.3,
        )),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (adData.isNotEmpty)
                  GestureDetector(
                    onTap: () => launchUrl(adData['url']),
                    child: Container(
                      height: 130,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(adData['image']),
                        ),
                      ),
                    ),
                  ),
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
                              ? Colors.blue
                              : Colors.white,
                          border: Border.all(
                            color: data['category'] == category
                                ? Colors.blue
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
                if (adData.isNotEmpty)
                  GestureDetector(
                    onTap: () => launchUrl(adData['url']),
                    child: Container(
                      height: 130,
                      margin: const EdgeInsets.only(left: 5, right: 5),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(adData['image']),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  List<TableRow> generateCalendar() {
    DateTime currentDate = this.currentDate;
    DateTime today = DateTime.now();

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
          // if (isHoliday) {
          //   cellWidget = Container(
          //     margin: const EdgeInsets.all(2),
          //     height: 40,
          //     width: 40,
          //     child: Container(
          //       decoration: BoxDecoration(
          //         border: Border.all(
          //           color: (currentDate.year == today.year &&
          //                   currentDate.month == today.month &&
          //                   date == today.day)
          //               ? Colors.red
          //               : Colors.transparent,
          //           width: 2.0,
          //         ),
          //       ),
          //       child: Center(
          //         child: Text(
          //           date.toString(),
          //           style: TextStyle(
          //             color: Colors.red,
          //           ),
          //         ),
          //       ),
          //     ),
          //   );
          // } else {
          cellWidget = GestureDetector(
            onTap: () {
              showDatePopup(
                date.toString(),
                months[currentDate.month - 1],
                currentDate.year.toString(),
              );
            },
            child: Container(
              margin: const EdgeInsets.all(2),
              height: 80,
              width: 60,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: (currentDate.year == today.year &&
                            currentDate.month == today.month &&
                            date == today.day)
                        ? Colors.red
                        : Colors.transparent,
                    width: 2.0,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(date.toString()),
                    Text(
                      shift,
                      style: TextStyle(
                        color: shift == 'Morning'
                            ? Constants.morningShiftColor
                            : shift == 'Night'
                                ? Constants.nightShiftColor
                                : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
          // }

          cells.add(cellWidget);
          date++;
        }
      }
      rows.add(TableRow(children: cells));
    }

    return rows;
  }
}
