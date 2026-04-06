import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return android;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return android;
      case TargetPlatform.macOS:
        return android;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD3N-D2rUs0ibCOlJ8bKLjk2hMNNWVQebw',
    appId: '1:897659505496:android:b1915b9eb31c19c369f32d',
    messagingSenderId: '897659505496',
    projectId: 'flutterapp-58d59',
    databaseURL: 'https://flutterapp-58d59-default-rtdb.firebaseio.com',
    storageBucket: 'flutterapp-58d59.firebasestorage.app',
  );
}