import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:komun_apps/pages/komunitas/index.dart';
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

class BuatKomunitas extends StatefulWidget {
  @override
  _BuatKomunitasState createState() => _BuatKomunitasState();
}

class _BuatKomunitasState extends State<BuatKomunitas> {
  bool prosesLogin = false;
  Future<File> file;
  String base64Image;
  File tmpFile;
  String errMessage = 'Error Uploading Image';
  Image imageUs;
  String status = "";
  final TextEditingController _nama = new TextEditingController();
  final TextEditingController _tentang = new TextEditingController();
  final TextEditingController _kegiatan = new TextEditingController();
  final TextEditingController _info = new TextEditingController();
  final TextEditingController _lokasi = new TextEditingController();
  final TextEditingController _contact = new TextEditingController();
  final TextEditingController _admin = new TextEditingController();

  final Helper helper = Helper();
  chooseImages() {
    setState(() {
      // ignore: deprecated_member_use
      file = ImagePicker.pickImage(source: ImageSource.camera);
    });

    setStatus('');
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

  startUpload() {
    setStatus('Uploading Image...');
    if (null == tmpFile) {
      setStatus(errMessage);
      return;
    }
    String fileName = tmpFile.path.split('/').last;
    save(fileName);
  }

  save(String filename) async {
    setState(() {
      prosesLogin = true;
    });
    final response = await http.post(Config.BASE_URL + "buatKomunitas", body: {
      "nama": _nama.text,
      "tentang": _tentang.text,
      "kegiatan": _kegiatan.text,
      "info": _info.text,
      "lokasi": _lokasi.text,
      "contact": _contact.text,
      "admin": idUser,
      "image": base64Image,
      "name": filename,
    });
    final res = jsonDecode(response.body);
    if (res['status'] == "200") {
      setState(() {
        prosesLogin = false;
      });
      helper.alertLog(res['message']);
      Navigator.push(context, MaterialPageRoute(builder: (context) => Index()));
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

  @override
  void initState() {
    super.initState();
    prosesLogin = false;
    _getCurrentUser();
  }

  void modalUpload() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: Text(
              "Upload Foto Profile Anda",
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
                              "Galeri",
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
                              "Kamera",
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
          "BuatKomunitas",
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
                          hintText: "Nama Komunitas",
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
                      controller: _tentang,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(left: 24, top: 14.0),
                          hintText: "Tentang Komunitas",
                          hintStyle: GoogleFonts.poppins(color: primaryColor),
                          prefixIcon: Icon(
                            Icons.album,
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
                      controller: _kegiatan,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(left: 24, top: 14.0),
                          hintText: "Kegiatan Komunitas",
                          hintStyle: GoogleFonts.poppins(color: primaryColor),
                          prefixIcon: Icon(
                            Icons.track_changes,
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
                      controller: _info,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(left: 24, top: 14.0),
                          hintText: "Info Komunitas",
                          hintStyle: GoogleFonts.poppins(color: primaryColor),
                          prefixIcon: Icon(
                            Icons.info,
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
                      controller: _lokasi,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(left: 24, top: 14.0),
                          hintText: "Lokasi Komunitas",
                          hintStyle: GoogleFonts.poppins(color: primaryColor),
                          prefixIcon: Icon(
                            Icons.pin_drop,
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
                      controller: _contact,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(left: 24, top: 14.0),
                          hintText: "Contact Komunitas",
                          hintStyle: GoogleFonts.poppins(color: primaryColor),
                          prefixIcon: Icon(
                            Icons.phone,
                            size: 23,
                            color: primaryColor,
                          )),
                    ),
                  ),
                ),
                // Container(
                //   margin: EdgeInsets.only(top: 14, left: 24, right: 24),
                //   decoration: BoxDecoration(
                //       color: Colors.white,
                //       border: Border.all(color: primaryColor),
                //       borderRadius: BorderRadius.circular(10)),
                //   child: Center(
                //     child: TextField(
                //       style: GoogleFonts.poppins(color: primaryColor),
                //       controller: _admin,
                //       decoration: InputDecoration(
                //           border: InputBorder.none,
                //           contentPadding: EdgeInsets.only(left: 24, top: 14.0),
                //           hintText: "Admin Komunitas",
                //           hintStyle: GoogleFonts.poppins(color: primaryColor),
                //           prefixIcon: Icon(
                //             Icons.people_outline,
                //             size: 23,
                //             color: primaryColor,
                //           )),
                //     ),
                //   ),
                // ),
                GestureDetector(
                  onTap: () {
                    modalUpload();
                  },
                  child: Container(
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(100)),
                    margin: EdgeInsets.only(top:5),
                    child: Center(child: showImage()),
                  ),
                ),
                GestureDetector(
                  onTap: () => base64Image == ""
                      ? helper.alertLog("Silahkan upload foto terlebih dahulu")
                      : startUpload(),
                  child: Container(
                    margin: EdgeInsets.only(top: 14),
                    width: MediaQuery.of(context).size.width * 0.80,
                    height: 40,
                    decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                        child: Text("Simpan",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: Colors.white))),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top:5),
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
