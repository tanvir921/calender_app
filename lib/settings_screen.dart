import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:calender_app/constants.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool shiftPattern = false;
  bool showHolidays = Constants.showHolidays;
  String language = 'English';

  Color nightShiftColor = Constants.nightShiftColor;
  Color morningShiftColor = Constants.morningShiftColor;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await Constants.loadMorningShiftColor();
    await Constants.loadNightShiftColor();
    await Constants.loadShowHolidays();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      morningShiftColor = Constants.morningShiftColor;
      nightShiftColor = Constants.nightShiftColor;
      showHolidays = Constants.showHolidays;
      language = prefs.getString('language') ?? 'English';
      shiftPattern = prefs.getBool('shiftPattern') ?? false;
    });
  }

  Future<void> _saveLanguage(String lang) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
  }

  Future<void> _saveShiftPattern(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('shiftPattern', value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: <Widget>[
          // ListTile(
          //   title: Text('Language'),
          //   trailing: DropdownButton<String>(
          //     value: language,
          //     onChanged: (String? newValue) {
          //       setState(() {
          //         language = newValue ?? 'English';
          //         _saveLanguage(language);
          //       });
          //     },
          //     items: <String>['English', 'Español', '中文']
          //         .map<DropdownMenuItem<String>>((String value) {
          //       return DropdownMenuItem<String>(
          //         value: value,
          //         child: Text(value),
          //       );
          //     }).toList(),
          //   ),
          // ),
          // SwitchListTile(
          //   title: Text('Shift Pattern'),
          //   value: shiftPattern,
          //   onChanged: (bool value) {
          //     setState(() {
          //       shiftPattern = value;
          //       _saveShiftPattern(value);
          //     });
          //   },
          // ),
          ListTile(
            title: Text('Morning Shift Color'),
            trailing: DropdownButton<Color>(
              value: morningShiftColor,
              onChanged: (Color? newValue) {
                if (newValue != null) {
                  setState(() {
                    morningShiftColor = newValue;
                    Constants.morningShiftColor = newValue;
                    Constants.saveMorningShiftColor(newValue);
                  });
                }
              },
              items: Constants.predefinedColors
                  .map<DropdownMenuItem<Color>>((Color value) {
                return DropdownMenuItem<Color>(
                  value: value,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: value,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          ListTile(
            title: Text('Night Shift Color'),
            trailing: DropdownButton<Color>(
              value: nightShiftColor,
              onChanged: (Color? newValue) {
                if (newValue != null) {
                  setState(() {
                    nightShiftColor = newValue;
                    Constants.nightShiftColor = newValue;
                    Constants.saveNightShiftColor(newValue);
                  });
                }
              },
              items: Constants.predefinedColors
                  .map<DropdownMenuItem<Color>>((Color value) {
                return DropdownMenuItem<Color>(
                  value: value,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: value,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SwitchListTile(
            title: Text('Show Holidays'),
            value: showHolidays,
            onChanged: (bool value) {
              setState(() {
                showHolidays = value;
                Constants.saveShowHolidays(value);
              });
            },
          ),
          // ListTile(
          //   title: Text('Shift Reminder'),
          //   subtitle: Text('Remind me before On Time Alarm'),
          //   trailing: Icon(Icons.keyboard_arrow_right),
          //   onTap: () {
          //     // Navigate to shift reminder settings
          //   },
          // ),
        ],
      ),
    );
  }
}
