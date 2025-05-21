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
    apiKey: 'AIzaSyDyAJZ9PjA5zg7P5oM2ibYsE1ISc-MLXOc',
    appId: '1:205053743741:web:695d7199f60144d4121714',
    messagingSenderId: '205053743741',
    projectId: 'landeed-69890',
    authDomain: 'landeed-69890.firebaseapp.com',
    storageBucket: 'landeed-69890.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDyAJZ9PjA5zg7P5oM2ibYsE1ISc-MLXOc',
    appId: '1:205053743741:android:695d7199f60144d4121714',
    messagingSenderId: '205053743741',
    projectId: 'landeed-69890',
    storageBucket: 'landeed-69890.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBqNNUbJ4CANuv28qLcqXNqFCLqpXwoC-g',
    appId: '1:205053743741:ios:0de12ebc035f79a5121714',
    messagingSenderId: '205053743741',
    projectId: 'landeed-69890',
    storageBucket: 'landeed-69890.appspot.com',
    iosClientId: '205053743741-ios-client-id.apps.googleusercontent.com',
    iosBundleId: 'com.landeed.landeed',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBqNNUbJ4CANuv28qLcqXNqFCLqpXwoC-g',
    appId: '1:205053743741:ios:0de12ebc035f79a5121714',
    messagingSenderId: '205053743741',
    projectId: 'landeed-69890',
    storageBucket: 'landeed-69890.appspot.com',
    iosClientId: '205053743741-ios-client-id.apps.googleusercontent.com',
    iosBundleId: 'com.landeed.landeed',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDyAJZ9PjA5zg7P5oM2ibYsE1ISc-MLXOc',
    appId: '1:205053743741:windows:695d7199f60144d4121714',
    messagingSenderId: '205053743741',
    projectId: 'landeed-69890',
    storageBucket: 'landeed-69890.appspot.com',
  );
} 