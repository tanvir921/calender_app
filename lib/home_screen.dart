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

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  DateTime currentDate = DateTime.now();
  Map<String, dynamic> data = {};
  int selectedYear = DateTime.now().year;
  String selectedCategory = 'A';
  Map<String, dynamic> adData = {};

  List<String> months = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];

  List<String> days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

  List<int> years = List.generate(10, (index) => DateTime.now().year - 5 + index);

  @override
  void initState() {
    super.initState();
    _loadSettingsAndCalendar();
  }

  Future<void> _loadSettingsAndCalendar() async {
    await Constants.loadMorningShiftColor();
    await Constants.loadNightShiftColor();
    await Constants.loadShowHolidays();
    loadCalendar(selectedCategory, selectedYear);
  }

  Future<void> loadCalendar(String category, int year) async {
    final res = await fetchCalendarData(category, year);
    setState(() {
      data = res['data'];
      data['category'] = category;
      adData = res['ads'];
    });
  }

  Future<Map<String, dynamic>> fetchCalendarData(String category, int year) async {
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
      currentDate = currentDate.month == 1
          ? DateTime(currentDate.year - 1, 12)
          : DateTime(currentDate.year, currentDate.month - 1);
      loadCalendar(selectedCategory, currentDate.year);
    });
  }

  void nextMonth() {
    setState(() {
      currentDate = currentDate.month == 12
          ? DateTime(currentDate.year + 1, 1)
          : DateTime(currentDate.year, currentDate.month + 1);
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

  void showDatePopup(String date, String month, String year) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Selected Date"),
          content: Text("$month $date, $year"),
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
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mewshifts'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (builder) => AboutScreen())),
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
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (adData.isNotEmpty) buildAdBanner(),
                buildCategorySelector(),
                const SizedBox(height: 20),
                buildYearDropdown(),
                const SizedBox(height: 20),
                buildMonthNavigator(),
                const SizedBox(height: 30),
                buildCalendarTable(),
                const SizedBox(height: 20),
                if (adData.isNotEmpty) buildAdBanner(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildAdBanner() {
    return GestureDetector(
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
    );
  }

  Widget buildCategorySelector() {
    return Row(
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
              color: data['category'] == category ? Colors.blue : Colors.white,
              border: Border.all(
                color: data['category'] == category ? Colors.blue : Colors.black,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: Text(
                category,
                style: TextStyle(
                  color: data['category'] == category ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget buildYearDropdown() {
    return DropdownButton<int>(
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
    );
  }

  Widget buildMonthNavigator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: previousMonth,
        ),
        Text(
          "${months[currentDate.month - 1]} ${currentDate.year}",
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: nextMonth,
        ),
      ],
    );
  }

  Widget buildCalendarTable() {
    return Table(
      children: [
        TableRow(
          children: days.map((day) => Center(child: Text(day))).toList(),
        ),
        ...generateCalendar(),
      ],
    );
  }

  List<TableRow> generateCalendar() {
    DateTime today = DateTime.now();
    int daysInMonth = DateTime(currentDate.year, currentDate.month + 1, 0).day;
    int firstDay = DateTime(currentDate.year, currentDate.month, 1).weekday % 7;

    List<TableRow> rows = [];
    int date = 1;
    for (int i = 0; i < 6; i++) {
      List<Widget> cells = [];
      for (int j = 0; j < 7; j++) {
        if (i == 0 && j < firstDay || date > daysInMonth) {
          cells.add(Container());
        } else {
          cells.add(buildDateCell(date, today));
          date++;
        }
      }
      rows.add(TableRow(children: cells));
    }
    return rows;
  }

  Widget buildDateCell(int date, DateTime today) {
    String shift = '';
    bool isHoliday = false;
    if (data.containsKey(months[currentDate.month - 1]) &&
        data[months[currentDate.month - 1]].containsKey(date.toString())) {
      shift = data[months[currentDate.month - 1]][date.toString()]['shift'];
      isHoliday = data[months[currentDate.month - 1]][date.toString()]['is_holiday'];
    }

    return GestureDetector(
      onTap: () {
        showDatePopup(date.toString(), months[currentDate.month - 1], currentDate.year.toString());
      },
      child: Container(
        margin: const EdgeInsets.all(2),
        height: 80,
        width: 60,
        decoration: BoxDecoration(
          border: Border.all(
            color: (currentDate.year == today.year && currentDate.month == today.month && date == today.day)
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
    );
  }

  @override
  bool get wantKeepAlive => true;
}
