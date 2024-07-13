import 'dart:convert';
import 'package:calender_app/about_screen.dart';
import 'package:calender_app/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  void initState() {
    super.initState();
    _loadSettingsAndCalendar();
    _loadNotesFromSharedPreferences();
  }

  Future<void> _loadSettingsAndCalendar() async {
    await Constants.loadMorningShiftColor();
    await Constants.loadNightShiftColor();
    await Constants.loadShowHolidays();
    loadCalendar(selectedCategory, selectedYear);
  }

  void loadCalendar(String category, int year) async {
    final res = await fetchCalendarData(category, year);
    setState(() {
      data = res;
      data['category'] = category;
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
      if (currentDate.month > 1) {
        currentDate = DateTime(currentDate.year, currentDate.month - 1);
      }
      loadCalendar(selectedCategory, currentDate.year);
    });
  }

  void nextMonth() {
    setState(() {
      if (currentDate.month < 12) {
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

  Map<String, List<String>> notes = {};


  final _prefs = SharedPreferences.getInstance();

Future<void> _saveNotesToSharedPreferences() async {
  final prefs = await _prefs;
  prefs.setString('notes', jsonEncode(notes));
}

Future<void> _loadNotesFromSharedPreferences() async {
  final prefs = await _prefs;
  final notesString = prefs.getString('notes');
  if (notesString != null) {
    notes = jsonDecode(notesString).cast<String, List<String>>();
  }
}


  void _showNoteDialog(BuildContext context, String date) {
  List<String> existingNotes = notes[date] ?? [];

  TextEditingController noteController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Notes for $date'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Display existing notes
            for (String note in existingNotes)
              Text(note),
            TextField(
              controller: noteController,
              decoration: InputDecoration(hintText: 'Add a note'),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Save'),
            onPressed: () {
              String newNote = noteController.text.trim();
              if (newNote.isNotEmpty) {
                setState(() {
                  notes[date] = (notes[date] ?? [])..add(newNote);
                  // Save notes to SharedPreferences
                  _saveNotesToSharedPreferences();
                });
              }
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
                  items: List<int>.generate(DateTime.now().year - 2024 + 1,
                          (index) => 2024 + index)
                      .where((year) => year <= DateTime.now().year)
                      .map((year) {
                    return DropdownMenuItem<int>(
                      value: year,
                      child: Text(year.toString()),
                    );
                  }).toList(),
                  value: selectedYear,
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
  int firstDay = DateTime(currentDate.year, currentDate.month, 1).weekday % 7;

  int date = 1;
  for (int i = 0; i < 6; i++) {
    List<Widget> cells = [];
    for (int j = 0; j < 7; j++) {
      if (i == 0 && j < firstDay) {
        cells.add(Container());
      } else if (date > daysInMonth) {
        cells.add(Container());
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

        if (shift == 'Morning') {
          cellWidget = Container(
            height: 40,
            width: double.infinity,
            color: Constants.morningShiftColor.withOpacity(0.5),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: (currentDate.year == today.year &&
                          currentDate.month == today.month &&
                          date == today.day)
                      ? Colors.red
                      : Colors.transparent,
                  width: 2,
                ),
                shape: BoxShape.circle,
              ),
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
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isHoliday && Constants.showHolidays
                          ? Colors.red
                          : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (shift == 'Night') {
          cellWidget = Container(
            height: 40,
            width: double.infinity,
            color: Constants.nightShiftColor.withOpacity(0.5),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: (currentDate.year == today.year &&
                          currentDate.month == today.month &&
                          date == today.day)
                      ? Colors.red
                      : Colors.transparent,
                  width: 2,
                ),
                shape: BoxShape.circle,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.nights_stay,
                    color: Colors.white,
                    size: 15,
                  ),
                  Text(
                    date.toString(),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isHoliday && Constants.showHolidays
                          ? Colors.red
                          : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          cellWidget = Container(
            height: 40,
            width: 40,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: (currentDate.year == today.year &&
                          currentDate.month == today.month &&
                          date == today.day)
                      ? Colors.red
                      : Colors.transparent,
                  width: 2,
                ),
                shape: BoxShape.circle,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 15),
                  Text(
                    date.toString(),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isHoliday && Constants.showHolidays
                          ? Colors.red
                          : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        cells.add(
          GestureDetector(
            onTap: () {
        String dateString = '${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${date.toString().padLeft(2, '0')}';
        _showNoteDialog(context, dateString);
      },
            child: Container(
              margin: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Colors.grey,
                  width: 1,
                ),
              ),
              child: Center(child: cellWidget),
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
