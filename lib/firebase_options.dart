// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyDfxtMmN3HJRMxGdn9btHveXGVptPKlAM4',
    appId: '1:61978761608:web:bd6396561312986e6a023d',
    messagingSenderId: '61978761608',
    projectId: 'self-finance-with-ads',
    authDomain: 'self-finance-with-ads.firebaseapp.com',
    storageBucket: 'self-finance-with-ads.appspot.com',
    measurementId: 'G-1B98D0FCSX',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyARMxxK0qx5jk2KUbbaZaBgt-afSKLqB3Q',
    appId: '1:61978761608:android:88e6d349aaa032b56a023d',
    messagingSenderId: '61978761608',
    projectId: 'self-finance-with-ads',
    storageBucket: 'self-finance-with-ads.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAGnWJ76et7ukAtZggjBQOkPekEv-AtimA',
    appId: '1:61978761608:ios:619a9e2c2235d02b6a023d',
    messagingSenderId: '61978761608',
    projectId: 'self-finance-with-ads',
    storageBucket: 'self-finance-with-ads.appspot.com',
    iosBundleId: 'com.vamshikrishna.selfFinance',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAGnWJ76et7ukAtZggjBQOkPekEv-AtimA',
    appId: '1:61978761608:ios:619a9e2c2235d02b6a023d',
    messagingSenderId: '61978761608',
    projectId: 'self-finance-with-ads',
    storageBucket: 'self-finance-with-ads.appspot.com',
    iosBundleId: 'com.vamshikrishna.selfFinance',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDfxtMmN3HJRMxGdn9btHveXGVptPKlAM4',
    appId: '1:61978761608:web:9f7e8e2eb12fe9dc6a023d',
    messagingSenderId: '61978761608',
    projectId: 'self-finance-with-ads',
    authDomain: 'self-finance-with-ads.firebaseapp.com',
    storageBucket: 'self-finance-with-ads.appspot.com',
    measurementId: 'G-7T5VK5YYY3',
  );

}