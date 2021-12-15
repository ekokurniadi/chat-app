import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:komun_apps/components/Helper.dart';
import 'package:komun_apps/components/config.dart';
import 'package:komun_apps/components/constanta.dart';
import 'package:http/http.dart' as http;
import 'package:komun_apps/pages/register.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _username = new TextEditingController();
  final TextEditingController _password = new TextEditingController();
  final TextEditingController _confirmpassword = new TextEditingController();
  final Helper helper = Helper();
  bool prosesLogin = false;
  String confirmPass = "";
  String status = "";
  bool statusConfirm = false;
  _loginAction() async {
    setState(() {
      prosesLogin = true;
    });
    final response = await http.post(Config.BASE_URL + "lupaPassword", body: {
      "username": _username.text,
      "password": _password.text,
    });
    final res = jsonDecode(response.body);
    String value = res['status'];
    String message = res['message'];

    if (value == "200") {
      setState(() {
        prosesLogin = false;
      });
      helper.alertLog(message);
      Navigator.pop(context);
    } else {
      setState(() {
        prosesLogin = false;
      });
      helper.alertLog(message);
    }
  }

  void cekpassword(String value) {
    if (value == _password.text) {
      setState(() {
        statusConfirm = true;
        status = "";
      });
    } else {
      statusConfirm = false;
      status = "Password not match";
    }
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
      backgroundColor: Colors.white,
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
                child: Center(child: Image.asset("images/lupa.jpg")),
              ),
              Container(
                margin: EdgeInsets.only(top: 24, left: 24, right: 24),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: primaryColor),
                    borderRadius: BorderRadius.circular(10)),
                child: Center(
                  child: TextField(
                    style: GoogleFonts.poppins(color: primaryColor),
                    controller: _username,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(left: 24, top: 14.0),
                        hintText: "Phone Number",
                        hintStyle: GoogleFonts.poppins(color: primaryColor),
                        prefixIcon: Icon(
                          Icons.people_outline,
                          size: 23,
                          color: primaryColor,
                        )),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 24, right: 24, top: 14),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: primaryColor),
                    borderRadius: BorderRadius.circular(10)),
                child: Center(
                  child: TextField(
                    style: GoogleFonts.poppins(color: primaryColor),
                    controller: _password,
                    obscureText: true,
                    decoration: InputDecoration(
                        labelStyle: GoogleFonts.poppins(),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(left: 24, top: 14.0),
                        hintText: "New Password",
                        hintStyle: GoogleFonts.poppins(color: primaryColor),
                        prefixIcon:
                            Icon(Icons.lock, size: 23, color: primaryColor)),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 24, right: 24, top: 14),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: primaryColor),
                    borderRadius: BorderRadius.circular(10)),
                child: Center(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        confirmPass = value;
                      });
                      cekpassword(confirmPass);
                    },
                    style: GoogleFonts.poppins(color: primaryColor),
                    controller: _confirmpassword,
                    obscureText: true,
                    decoration: InputDecoration(
                        labelStyle: GoogleFonts.poppins(),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(left: 24, top: 14.0),
                        hintText: "Confirm New Password",
                        hintStyle: GoogleFonts.poppins(color: primaryColor),
                        prefixIcon:
                            Icon(Icons.lock, size: 23, color: primaryColor)),
                  ),
                ),
              ),
              Container(
                child: Visibility(
                    visible: status == "" ? false : true,
                    child: Text("$status",
                        style: GoogleFonts.poppins(
                            color: statusConfirm == true
                                ? Colors.green
                                : Colors.red))),
              ),
              GestureDetector(
                onTap: () => _loginAction(),
                child: Container(
                  margin: EdgeInsets.only(top: 14),
                  width: MediaQuery.of(context).size.width * 0.80,
                  height: 40,
                  decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(10)),
                  child: Center(
                      child: Text("Submit",
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: Colors.white))),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Register()));
                },
                child: Container(
                  margin: EdgeInsets.only(top: 18),
                  width: MediaQuery.of(context).size.width * 0.80,
                  height: 40,
                  child: Center(
                      child: Text("Create New Account",
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w400,
                              color: primaryColor))),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.15,
                height: 3,
                decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(30)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
