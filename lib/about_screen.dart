import 'package:calender_app/constants.dart';
import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        centerTitle: true,
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/bg.png',
            height: 200,
            width: 200,
          ),
          SizedBox(height: 10),
          Text(
            Constants.appName,
            style: TextStyle(fontSize: 30),
          ),
          SizedBox(height: 5),
          Text('Version ${Constants.appVersion}',
              style: TextStyle(fontSize: 15)),
        ],
      )),
    );
  }
}
