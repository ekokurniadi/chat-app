import 'package:flutter/material.dart';
import 'package:komun_apps/pages/splashscreen.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:new_version/new_version.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize without device test ids
  FirebaseAdMob.instance
      .initialize(appId: "ca-app-pub-3137462128319942~6703857224");
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _checkVersion();
  }

  void _checkVersion() async {
    final newVersion = NewVersion(
	  context: context,
      androidId: "com.komunapps.com.komun_apps",
	  dialogTitle: "Update Available",
	  dismissText: "Exit",
	  dialogText: "Please update your app for best experiences with Komun Apps",
	  dismissAction: () {
        SystemNavigator.pop();
      },
	  updateText: "Update"
    );
    final status = await newVersion.getVersionStatus();
	newVersion.showUpdateDialog(status);
    print("DEVICE : " + status.localVersion);
    print("STORE : " + status.storeVersion);
  }

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
