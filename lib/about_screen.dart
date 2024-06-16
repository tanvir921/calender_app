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
          child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/bg.png',
              height: 200,
              width: 200,
            ),
            const SizedBox(height: 10),
            const Text(
              Constants.appName,
              style: TextStyle(fontSize: 30),
            ),
            const SizedBox(height: 5),
            const Text('Version ${Constants.appVersion}',
                style: TextStyle(fontSize: 15)),
            const SizedBox(height: 10),
            Container(
              width: 350,
              child: const Text(
                'هذا البرنامج لجميع موظفي وزاره الكهرباء والماء والطاقة المتجددة حيث يمكن متابعة عمل نظام النوبات والصباحي مع خاصية اضافة ايام الاجازات الدوريه والمرضية والطارئة . ',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text('Created by:'),
            const Text(
              'Eng. Marzouq Alshaaban',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text('Email: mtsbinshaaban@mew.gov.kw'),
            const SizedBox(
              height: 20,
            ),
            const SizedBox(
              width: 400,
              child: Center(
                child: Text(
                  'Dedicated to all colleagues Workers in the Ministry of Electricity and Water',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
          ],
        ),
      )),
    );
  }
}
