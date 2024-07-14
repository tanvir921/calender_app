


import 'package:calender_app/home_screen.dart';
import 'package:calender_app/settings_screen.dart';
import 'package:calender_app/webview_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:calender_app/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp( MyApp());
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title

  importance: Importance.high,
);

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  

  void initState() {
    super.initState();
    var initialzationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(android: initialzationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification!.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                color: Colors.blue,
                // TODO add a proper drawable resource to android, for now using
                //      one that already exists in example app.
                icon: "@mipmap/ic_launcher",
              ),
            ));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        showDialog(
            // context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(notification.title ?? ""),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(notification.body ?? "")],
                  ),
                ),
              );
            },
            context: context);
      }
    });

    getToken();

    
  }

  late String token;
  getToken() async {
    token = (await FirebaseMessaging.instance.getToken())!;
  }



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    HomeScreen(),
    const WebviewScreen(
      url: 'https://workflow.mew.gov.kw',
    ),
    const WebviewScreen(
      url: 'https://procurement.mew.gov.kw/Account/Login',
    ),
    const WebviewScreen(
      url: 'https://portal.csc.gov.kw/webcenter/portal/CSCPortal',
    ),
    SettingsScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Colors.black,
        unselectedLabelStyle: const TextStyle(color: Colors.blue),
        selectedItemColor: Colors.blue,
        selectedLabelStyle: const TextStyle(color: Colors.blue),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: _onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'الصفحة الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/bg.png',
              height: 25,
            ),
            label: 'المراسلات',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/bg.png',
              height: 25,
            ),
            label: 'الشراء الالي',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/3.png',
              height: 25,
            ),
            label: 'ديوان الخدمه المدنيه',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'الاعدادات',
          ),
        ],
      ),
    );
  }
}
