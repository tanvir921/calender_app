import 'package:calender_app/calender_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'calendar_provider.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Custom Calendar 2024'),
      ),
      body: Consumer<CalendarProvider>(
        builder: (context, provider, child) {
          if (provider.calender == null) {
            Provider.of<CalendarProvider>(context, listen: false)
                .getCalendarData('A');
          }
          return Column(
            children: [
              TableCalendar(
                firstDay: DateTime(2024, 1, 1),
                lastDay: DateTime(2024, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    Calender? cal = provider.calender;
                    if (cal != null) {
                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: cal.isHoliday??false
                              ? Colors.red.withOpacity(0.5)
                              : null,
                        ),
                        child: Center(
                          child: Icon(
                            cal.shift == Shift.MORNING
                                ? Icons.wb_sunny
                                : cal.shift == Shift.NIGHT
                                    ? Icons.nights_stay
                                    : null,
                            color: cal.isHoliday??false ? Colors.white : Colors.black,
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                  selectedBuilder: (context, day, focusedDay) {
                    Calender? cal = provider.calender;
                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                      child: Center(
                        child: Icon(
                          cal != null
                              ? (cal.shift == Shift.MORNING
                                  ? Icons.wb_sunny
                                  : cal.shift == Shift.NIGHT
                                      ? Icons.nights_stay
                                      : null)
                              : null,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8.0),
              _selectedDay != null
                  ? Column(
                      children: [
                        Text('Selected Date: ${_selectedDay?.toLocal()}'),
                      ],
                    )
                  : Text('No day selected'),
            ],
          );
        },
      ),
    );
  }
}
