import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyCRHn-k5QFa_EaEez12CfI9jWp9YmXfBT4",
    authDomain: "mad-lab-85592.firebaseapp.com",
    projectId: "mad-lab-85592",
    storageBucket: "mad-lab-85592.appspot.com",
    messagingSenderId: "183661997097",
    appId: "1:183661997097:web:b49302752315e026994038",
    measurementId: "G-9HGRPBS39V",
  );
} 