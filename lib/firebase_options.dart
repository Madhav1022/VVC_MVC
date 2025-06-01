import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Web configuration - you'll need to get these values from your Firebase console
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: 'YOUR_WEB_APP_ID',
    messagingSenderId: '813948457066',
    projectId: 'virtual-visiting-card-mvc',
    authDomain: 'virtual-visiting-card-mvc.firebaseapp.com',
    storageBucket: 'virtual-visiting-card-mvc.firebasestorage.app',
  );

  // Android configuration - you'll need to get these values from your Firebase console
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: 'YOUR_ANDROID_APP_ID',
    messagingSenderId: '813948457066',
    projectId: 'virtual-visiting-card-mvc',
    storageBucket: 'virtual-visiting-card-mvc.firebasestorage.app',
  );

  // iOS configuration - using values from your GoogleService-Info.plist
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBuVDeJlWPNx5mg7t0JjQtWwVI9ZE4cWUk',
    appId: '1:813948457066:ios:ad65c3b1ac45739f9f7a13',
    messagingSenderId: '813948457066',
    projectId: 'virtual-visiting-card-mvc',
    storageBucket: 'virtual-visiting-card-mvc.firebasestorage.app',
    iosClientId: '813948457066-YOUR_CLIENT_ID_HERE.apps.googleusercontent.com',
    iosBundleId: 'com.example.virtualVisitingCardMvc',
  );
}