// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDbdApnj5PGC9284_2Ht-qAtQ7pRV6nayk',
    appId: '1:682679510328:web:0218366eee70db70864dcd',
    messagingSenderId: '682679510328',
    projectId: 'smart-chadaha',
    authDomain: 'smart-chadaha.firebaseapp.com',
    storageBucket: 'smart-chadaha.appspot.com',
    measurementId: 'G-9VV53KJRPY',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA0gkbuQFqeBFCX1Nt9TaADOFxyDBhRXAs',
    appId: '1:682679510328:android:beae0760d2234154864dcd',
    messagingSenderId: '682679510328',
    projectId: 'smart-chadaha',
    storageBucket: 'smart-chadaha.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAremMbenPT_19n13YsgNMPOrNeSpqJyb4',
    appId: '1:682679510328:ios:480a95eb6410b2bb864dcd',
    messagingSenderId: '682679510328',
    projectId: 'smart-chadaha',
    storageBucket: 'smart-chadaha.appspot.com',
    iosBundleId: 'com.example.smartChandaha',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAremMbenPT_19n13YsgNMPOrNeSpqJyb4',
    appId: '1:682679510328:ios:2049dd46a2fb7937864dcd',
    messagingSenderId: '682679510328',
    projectId: 'smart-chadaha',
    storageBucket: 'smart-chadaha.appspot.com',
    iosBundleId: 'com.example.smartChandaha.RunnerTests',
  );
}