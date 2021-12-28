import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:komun_apps/components/constanta.dart';
import 'package:komun_apps/components/uploadImageDemo.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import '../../components/Helper.dart';
import '../../components/config.dart';

class ProfileUser extends StatefulWidget {
  final String id;
  ProfileUser({this.id});
  @override
  _ProfileUserState createState() => _ProfileUserState();
}

class _ProfileUserState extends State<ProfileUser> {
  bool loading = false;

  String imageUser = "";
  bool terima = true;
  String status = "0";
  String user = "";
  TextEditingController _nama = TextEditingController();
  TextEditingController _alamat = TextEditingController();
  TextEditingController _level = TextEditingController();
  TextEditingController _username = TextEditingController();
  TextEditingController _password = TextEditingController();
  TextEditingController _usia = TextEditingController();
  TextEditingController _status = TextEditingController();
  TextEditingController _agama = TextEditingController();
  TextEditingController _jenisKelamin = TextEditingController();
  final Helper helper = new Helper();
  FirebaseMessaging fm = FirebaseMessaging();

  _ProfileUserState() {
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
    _getCurrentUser();
    _getDetailAlbum();
  }

  _getCurrentUser() async {
    final response = await http
        .post(Config.BASE_URL + "getCurrentUser", body: {"id": widget.id});
    final res = jsonDecode(response.body);
    print(res);
    if (res['status'] == 200) {
      setState(() {
        loading = false;
        imageUser = res['picture'];
        _nama.text = res['nama'];
        _alamat.text = res['alamat'];
        _level.text = res['level'];
        _username.text = res['username'];
        _password.text = res['password'];
        _usia.text = res['usia'];
        _status.text = res['status_pernikahan'];
        _agama.text = res['agama'];
        status = res['statususer'];
        _jenisKelamin.text = res['jenis_kelamin'];
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

  List<dynamic> album;
  _getDetailAlbum() async {
    final response = await http
        .post(Config.BASE_URL + "getAlbumUser", body: {"id": widget.id});
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: Text(
          "Profile User",
          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),
      backgroundColor: Color(0xFFf4f4f4),
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
                            child: Image.asset(
                              "images/user-default.png",
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 90,
                            height: 90,
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
                          child: TextField(
                            readOnly: true,
                            controller: _nama,
                            style: GoogleFonts.poppins(),
                            decoration: InputDecoration(
                              labelText: "Name",
                              labelStyle: TextStyle(
                                color: Color(0xFF70747F),
                              ),
                              hintText: "Name",
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2,
                                  color: Color(0xFFC9CFDF),
                                ),
                              ),
                              contentPadding: const EdgeInsets.only(
                                  left: 0.0, bottom: 0.0, top: 0.0),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2,
                                  color: Color(0xFFC9CFDF),
                                ),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2,
                                  color: Color(0xFFC9CFDF),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      ListTile(
                        title: Container(
                          width: MediaQuery.of(context).size.width,
                          child: TextField(
                            readOnly: true,
                            controller: _alamat,
                            style: GoogleFonts.poppins(),
                            decoration: InputDecoration(
                              labelText: "Address",
                              labelStyle: TextStyle(
                                color: Color(0xFF70747F),
                              ),
                              hintText: "Address",
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2,
                                  color: Color(0xFFC9CFDF),
                                ),
                              ),
                              contentPadding: const EdgeInsets.only(
                                  left: 0.0, bottom: 0.0, top: 0.0),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2,
                                  color: Color(0xFFC9CFDF),
                                ),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2,
                                  color: Color(0xFFC9CFDF),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      ListTile(
                        title: Container(
                          width: MediaQuery.of(context).size.width,
                          child: TextField(
                            controller: _usia,
                            style: GoogleFonts.poppins(),
                            decoration: InputDecoration(
                              labelText: "Age",
                              labelStyle: TextStyle(
                                color: Color(0xFF70747F),
                              ),
                              hintText: "Age",
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2,
                                  color: Color(0xFFC9CFDF),
                                ),
                              ),
                              contentPadding: const EdgeInsets.only(
                                  left: 0.0, bottom: 0.0, top: 0.0),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2,
                                  color: Color(0xFFC9CFDF),
                                ),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2,
                                  color: Color(0xFFC9CFDF),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      ListTile(
                        title: Container(
                          width: MediaQuery.of(context).size.width,
                          child: TextField(
                            controller: _jenisKelamin,
                            style: GoogleFonts.poppins(),
                            decoration: InputDecoration(
                              labelText: "Gender",
                              labelStyle: TextStyle(
                                color: Color(0xFF70747F),
                              ),
                              hintText: "Gender",
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2,
                                  color: Color(0xFFC9CFDF),
                                ),
                              ),
                              contentPadding: const EdgeInsets.only(
                                  left: 0.0, bottom: 0.0, top: 0.0),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2,
                                  color: Color(0xFFC9CFDF),
                                ),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2,
                                  color: Color(0xFFC9CFDF),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      ListTile(
                        title: Container(
                          width: MediaQuery.of(context).size.width,
                          child: TextField(
                            controller: _status,
                            style: GoogleFonts.poppins(),
                            decoration: InputDecoration(
                              labelText: "Status",
                              labelStyle: TextStyle(
                                color: Color(0xFF70747F),
                              ),
                              hintText: "Status",
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2,
                                  color: Color(0xFFC9CFDF),
                                ),
                              ),
                              contentPadding: const EdgeInsets.only(
                                  left: 0.0, bottom: 0.0, top: 0.0),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2,
                                  color: Color(0xFFC9CFDF),
                                ),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2,
                                  color: Color(0xFFC9CFDF),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      ListTile(
                        title: Container(
                          width: MediaQuery.of(context).size.width,
                          child: TextField(
                            controller: _agama,
                            style: GoogleFonts.poppins(),
                            decoration: InputDecoration(
                              labelText: "Religion",
                              labelStyle: TextStyle(
                                color: Color(0xFF70747F),
                              ),
                              hintText: "Religion",
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2,
                                  color: Color(0xFFC9CFDF),
                                ),
                              ),
                              contentPadding: const EdgeInsets.only(
                                  left: 0.0, bottom: 0.0, top: 0.0),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2,
                                  color: Color(0xFFC9CFDF),
                                ),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2,
                                  color: Color(0xFFC9CFDF),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Divider(),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Post",
                          style: GoogleFonts.poppins(color: Colors.blueGrey),
                        ),
                      ),
                      album == null
                          ? Center(
                              child: Text("Nothing to show"),
                            )
                          : Container(
                              height: MediaQuery.of(context).size.height * 0.80,
                              child: GridView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3),
                                  itemCount: album.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return GestureDetector(
                                      onTap: () {
                                        showImages("${album[index]['foto']}",
                                            album[index]['id']);
                                      },
                                      child: Container(
                                        color: Colors.blueGrey,
                                        padding: EdgeInsets.all(2),
                                        margin: EdgeInsets.all(0.5),
                                        child: Image.network(
                                          Config.BASE_URL_IMAGE +
                                              album[index]['foto'],
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    );
                                  }),
                            ),
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
