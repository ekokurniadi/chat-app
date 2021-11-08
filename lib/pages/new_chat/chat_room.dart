import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:komun_apps/components/uploadImageMessage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/config.dart';
import '../../components/Helper.dart';

class ChatRoom extends StatefulWidget {
  final String id;
  ChatRoom(this.id);

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  _ChatRoomState() {
    fm.configure(
      onLaunch: (Map<String, dynamic> msg) async {
        if (msg['data']['screen'] == 'list_trx' &&
            msg['notification']['body'] != null) {
          helper.alertLog(msg['notification']['body']);
          getMessage();
        } else if (msg['data']['screen'] == 'list_notif') {
          helper.alertLog(msg['notification']['body']);
          getMessage();
        }
      },
      onResume: (Map<String, dynamic> msg) async {
        if (msg['data']['screen'] == 'list_trx' &&
            msg['notification']['body'] != null) {
          helper.alertLog(msg['notification']['body']);
          getMessage();
        } else if (msg['data']['screen'] == 'list_notif') {
          helper.alertLog(msg['notification']['body']);
          getMessage();
        }
      },
      onMessage: (Map<String, dynamic> msg) async {
        if (msg['data']['screen'] == 'list_trx' &&
            msg['notification']['body'] != null) {
          helper.alertLog(msg['notification']['body']);
          getMessage();
        } else if (msg['data']['screen'] == 'list_notif') {
          helper.alertLog(msg['notification']['body']);
          getMessage();
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getData();
    getMessage();
  }

  TextEditingController sendController = TextEditingController();
  FirebaseMessaging fm = FirebaseMessaging();
  final Helper helper = Helper();
  String nama;
  String idPenerima;
  String tokenFcm;

  getData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var userId = pref.getString("idUser");
    getCurrent();
    final request = await http.post(Config.BASE_URL + "get_detail_room",
        body: {"id": widget.id, "user_id": userId});

    final response = jsonDecode(request.body);
    print(response);
    if (response["status"] == 200) {
      setState(() {
        nama = response["nama"];
        idPenerima = response["id_penerima"];
        tokenFcm = response["token_fcm"];
      });
    } else {
      helper.alertLog("Terjadi kesalahan");
    }
  }

  ScrollController _scrollController = new ScrollController();
  List<dynamic> dataList;
  getMessage() async {
    final request = await http
        .post(Config.BASE_URL + "get_detail_pesan", body: {"id": widget.id});
    Map<String, dynamic> response = jsonDecode(request.body);
    setState(() {
      dataList = response["data"];
    });
    print(response);
  }

  String users = "";
  getCurrent() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var user = sharedPreferences.get('idUser');
    setState(() {
      users = user;
    });
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

  bool isLoading = false;
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

  String text = "";
  void updateInformation(String information) {
    setState(() => text = information);
    setState(() {
      text = information;
    });
    getMessage();
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
              recepient:idPenerima )),
    );
    updateInformation(information);
  }

  _kirimPesan() async {
    final request = await http.post(Config.BASE_URL + "kirim_pesan", body: {
      "kode_pesan": widget.id,
      "pengirim": users,
      "penerima": idPenerima,
      "token_fcm": tokenFcm,
      "jenis_pesan": "0",
      "isi_pesan": sendController.text,
      "hapus_by_pengirim": "0",
      "hapus_by_penerima": "0"
    });
    final response = jsonDecode(request.body);

    if (response["status"] == 200) {
      sendController.clear();
      getMessage();
    }
  }

  _scrollToBottom() {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0c53a0),
        elevation: 0,
        title: Text(
          "Chatting with $nama",
          style: GoogleFonts.poppins(color: Colors.white),
        ),
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
                  dataList == null
                      ? Center(child: CircularProgressIndicator())
                      : SizedBox(
                          height: MediaQuery.of(context).size.height * 0.80,
                          child: ListView.builder(
                              controller: _scrollController,
                              reverse: false,
                              itemCount: dataList.length == null
                                  ? 0
                                  : dataList.length + 1,
                              itemBuilder: (BuildContext context, int index) {
                                if (index == dataList.length ||
                                    dataList.length == null) {
                                  return _buildProgressIndicator();
                                } else {
                                  return dataList[index]['pengirim'] == users
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            dataList[index]['jenis_pesan'] ==
                                                    "0"
                                                ? Container(
                                                    child: Text(
                                                      "${dataList[index]['isi_pesan']}",
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
                                                    child: dataList[index]
                                                                ['isi_pesan'] ==
                                                            null
                                                        ? CircularProgressIndicator()
                                                        : Image.network(
                                                            Config.BASE_URL_IMAGE +
                                                                dataList[index][
                                                                    'isi_pesan'],
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
                                            dataList[index]['jenis_pesan'] ==
                                                    "0"
                                                ? Container(
                                                    child: Text(
                                                      "${dataList[index]['isi_pesan']}",
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
                                                    child: dataList[index]
                                                                ['isi_pesan'] ==
                                                            null
                                                        ? CircularProgressIndicator()
                                                        : Image.network(
                                                            Config.BASE_URL_IMAGE +
                                                                dataList[index][
                                                                    'isi_pesan'],
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
                              : _kirimPesan();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
