import 'package:flutter/material.dart';
import 'package:komun_apps/pages/splashscreen.dart';
import 'package:firebase_admob/firebase_admob.dart';
// import 'package:komun_apps/pages/splashscreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize without device test ids
  FirebaseAdMob.instance.initialize(appId: "ca-app-pub-3137462128319942~6703857224");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Komun Apps',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(),
    );
  }
}
