import 'package:flutter/material.dart';
import 'package:komun_apps/pages/adMobIn.dart';
import 'package:komun_apps/pages/home/home.dart';
import 'package:komun_apps/pages/login.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String idUser = "";
  String job = "";

  _getCurrentUser() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var user = sharedPreferences.get('idUser');
    print("usernya: $user");
    setState(() {
      idUser = user;
    });
  }

  initSplashScreen() async {
    var duration = const Duration(seconds: 5);
    return Timer(duration, () {
      if (idUser == null) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Login()));
      } else if (idUser != null) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Home()));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    initSplashScreen();
    _getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AdMobInPage()
    );
  }
}
