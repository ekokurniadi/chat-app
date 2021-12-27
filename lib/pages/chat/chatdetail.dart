import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:komun_apps/components/uploadImageMessage.dart';
import 'package:komun_apps/pages/profile/profileUser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/Helper.dart';
import '../../components/config.dart';
import '../../components/constanta.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent/android_intent.dart';
import 'dart:ui';

class ChatDetail extends StatefulWidget {
  final String id;
  final String name;
  final String tujuan;
  final String dari;
  final String call;
  ChatDetail({this.id, this.name, this.tujuan, this.call, this.dari});

  @override
  _ChatDetailState createState() => _ChatDetailState();
}

class _ChatDetailState extends State<ChatDetail> {
  int page = 20;
  bool isLoading = false;
  ScrollController _scrollController = new ScrollController();
  String users = "";
  TextEditingController sendController = TextEditingController();
  final Helper helper = Helper();
  FirebaseMessaging fm = FirebaseMessaging();

  _ChatDetailState() {
    fm.configure(
      onLaunch: (Map<String, dynamic> msg) async {
        // print("ketika sedang berjalan");
        // print(msg);

        if (msg['data']['screen'] == 'list_trx' &&
            msg['notification']['body'] != null) {
          helper.alertLog(msg['notification']['body']);
          _getMoreData(page);
        } else if (msg['data']['screen'] == 'list_notif') {
          helper.alertLog(msg['notification']['body']);
          _getMoreData(page);
        }
      },
      onResume: (Map<String, dynamic> msg) async {
        // print("ketika sedang berjalan");
        // print(msg);

        if (msg['data']['screen'] == 'list_trx' &&
            msg['notification']['body'] != null) {
          helper.alertLog(msg['notification']['body']);
          _getMoreData(page);
        } else if (msg['data']['screen'] == 'list_notif') {
          helper.alertLog(msg['notification']['body']);
          _getMoreData(page);
        }
      },
      onMessage: (Map<String, dynamic> msg) async {
        // print("ketika sedang berjalan");
        // print(msg);
        if (msg['data']['screen'] == 'list_trx' &&
            msg['notification']['body'] != null) {
          helper.alertLog(msg['notification']['body']);
          _getMoreData(page);
        } else if (msg['data']['screen'] == 'list_notif') {
          helper.alertLog(msg['notification']['body']);
          _getMoreData(page);
        }
      },
    );
  }

  List<dynamic> dataUser;
  _getMoreData(int index) async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });
      var url = await http.post(Config.BASE_URL + "getMessage", body: {
        "start": "0",
        "length": index.toString(),
        "draw": "1",
        "searching": "",
        "id": widget.id
      });
      // final response = jsonDecode(url.body);
      Map<String, dynamic> response = jsonDecode(url.body);

      setState(() {
        dataUser = response["data"];
        isLoading = false;
        page++;
      });
    }
  }

  getCurrent() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var user = sharedPreferences.get('idUser');
    setState(() {
      users = user;
    });
  }

  _sendMessage() async {
    print(widget.tujuan);
    final response = await http.post(Config.BASE_URL + "sendMessage", body: {
      "id_chat": widget.id,
      "message": sendController.text,
      "sender": users,
      "recipient": widget.tujuan != users ? widget.tujuan : widget.dari
    });

    setState(() {
      sendController.clear();
    });
    final res = jsonDecode(response.body);
    if (res['status'] == "200") {
      _getMoreData(page);
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  // ignore: unused_element
  void _launchTurnByTurnNavigationInGoogleMaps(String tujuan) {
    final AndroidIntent intent = AndroidIntent(
        action: 'action_view',
        data: Uri.encodeFull('http://maps.google.com/maps?daddr=$tujuan'),
        package: 'com.google.android.apps.maps');
    intent.launch();
  }

  Timer timer;
  @override
  void initState() {
    super.initState();
    getCurrent();
    _getMoreData(page);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getMoreData(page);
      }

      // _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
    timer = Timer.periodic(Duration(seconds: 2), (Timer t) {
    //   _getMoreData(page);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: isLoading ? 1.0 : 00,
          child: new Container(),
        ),
      ),
    );
  }

  bool isLastMessageRight(int index, String sender) {
    if ((index > 0 && sender == users) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  viewUser(String id) {
    Navigator.push(
        context,
        MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => ProfileUser(
                  id: id,
                )));
  }

  String text = "";
  void updateInformation(String information) {
    setState(() => text = information);
    setState(() {
      text = information;
    });
    _getMoreData(page);
	  _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  void toUpload() async {
    final information = await Navigator.push(
      context,
      MaterialPageRoute(
          fullscreenDialog: true,
          builder: (context) => UploadImageMessage(
              link: "SendMessageImage",
              id: widget.id,
              recepient: widget.tujuan != users ? widget.tujuan : widget.dari)),
    );
    updateInformation(information);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: Text(
          "Chatting with ${widget.name}",
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.call),
              onPressed: () {
                launch("tel://${widget.call}");
              }),
          PopupMenuButton(
              onSelected: (value) {
                if (value == 0) {
                  viewUser(widget.tujuan);
                } else {
                  viewUser(widget.tujuan);
                }
              },
              itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 0,
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.people, color: Colors.black),
                          SizedBox(width: 8.0),
                          Text("Profile",
                              style: GoogleFonts.poppins(
                                  fontSize: 14.0, color: Color(0xFF70747F))),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 0,
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.pin_drop, color: Colors.black),
                          SizedBox(width: 8.0),
                          Text("Lokasi",
                              style: GoogleFonts.poppins(
                                  fontSize: 14.0, color: Color(0xFF70747F))),
                        ],
                      ),
                    ),
                  ])
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("images/bg.png"), fit: BoxFit.cover)),
              child: Column(
                children: [
                  dataUser == null
                      ? Center(
                          child: Container(),
                        )
                      : SizedBox(
                          height: MediaQuery.of(context).size.height * 0.80,
                          child: ListView.builder(
                              controller: _scrollController,
                              reverse: false,
                              itemCount: dataUser.length == null
                                  ? 0
                                  : dataUser.length + 1,
                              itemBuilder: (BuildContext context, int index) {
                                if (index == dataUser.length ||
                                    dataUser.length == null) {
                                  return _buildProgressIndicator();
                                } else {
                                  return dataUser[index]['sender'] == users
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            dataUser[index]['type'] == "0"
                                                ? Container(
                                                    child: Text(
                                                      "${dataUser[index]['message']}",
                                                      style: GoogleFonts.ptSans(
                                                          fontSize: 18),
                                                    ),
                                                    width: 200,
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            15.0,
                                                            10.0,
                                                            15.0,
                                                            10.0),
                                                    decoration: BoxDecoration(
                                                        color:
                                                            Color(0xFFaadaff),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0)),
                                                    margin: EdgeInsets.only(
                                                        bottom: 10.0,
                                                        right: 10,
                                                        top: 10),
                                                  )
                                                : Container(
                                                    child: dataUser[index]
                                                                ['message'] ==
                                                            null
                                                        ? CircularProgressIndicator()
                                                        : Image.network(
                                                            Config.BASE_URL_IMAGE +
                                                                dataUser[index]
                                                                    ['message'],
                                                            fit: BoxFit.fill,
                                                          ),
                                                    decoration: BoxDecoration(
                                                        color:
                                                            Color(0xFFaadaff),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0)),
                                                    width: 200,
                                                    
                                                    margin: EdgeInsets.only(
                                                        bottom: 10.0,
                                                        right: 10,
                                                        top: 10),
                                                  )
                                          ],
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            dataUser[index]['type'] == "0"
                                                ? Container(
                                                    child: Text(
                                                      "${dataUser[index]['message']}",
                                                      style: GoogleFonts.ptSans(
                                                          fontSize: 18),
                                                    ),
                                                    width: 200,
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            15.0,
                                                            10.0,
                                                            15.0,
                                                            10.0),
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0)),
                                                    margin: EdgeInsets.only(
                                                        bottom: 10.0,
                                                        right: 10,
                                                        top: 10,
                                                        left: 10),
                                                  )
                                                : Container(
                                                    child: dataUser[index]
                                                                ['message'] ==
                                                            null
                                                        ? CircularProgressIndicator()
                                                        : Image.network(
                                                            Config.BASE_URL_IMAGE +
                                                                dataUser[index]
                                                                    ['message'],
                                                            fit: BoxFit.fill,
                                                          ),
                                                    decoration: BoxDecoration(
                                                        color:
                                                            Color(0xFFaadaff),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0)),
                                                    width: 200,
                                                    
                                                    margin: EdgeInsets.only(
                                                        bottom: 10.0,
                                                        right: 10,
                                                        top: 10),
                                                  )
                                          ],
                                        );
                                }
                              }),
                        ),
                  Container(
                    margin:
                        EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 0),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 3,
                          blurRadius: 2,
                          offset: Offset(0, 2), // changes position of shadow
                        ),
                      ],
                    ),
                    child: new ListTile(
                      leading: new IconButton(
                        iconSize: 25,
                        icon: new Icon(
                          Icons.add_photo_alternate,
                          color: Colors.blueGrey,
                        ),
                        onPressed: () {
                          toUpload();
                        },
                      ),
                      title: TextField(
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        autofocus: false,
                        style: GoogleFonts.poppins(),
                        controller: sendController,
                        decoration: new InputDecoration(
                          hintText: 'Type your message here',
                          hintStyle: GoogleFonts.poppins(),
                          border: InputBorder.none,
                        ),
                      ),
                      trailing: new IconButton(
                        icon: new Icon(Icons.send, color: Colors.blueGrey),
                        onPressed: () {
                          sendController.text.length <= 0
                              ? helper.alertLog("Nothing to send")
                              : _sendMessage();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
