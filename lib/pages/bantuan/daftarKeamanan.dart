import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:komun_apps/components/constanta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/Helper.dart';
import '../../components/config.dart';
import '../../components/constanta.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

class DaftarKeamanan extends StatefulWidget {
  @override
  _DaftarKeamananState createState() => _DaftarKeamananState();
}

class _DaftarKeamananState extends State<DaftarKeamanan> {
  bool prosesLogin = false;
  Future<File> file;
  String base64Image;
  File tmpFile;
  String errMessage = 'Error Uploading Image';
  Image imageUs;
  String status = "";
  final TextEditingController _nama = new TextEditingController();
  final TextEditingController _noTelp = new TextEditingController();
  final TextEditingController _alamat = new TextEditingController();

  final Helper helper = Helper();
  chooseImages() {
    setState(() {
      // ignore: deprecated_member_use
      file = ImagePicker.pickImage(source: ImageSource.camera);
    });

    setStatus('');
  }

  bool loading;
  _getCurrentUser() async {
    setState(() {
      loading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    var userId = pref.getString("idUser");
    final response = await http
        .post(Config.BASE_URL + "getCurrentUser", body: {"id": userId});
    final res = jsonDecode(response.body);
    if (res['status'] == 200) {
      setState(() {
        loading = false;
        _nama.text = res['nama'];
        _alamat.text = res['alamat'];
        _noTelp.text = res['username'];
        status = res['statususer'];
      });
    } else {
      setState(() {
        loading = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    getIdUser();
  }

  setStatus(String message) {
    setState(() {
      status = message;
    });
  }

  chooseImage() {
    setState(() {
      // ignore: deprecated_member_use
      file = ImagePicker.pickImage(source: ImageSource.gallery);
    });
    setStatus('');
  }

  String user = "";
  getIdUser() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var userId = pref.getString("idUser");
    setState(() {
      user = userId;
    });
  }

  save() async {
    setState(() {
      prosesLogin = true;
    });
    final response =
        await http.post(Config.BASE_URL + "registerKeamanan", body: {
      "id": user,
      "nama": _nama.text,
      "noTelp": _noTelp.text,
      "alamat": _alamat.text,
    });
    final res = jsonDecode(response.body);
    if (res['status'] == "200") {
      setState(() {
        prosesLogin = false;
      });
      helper.alertLog(res['message']);
    } else {
      setState(() {
        prosesLogin = false;
      });
      helper.alertLog(res['message']);
    }
  }

  showImage() {
    return FutureBuilder<File>(
      future: file,
      builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            null != snapshot.data) {
          tmpFile = snapshot.data;
          base64Image = base64Encode(snapshot.data.readAsBytesSync());
          return Image.file(
            snapshot.data,
            fit: BoxFit.fill,
            width: 100,
            height: 110,
          );
        } else if (null != snapshot.error) {
          return Image.asset(
            "images/add-photo.png",
            width: 100,
            height: 110,
            fit: BoxFit.fill,
          );
        } else {
          return Image.asset(
            "images/add-photo.png",
            width: 100,
            height: 110,
            fit: BoxFit.fill,
          );
        }
      },
    );
  }

  void modalUpload() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: Text(
              "Please Upload your profile picture",
              style: GoogleFonts.poppins(fontSize: 15.0),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.cancel),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
            content: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      chooseImage();
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.all(5),
                      height: 50,
                      width: 100,
                      decoration: BoxDecoration(
                          border: Border.all(color: primaryColor),
                          borderRadius: BorderRadius.circular(30)),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.picture_in_picture,
                                color: Colors.blueGrey),
                            Text(
                              "Galery",
                              style: GoogleFonts.poppins(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      chooseImages();
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 50,
                      width: 100,
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          border: Border.all(color: primaryColor),
                          borderRadius: BorderRadius.circular(30)),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_front, color: Colors.blueGrey),
                            Text(
                              "Camera",
                              style: GoogleFonts.poppins(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: Text(
          "Register as Security",
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
              children: [
                Container(
                  margin: EdgeInsets.only(top: 14, left: 24, right: 24),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: primaryColor),
                      borderRadius: BorderRadius.circular(10)),
                  child: Center(
                    child: TextField(
                      style: GoogleFonts.poppins(color: primaryColor),
                      controller: _nama,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(left: 24, top: 14.0),
                          hintText: "Name",
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
                  margin: EdgeInsets.only(top: 14, left: 24, right: 24),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: primaryColor),
                      borderRadius: BorderRadius.circular(10)),
                  child: Center(
                    child: TextField(
                      style: GoogleFonts.poppins(color: primaryColor),
                      controller: _alamat,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(left: 24, top: 14.0),
                          hintText: "Work Address",
                          hintStyle: GoogleFonts.poppins(color: primaryColor),
                          prefixIcon: Icon(
                            Icons.home,
                            size: 23,
                            color: primaryColor,
                          )),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 14, left: 24, right: 24),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: primaryColor),
                      borderRadius: BorderRadius.circular(10)),
                  child: Center(
                    child: TextField(
                      style: GoogleFonts.poppins(color: primaryColor),
                      controller: _noTelp,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(left: 24, top: 14.0),
                          hintText: "Phone Number",
                          hintStyle: GoogleFonts.poppins(color: primaryColor),
                          prefixIcon: Icon(
                            Icons.call,
                            size: 23,
                            color: primaryColor,
                          )),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => save(),
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
                Container(
                  width: MediaQuery.of(context).size.width * 0.15,
                  height: 3,
                  decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(30)),
                ),
              ],
            ),
          )),
    );
  }
}
