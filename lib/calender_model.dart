import 'dart:convert';
import 'package:http/http.dart' as http;

Map<String, List<Map<String, Calender>>> calenderFromJson(String str) => Map.from(json.decode(str)).map((k, v) => MapEntry<String, List<Map<String, Calender>>>(k, List<Map<String, Calender>>.from(v.map((x) => Map.from(x).map((k, v) => MapEntry<String, Calender>(k, Calender.fromJson(v)))))));

String calenderToJson(Map<String, List<Map<String, Calender>>> data) => json.encode(Map.from(data).map((k, v) => MapEntry<String, dynamic>(k, List<dynamic>.from(v.map((x) => Map.from(x).map((k, v) => MapEntry<String, dynamic>(k, v.toJson())))))));

class Calender {
    Shift? shift;
    bool? isHoliday;

    Calender({
        required this.shift,
        required this.isHoliday,
    });

    factory Calender.fromJson(Map<String, dynamic> json) => Calender(
        shift: shiftValues.map[json["shift"]]!,
        isHoliday: json["is_holiday"],
    );

    Map<String, dynamic> toJson() => {
        "shift": shiftValues.reverse[shift],
        "is_holiday": isHoliday,
    };
}

enum Shift {
    EMPTY,
    MORNING,
    NIGHT
}

final shiftValues = EnumValues({
    "": Shift.EMPTY,
    "Morning": Shift.MORNING,
    "Night": Shift.NIGHT
});

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
            reverseMap = map.map((k, v) => MapEntry(v, k));
            return reverseMap;
    }
}
Future<Map<String, List<Map<String, Calender>>>> fetchCalendarData() async {
  final response = await http.get(Uri.parse('https://calendar.sohojbazar.com/api/calendar?category=D'));

  if (response.statusCode == 200) {
    return calenderFromJson(response.body);
  } else {
    throw Exception('Failed to load calendar data');
  }
}