import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:komun_apps/components/constanta.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
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
      body: SingleChildScrollView(
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
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Center(
                child: TextField(
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
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Center(
                child: TextField(
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
            Container(
              margin: EdgeInsets.only(top: 5),
              width: MediaQuery.of(context).size.width * 0.80,
              height: 40,
              decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(10)),
              child: Center(
                  child: Text("SIGN IN",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, color: Colors.white))),
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
                  color: Colors.white, borderRadius: BorderRadius.circular(30)),
              child: Center(
                  child: Text("Daftar akun baru",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500, color: Colors.white))),
            ),
          ],
        ),
      ),
    );
  }
}
