import 'dart:convert';
import 'dart:async';
// ignore: unused_import
import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:komun_apps/pages/addMob.dart';
import 'package:komun_apps/pages/chat/create_chat.dart';
import 'package:komun_apps/pages/new_chat/chat_room.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:komun_apps/components/Helper.dart';
import 'package:komun_apps/components/config.dart';
import 'package:http/http.dart' as http;

class ListChat extends StatefulWidget {
  @override
  _ListChatState createState() => _ListChatState();
}

class _ListChatState extends State<ListChat> {
  // inisialisai
  bool prosesLoading = false;
  bool controllerSearchValue;
  TextEditingController controllerSearch = TextEditingController();
  String filter = "";
  ScrollController _scrollController = new ScrollController();
  int page = 20;
  bool isLoading = false;
  final Helper helper = Helper();
  FirebaseMessaging fm = FirebaseMessaging();
  String users = "";

  _ListChatState() {
    fm.configure(
      onLaunch: (Map<String, dynamic> msg) async {
        // print("ketika sedang berjalan");
        // print(msg);

        if (msg['data']['screen'] == 'list_trx' &&
            msg['notification']['body'] != null) {
          helper.alertLog(msg['notification']['body']);
          _getMoreData(page, filter);
        } else if (msg['data']['screen'] == 'list_notif') {
          helper.alertLog(msg['notification']['body']);
          _getMoreData(page, filter);
        }
      },
      onResume: (Map<String, dynamic> msg) async {
        // print("ketika sedang berjalan");
        // print(msg);

        if (msg['data']['screen'] == 'list_trx' &&
            msg['notification']['body'] != null) {
          helper.alertLog(msg['notification']['body']);
          _getMoreData(page, filter);
        } else if (msg['data']['screen'] == 'list_notif') {
          helper.alertLog(msg['notification']['body']);
          _getMoreData(page, filter);
        }
      },
      onMessage: (Map<String, dynamic> msg) async {
        // print("ketika sedang berjalan");
        // print(msg);
        if (msg['data']['screen'] == 'list_trx' &&
            msg['notification']['body'] != null) {
          helper.alertLog(msg['notification']['body']);
          _getMoreData(page, filter);
        } else if (msg['data']['screen'] == 'list_notif') {
          helper.alertLog(msg['notification']['body']);
          _getMoreData(page, filter);
        }
      },
    );
  }

  String smallSentence(String bigSentence) {
    if (bigSentence.length > 30) {
      return bigSentence.substring(0, 30) + '...';
    } else {
      return bigSentence;
    }
  }

  List<dynamic> dataUser;
  _getMoreData(int index, String filter) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var user = sharedPreferences.get('idUser');
    setState(() {
      users = user;
    });

    if (!isLoading) {
      setState(() {
        isLoading = true;
      });
      var url = await http.post(Config.BASE_URL + "list_pesan", body: {
        "start": "0",
        "length": index.toString(),
        "draw": "1",
        "searching": "$filter",
        "id_user": user
      });
      // final response = jsonDecode(url.body);
      Map<String, dynamic> response = jsonDecode(url.body);
      if (this.mounted) {
        setState(() {
          dataUser = response["data"];
          isLoading = false;
          page++;
        });
      }
    }
  }

  deletePesan(String id) async {
    setState(() {
      prosesLoading = true;
    });
    final request = await http.post(Config.BASE_URL + "delete_pesan",
        body: {"id": id, "user_id": users});
    final response = jsonDecode(request.body);
    if (response["status"] == 200) {
      helper.alertLog("Berhasil menghapus pesan");
      _getMoreData(page, filter);
      setState(() {
        prosesLoading = false;
      });
    } else {
      helper.alertLog("Gagal menghapus pesan");
      _getMoreData(page, filter);
      setState(() {
        prosesLoading = false;
      });
    }
  }

  Timer timer;
  @override
  void initState() {
    super.initState();
    prosesLoading = false;
    controllerSearchValue = false;
    _getMoreData(page, filter);
    timer = Timer.periodic(Duration(seconds: 5), (Timer t) {
      _getMoreData(page, filter);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _getMoreData(page, filter);
  }

  void openChat(String id) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ChatRoom(id)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: ModalProgressHUD(
          inAsyncCall: prosesLoading,
          opacity: 0.5,
          progressIndicator: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Color(0xFF0c53a0)),
          ),
          child: Column(
            children: [
              AdMobPage(),
              Container(
                margin: EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 8),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
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
                  leading: new Icon(
                    Icons.search,
                  ),
                  title: TextField(
                    autofocus: false,
                    style: GoogleFonts.poppins(),
                    controller: controllerSearch,
                    decoration: new InputDecoration(
                      hintText: 'Search',
                      hintStyle: GoogleFonts.poppins(),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      setState(() {
                        filter = controllerSearch.text;
                        _getMoreData(page, filter);
                      });
                      if (value == "") {
                        setState(() {
                          controllerSearchValue = false;
                          _getMoreData(page, filter);
                        });
                      } else {
                        setState(() {
                          controllerSearchValue = true;
                          _getMoreData(page, filter);
                        });
                      }
                    },
                  ),
                  trailing: new IconButton(
                    icon: new Icon(
                      Icons.cancel,
                      color: controllerSearchValue == true
                          ? Colors.blueGrey
                          : Colors.transparent,
                    ),
                    onPressed: () {
                      controllerSearch.clear();
                      setState(() {
                        filter = "";
                        controllerSearchValue = false;
                      });
                      setState(() {
                        _getMoreData(page, filter);
                      });
                    },
                  ),
                ),
              ),
              dataUser == null
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : SizedBox(
                      height: MediaQuery.of(context).size.height * 0.80,
                      child: ListView.builder(
                          controller: _scrollController,
                          itemCount: dataUser.length,
                          itemBuilder: (BuildContext context, int index) {
							  
                            return dataUser[index]["hapus_by_pengirim"] == users
                                ? Container()
                                : GestureDetector(
                                    onTap: () =>
                                        openChat(dataUser[index]["id_pesan"]),
                                    child: Card(
                                      margin: EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 8),
                                      elevation: 3,
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            color: Colors.white),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                dataUser[index]["foto_pengirim"] ==
                                                            null ||
                                                        dataUser[index][
                                                                "foto_pengirim"] ==
                                                            ""
                                                    ? CircularProgressIndicator()
                                                    : CircleAvatar(
                                                        backgroundImage:
                                                            NetworkImage(Config
                                                                    .BASE_URL_IMAGE +
                                                                dataUser[index][
                                                                    "foto_pengirim"])),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Row(
                                                  children: [
                                                    Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                          child: Text(
                                                              dataUser[index][
                                                                  "nama_penerima"],
                                                              style: GoogleFonts.poppins(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                        ),
                                                        Container(
                                                          child: dataUser[index]
                                                                      [
                                                                      "tipe_pesan"] ==
                                                                  "0"
                                                              ? Container(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      2,
                                                                  child: Text(
                                                                      smallSentence(
                                                                          dataUser[index]
                                                                              [
                                                                              "pesan_terakhir"]),
                                                                      style: GoogleFonts
                                                                          .poppins()),
                                                                )
                                                              : Row(
                                                                  children: [
                                                                    Icon(
                                                                      Icons
                                                                          .photo_size_select_actual,
                                                                      color: Colors
                                                                          .grey,
                                                                    ),
                                                                    Text(
                                                                        "picture",
                                                                        style: GoogleFonts
                                                                            .poppins()),
                                                                  ],
                                                                ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Align(
                                                      alignment:
                                                          Alignment.topRight,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: [
                                                          Text(dataUser[index]
                                                              ["jam_pesan"]),
                                                          PopupMenuButton(
                                                            padding:
                                                                EdgeInsets.zero,
                                                            onSelected:
                                                                (value) {
                                                              if (value == 0) {
                                                                deletePesan(dataUser[
                                                                        index][
                                                                    "id_pesan"]);
                                                              }
                                                            },
                                                            offset:
                                                                const Offset(
                                                                    0, 300),
                                                            icon: Icon(
                                                                Icons.more_vert,
                                                                color: Color(
                                                                    0xFF2c406e)),
                                                            itemBuilder:
                                                                (context) => [
                                                              PopupMenuItem(
                                                                value: 0,
                                                                child: Row(
                                                                  children: <
                                                                      Widget>[
                                                                    Text(
                                                                        "Delete",
                                                                        style: GoogleFonts.poppins(
                                                                            fontSize:
                                                                                14.0,
                                                                            color:
                                                                                Color(0xFF70747F))),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      )),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                          }),
                    )
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50),
        child: FloatingActionButton(
          backgroundColor: Colors.green,
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => CreateChat())),
          child: Icon(Icons.message),
        ),
      ),
    );
  }
}
