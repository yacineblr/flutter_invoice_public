import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_invoice/service-locator.dart';
import 'package:flutter_invoice/views/home.dart';
import 'package:flutter_localizations/flutter_localizations.dart';



void main() {
  setupLocator();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(Root());
}

class Root extends StatelessWidget {
  // Create the initialization Future outside of `build`:


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [const Locale('fr', '')],
      theme: ThemeData(
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          }
        )
      ),
      home: Scaffold(
        resizeToAvoidBottomInset: true,
        body: FutureBuilder(
          future: locator.allReady(timeout: Duration(seconds: 10)),
          builder: (context, snapshotLocator) {
            print('____ main - locator.allReady : ${snapshotLocator.hasData.toString()}');
            if (snapshotLocator.hasData) {
              return Material(child: Home());
            } else {
              return Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
          },
        ),
      ),
    );
  }
}
