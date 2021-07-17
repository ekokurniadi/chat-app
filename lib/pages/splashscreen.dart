import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String idUser="";
  String job="";

  _getCurrentUser()async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var user = sharedPreferences.get('id');
    var userJob = sharedPreferences.get('job');
    setState(() {
      idUser = user;
      job = userJob;
    });
  }

  initSplashScreen()async{
    var duration = const Duration(seconds:2);
    return Timer(duration,(){
      if(idUser==null){
        
      }else if(idUser != null){

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
    return Container(
       child: null,
    );
  }
}