
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:nutri_scan/core/config/app_config.dart';
import 'package:nutri_scan/firebase_options.dart';

Future<void> initializeDatabase() async {
  // Any necessary initialization can be done here.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (AppConfig.useEmulator) {
    FirebaseFirestore.instance.useFirestoreEmulator('127.0.0.1', 8080);
  }

}

class Database {
  static final db = FirebaseFirestore.instance;
}