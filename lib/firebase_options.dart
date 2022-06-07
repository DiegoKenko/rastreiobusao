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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDZT5coXo6WlxWHoe4iZGLYkg8bq7xK1CM',
    appId: '1:519420295610:android:c3089dca57bbb2766b4583',
    messagingSenderId: '519420295610',
    projectId: 'multirotas-b3006',
    databaseURL: 'https://multirotas-b3006-default-rtdb.firebaseio.com',
    storageBucket: 'multirotas-b3006.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAONyfWeJJWQlqy2szV5mpxUl_Q5Y1hqEk',
    appId: '1:519420295610:ios:dee1dbcfc72fafb16b4583',
    messagingSenderId: '519420295610',
    projectId: 'multirotas-b3006',
    databaseURL: 'https://multirotas-b3006-default-rtdb.firebaseio.com',
    storageBucket: 'multirotas-b3006.appspot.com',
    iosClientId: '519420295610-652s4pdt3vubahnusi3geavbt61ftvm3.apps.googleusercontent.com',
    iosBundleId: 'com.example.rastreiobusao',
  );
}
