import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_emoji/flutter_emoji.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Calendar App'),
        ),
        body: FutureBuilder<CalendarData>(
          future:
              fetchCalendarData('A', 2024), // Replace 'A' with desired category
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return CalendarScreen(calendarData: snapshot.data!);
            }
          },
        ),
      ),
    );
  }
}

class CalendarScreen extends StatefulWidget {
  final CalendarData calendarData;

  const CalendarScreen({Key? key, required this.calendarData})
      : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final ValueNotifier<DateTime> _focusedDay =
      ValueNotifier(DateTime.now());
  late final PageController _pageController =
      PageController(initialPage: DateTime.now().year - 2024);

  @override
  Widget build(BuildContext context) {
    final Emoji emoji = Emoji('gjg', 'nk');

    return PageView.builder(
      controller: _pageController,
      itemCount:
          DateTime.now().year - 2023, // Adjust based on your desired year range
      itemBuilder: (context, index) {
        final year = 2024 + index;
        final calendarData = widget.calendarData.data[year.toString()];

        return TableCalendar(
          focusedDay: _focusedDay.value,
          firstDay: DateTime(year),
          lastDay: DateTime(year + 1),
          onDaySelected: (selectedDay, focusedDay) {
            _focusedDay.value = focusedDay;
          },
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            weekendDecoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
            ),
            holidayDecoration: BoxDecoration(
              color: Colors.red,
            ),
            defaultDecoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
            ),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: TextStyle(color: Colors.grey),
            weekendStyle: TextStyle(color: Colors.grey),
          ),
          headerStyle: HeaderStyle(
            titleTextStyle: TextStyle(fontSize: 18),
            formatButtonVisible: false,
          ),
          eventLoader: (day) {
            final shift = calendarData[day.day.toString()]['shift'];
            final isHoliday = calendarData[day.day.toString()]['is_holiday'];

            if (isHoliday) {
              return ['Holiday'];
            } else if (shift == 'Morning') {
              return ['Morning ${'sun'}'];
            } else if (shift == 'Night') {
              return ['Night ${'moon'}'];
            } else {
              return [];
            }
          },
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              return Center(
                child: Text(day.day.toString()),
              );
            },
            markerBuilder: (context, day, events) {
              if (events.isNotEmpty) {
                return Positioned(
                  right: 1,
                  top: 1,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          (events[0] == 'Morning') ? Colors.blue : Colors.grey,
                    ),
                  ),
                );
              } else {
                return null;
              }
            },
          ),
        );
      },
    );
  }
}

class CalendarData {
  final String category;
  final int year;
  final Map<String, dynamic> data;

  CalendarData(
      {required this.category, required this.year, required this.data});

  factory CalendarData.fromJson(Map<String, dynamic> json) {
    return CalendarData(
      category: json['category'],
      year: json['year'],
      data: json['data'],
    );
  }
}

Future<CalendarData> fetchCalendarData(String category, int year) async {
  final response = await http.get(Uri.parse(
      'https://mewshift.com/api/calendar?category=$category&year=$year'));

  if (response.statusCode == 200) {
    return CalendarData.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load data');
  }
}




// import 'package:calender_app/home_screen.dart';
// import 'package:calender_app/settings_screen.dart';
// import 'package:calender_app/webview_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:calender_app/firebase_options.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
//   await flutterLocalNotificationsPlugin
//       .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin>()
//       ?.createNotificationChannel(channel);

//   await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
//     alert: true,
//     badge: true,
//     sound: true,
//   );

//   SystemChrome.setPreferredOrientations([
//     DeviceOrientation.portraitUp,
//     DeviceOrientation.portraitDown,
//   ]);
//   runApp( MyApp());
// }

// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // If you're going to use other Firebase services in the background, such as Firestore,
//   // make sure you call `initializeApp` before using other Firebase services.
//   await Firebase.initializeApp();
//   print('Handling a background message ${message.messageId}');
// }
// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

//     const AndroidNotificationChannel channel = AndroidNotificationChannel(
//   'high_importance_channel', // id
//   'High Importance Notifications', // title

//   importance: Importance.high,
// );

// class MyApp extends StatefulWidget {
//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {

  

//   void initState() {
//     super.initState();
//     var initialzationSettingsAndroid =
//         const AndroidInitializationSettings('@mipmap/ic_launcher');
//     var initializationSettings =
//         InitializationSettings(android: initialzationSettingsAndroid);
//     flutterLocalNotificationsPlugin.initialize(initializationSettings);

//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       RemoteNotification? notification = message.notification;
//       AndroidNotification? android = message.notification!.android;
//       if (notification != null && android != null) {
//         flutterLocalNotificationsPlugin.show(
//             notification.hashCode,
//             notification.title,
//             notification.body,
//             NotificationDetails(
//               android: AndroidNotificationDetails(
//                 channel.id,
//                 channel.name,
//                 color: Colors.blue,
//                 // TODO add a proper drawable resource to android, for now using
//                 //      one that already exists in example app.
//                 icon: "@mipmap/ic_launcher",
//               ),
//             ));
//       }
//     });

//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       RemoteNotification? notification = message.notification;
//       AndroidNotification? android = message.notification?.android;
//       if (notification != null && android != null) {
//         showDialog(
//             // context: context,
//             builder: (_) {
//               return AlertDialog(
//                 title: Text(notification.title ?? ""),
//                 content: SingleChildScrollView(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [Text(notification.body ?? "")],
//                   ),
//                 ),
//               );
//             },
//             context: context);
//       }
//     });

//     getToken();

    
//   }

//   late String token;
//   getToken() async {
//     token = (await FirebaseMessaging.instance.getToken())!;
//   }



//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.green,
//       ),
//       home: MainScreen(),
//     );
//   }
// }

// class MainScreen extends StatefulWidget {
//   @override
//   _MainScreenState createState() => _MainScreenState();
// }

// class _MainScreenState extends State<MainScreen> {
//   int _currentIndex = 0;
//   final List<Widget> _screens = [
//     HomeScreen(),
//     const WebviewScreen(
//       url: 'https://workflow.mew.gov.kw',
//     ),
//     const WebviewScreen(
//       url: 'https://procurement.mew.gov.kw/Account/Login',
//     ),
//     const WebviewScreen(
//       url: 'https://portal.csc.gov.kw/webcenter/portal/CSCPortal',
//     ),
//     SettingsScreen(),
//   ];

//   void _onTabTapped(int index) {
//     setState(() {
//       _currentIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _screens[_currentIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         unselectedItemColor: Colors.black,
//         unselectedLabelStyle: const TextStyle(color: Colors.blue),
//         selectedItemColor: Colors.blue,
//         selectedLabelStyle: const TextStyle(color: Colors.blue),
//         showSelectedLabels: true,
//         showUnselectedLabels: true,
//         onTap: _onTabTapped,
//         currentIndex: _currentIndex,
//         items: [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'الصفحة الرئيسية',
//           ),
//           BottomNavigationBarItem(
//             icon: Image.asset(
//               'assets/images/bg.png',
//               height: 25,
//             ),
//             label: 'المراسلات',
//           ),
//           BottomNavigationBarItem(
//             icon: Image.asset(
//               'assets/images/bg.png',
//               height: 25,
//             ),
//             label: 'الشراء الالي',
//           ),
//           BottomNavigationBarItem(
//             icon: Image.asset(
//               'assets/images/3.png',
//               height: 25,
//             ),
//             label: 'ديوان الخدمه المدنيه',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.settings),
//             label: 'الاعدادات',
//           ),
//         ],
//       ),
//     );
//   }
// }
