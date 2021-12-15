import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:komun_apps/components/uploadImage.dart';
import 'package:komun_apps/components/uploadImageDemo.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import '../../components/Helper.dart';
import '../../components/config.dart';

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  bool loading = false;
  bool _obsecureText = true;
  String imageUser = "";
  bool terima = true;
  String status = "0";
  String user = "";
  TextEditingController _nama = TextEditingController();
  TextEditingController _alamat = TextEditingController();
  TextEditingController _level = TextEditingController();
  TextEditingController _username = TextEditingController();
  TextEditingController _password = TextEditingController();
  final Helper helper = new Helper();
  FirebaseMessaging fm = FirebaseMessaging();

  _SettingState() {
    fm.configure(
      onLaunch: (Map<String, dynamic> msg) async {
        // print("ketika sedang berjalan");
        // print(msg);

        if (msg['data']['screen'] == 'list_trx' &&
            msg['notification']['body'] != null) {
          helper.alertLog(msg['notification']['body']);
        } else if (msg['data']['screen'] == 'list_notif') {
          helper.alertLog(msg['notification']['body']);
        }
      },
      onResume: (Map<String, dynamic> msg) async {
        // print("ketika sedang berjalan");
        // print(msg);

        if (msg['data']['screen'] == 'list_trx' &&
            msg['notification']['body'] != null) {
          helper.alertLog(msg['notification']['body']);
        } else if (msg['data']['screen'] == 'list_notif') {
          helper.alertLog(msg['notification']['body']);
        }
      },
      onMessage: (Map<String, dynamic> msg) async {
        // print("ketika sedang berjalan");
        // print(msg);
        if (msg['data']['screen'] == 'list_trx' &&
            msg['notification']['body'] != null) {
          helper.alertLog(msg['notification']['body']);
        } else if (msg['data']['screen'] == 'list_notif') {
          helper.alertLog(msg['notification']['body']);
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    loading = true;
    getIdUser();
    _getCurrentUser();
    _getDetailAlbum();
  }

  void _showPassword() {
    setState(() {
      _obsecureText = !_obsecureText;
    });
  }

  getIdUser() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var userId = pref.getString("idUser");
    setState(() {
      user = userId;
    });
  }

  _getCurrentUser() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var userId = pref.getString("idUser");
    _getDetailAlbum();
    final response = await http
        .post(Config.BASE_URL + "getCurrentUser", body: {"id": userId});
    final res = jsonDecode(response.body);

    if (res['status'] == 200) {
      setState(() {
        loading = false;
        imageUser = res['picture'];
        _nama.text = res['nama'];
        _alamat.text = res['alamat'];
        _level.text = res['level'];
        _username.text = res['username'];
        _password.text = res['password'];
        status = res['statususer'];
        if (res['statususer'] == "0") {
          terima = false;
        } else {
          terima = true;
        }
      });
    } else {
      setState(() {
        loading = true;
      });
    }
  }

  updateState(bool val) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var userId = pref.getString("idUser");
    String nilai;
    if (val == true) {
      setState(() {
        nilai = "1";
      });
    } else {
      setState(() {
        nilai = "0";
      });
    }
    final response = await http.post(Config.BASE_URL + "updateState",
        body: {"id": userId, "status": nilai.toString()});
    final res = jsonDecode(response.body);
    if (res['status'] == "200") {
      helper.alertLog(res['message']);
      _getCurrentUser();
    } else {
      helper.alertLog(res['message']);
      _getCurrentUser();
    }
  }

  _saveSetting() async {
    setState(() {
      loading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    var userId = pref.getString("idUser");
    final response =
        await http.post(Config.BASE_URL + "updateSettingUser", body: {
      "id": userId,
      "nama": _nama.text.toString(),
      "alamat": _alamat.text.toString(),
      "password": _password.text.toString(),
    });
    final res = jsonDecode(response.body);
    if (res["status"] == 200) {
      setState(() {
        loading = false;
        helper.alertSuccess(res['message'], context);
        _getCurrentUser();
      });
    } else {
      loading = false;
      helper.alertError(res['message'], context);
      _getCurrentUser();
    }
  }

  void updateInformation2(String information) {
    setState(() => text = information);
    setState(() {
      text = information;
    });
    helper.alertLog("Foto berhasil di unggah");
    _getDetailAlbum();
  }

  void toUpload2() async {
    final information = await Navigator.push(
      context,
      MaterialPageRoute(
          fullscreenDialog: true,
          builder: (context) => UploadImage(text: "albumUser", id: user)),
    );
    updateInformation2(information);
  }

  List<dynamic> album;
  _getDetailAlbum() async {
    final response =
        await http.post(Config.BASE_URL + "getAlbumUser", body: {"id": user});
    Map<String, dynamic> res = jsonDecode(response.body);
    print(res);
    setState(() {
      album = res['values'];
    });
    // print(album);
    return "Success";
  }

  void showImages(networkImage, id) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            insetPadding: EdgeInsets.zero,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: Text(
              'Foto',
            ),
            content: Container(
              width: MediaQuery.of(context).size.width * 0.90,
              height: MediaQuery.of(context).size.height * 0.50,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(Config.BASE_URL_IMAGE + "$networkImage"),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          );
        });
  }

  String text = "";
  void updateInformation(String information) {
    setState(() => text = information);
    setState(() {
      text = information;
    });
    _getCurrentUser();
  }

  void toUpload() async {
    final information = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => UploadImageDemo(text: "1", id: user)),
    );
    updateInformation(information);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf4f4f4),
      appBar: AppBar(
        backgroundColor: Color(0xFF0c53a0),
        elevation: 0,
        title: Text(
          "Setting",
          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: loading,
        opacity: 0.5,
        progressIndicator: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Color(0xFF0c53a0)),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.20,
                decoration: BoxDecoration(
                  color: Color(0xFF306bdd),
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(50),
                    bottomLeft: Radius.circular(50),
                  ),
                ),
                child: Center(
                  child: imageUser == null
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50.0),
                              color: Colors.white,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                toUpload();
                              },
                              child: Image.asset(
                                "images/user-default.png",
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 90,
                            height: 90,
                            child: GestureDetector(
                              onTap: () {
                                toUpload();
                              },
                              child: imageUser == null
                                  ? Image.asset(
                                      "images/user-default.png",
                                      fit: BoxFit.cover,
                                    )
                                  : CircleAvatar(
                                      radius: 0,
                                      backgroundImage: NetworkImage(
                                        Config.BASE_URL_IMAGE + "$imageUser",
                                        scale: 10,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                ),
              ),
              Card(
                margin: EdgeInsets.only(
                    top: 10.0, left: 10.0, right: 10.0, bottom: 50.0),
                elevation: 3.0,
                child: Container(
                  child: Column(
                    children: [
                      ListTile(
                        title: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              children: [
                                Text(
                                  "Non Active",
                                  style: GoogleFonts.poppins(),
                                ),
                                Switch(
                                  value: terima,
                                  onChanged: (value) {
                                    setState(() {
                                      terima = value;
                                    });
                                    updateState(value);
                                  },
                                  activeTrackColor: Colors.lightBlueAccent,
                                  activeColor: Colors.blue,
                                ),
                                Text(
                                  "Active",
                                  style: GoogleFonts.poppins(),
                                ),
                              ],
                            )),
                      ),
                      SizedBox(height: 20.0),
                      Divider(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
