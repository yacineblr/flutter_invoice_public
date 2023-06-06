import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_invoice/service-locator.dart';

class AppService {
  FirebaseApp? firebase;
  AppService() {
    initAsync();
  }

  initAsync() async {
    firebase = await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "",
        authDomain: "",
        databaseURL: "",
        projectId: "",
        storageBucket: "",
        messagingSenderId: "",
        appId: ""
      )
    );
    locator.signalReady(this);
  }
}