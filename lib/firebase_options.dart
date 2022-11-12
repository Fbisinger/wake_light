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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyBqFXLJc9Bv3_BxwNSZ2r-wXuia7RrghFI',
    appId: '1:307991962498:web:1d85905813db489b0fa59b',
    messagingSenderId: '307991962498',
    projectId: 'wake-light-61f40',
    authDomain: 'wake-light-61f40.firebaseapp.com',
    databaseURL: 'https://wake-light-61f40-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'wake-light-61f40.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDgfKGVleFKm5jzaadOAClUbZT_n2jTgTs',
    appId: '1:307991962498:android:df615d6a4a22ea790fa59b',
    messagingSenderId: '307991962498',
    projectId: 'wake-light-61f40',
    databaseURL: 'https://wake-light-61f40-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'wake-light-61f40.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB6CfkPgqpLDeS_FEe9nuMrJdZhmaHQB8g',
    appId: '1:307991962498:ios:17ff7036781903450fa59b',
    messagingSenderId: '307991962498',
    projectId: 'wake-light-61f40',
    databaseURL: 'https://wake-light-61f40-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'wake-light-61f40.appspot.com',
    iosClientId: '307991962498-e2kuqf1mn4buef2a76osrcol8heo0d07.apps.googleusercontent.com',
    iosBundleId: 'com.laurenckaefer.wakeLight',
  );
}