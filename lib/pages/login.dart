import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:komun_apps/components/Helper.dart';
import 'package:komun_apps/components/config.dart';
import 'package:komun_apps/components/constanta.dart';
import 'package:http/http.dart' as http;
import 'package:komun_apps/pages/home/home.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _username = new TextEditingController();
  final TextEditingController _password = new TextEditingController();
  final Helper helper = Helper();
  bool prosesLogin = false;
  FirebaseMessaging fm = FirebaseMessaging();
  String tokenFcm = "";

  _LoginState() {
    fm.getToken().then((value) => tokenFcm = value);
    fm.configure();
  }

  _loginAction() async {
    setState(() {
      prosesLogin = true;
    });
    final response = await http.post(Config.BASE_URL + "login", body: {
      "username": _username.text,
      "password": _password.text,
      "token": tokenFcm
    });
    final res = jsonDecode(response.body);
    String value = res['status'];
    String message = res['message'];
    String idUser = res['idUser'].toString();
    String nama = res['nama'];
    String username = res['username'];
    String level = res['level'];

    if (value == "1") {
      setState(() {
        savePref(idUser, nama, username, level);
      });
      setState(() {
        prosesLogin = false;
      });
      helper.alertLog(message);
       Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Home()));
    } else {
      setState(() {
        prosesLogin = false;
      });
      helper.alertLog(message);
    }
  }

  savePref(String idUser, String nama, String username, String level) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setString("idUser", idUser);
      preferences.setString("nama", nama);
      preferences.setString("username", username);
      preferences.setString("level", level);
    });
  }

  @override
  void initState() {
    super.initState();
    prosesLogin = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: Text(
          "Komun",
          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),
      backgroundColor: primaryColor,
      body: ModalProgressHUD(
        inAsyncCall: prosesLogin,
        opacity: 0.5,
        progressIndicator: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Color(0xFF0c53a0)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.all(20),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.30,
                child: Center(child: Image.asset("images/user-login.png")),
              ),
              Container(
                margin: EdgeInsets.only(top: 24, left: 24, right: 24),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                child: Center(
                  child: TextField(
                    controller: _username,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(left: 24, top: 14.0),
                        hintText: "Username",
                        hintStyle: GoogleFonts.poppins(color: primaryColor),
                        prefixIcon: Icon(
                          Icons.people_outline,
                          size: 23,
                        )),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 24, right: 24, top: 10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                child: Center(
                  child: TextField(
                    controller: _password,
                    obscureText: true,
                    decoration: InputDecoration(
                        labelStyle: GoogleFonts.poppins(),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(left: 24, top: 14.0),
                        hintText: "Password",
                        hintStyle: GoogleFonts.poppins(color: primaryColor),
                        prefixIcon: Icon(
                          Icons.lock,
                          size: 23,
                        )),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 5),
                width: MediaQuery.of(context).size.width * 0.80,
                height: 40,
                child: Center(
                    child: Align(
                        alignment: Alignment.centerRight,
                        child: Text("Lupa Password",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w400,
                                color: Colors.white)))),
              ),
              GestureDetector(
                onTap: () => _loginAction(),
                child: Container(
                  margin: EdgeInsets.only(top: 5),
                  width: MediaQuery.of(context).size.width * 0.80,
                  height: 40,
                  decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(10)),
                  child: Center(
                      child: Text("SIGN IN",
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: Colors.white))),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 18),
                width: MediaQuery.of(context).size.width * 0.80,
                height: 40,
                child: Center(
                    child: Text("Daftar akun baru",
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w400, color: Colors.white))),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.15,
                height: 3,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
