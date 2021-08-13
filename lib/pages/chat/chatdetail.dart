import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/Helper.dart';
import '../../components/config.dart';
import '../../components/constanta.dart';

class ChatDetail extends StatefulWidget {
  final String id;
  final String name;
  final String tujuan;
  ChatDetail({this.id, this.name, this.tujuan});

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

      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
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
    final response = await http.post(Config.BASE_URL + "sendMessage", body: {
      "id_chat": widget.id,
      "message": sendController.text,
      "sender": users,
      "recipient": widget.tujuan
    });
    setState(() {
      sendController.clear();
    });
    final res = jsonDecode(response.body);
    if (res['status'] == "200") {
      _getMoreData(page);
    }
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
    });
    timer = Timer.periodic(Duration(milliseconds: 200), (Timer t) {
      _getMoreData(page);
    });
    // _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
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
                                            Container(
                                              child: Text(
                                                  "${dataUser[index]['message']}"),
                                              width: 200,
                                              padding: EdgeInsets.fromLTRB(
                                                  15.0, 10.0, 15.0, 10.0),
                                              decoration: BoxDecoration(
                                                  color: Color(0xFFaadaff),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0)),
                                              margin: EdgeInsets.only(
                                                  bottom: 10.0, right: 10,top:10),
                                            )
                                          ],
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              child: Text(
                                                  "${dataUser[index]['message']}"),
                                              width: 200,
                                              padding: EdgeInsets.fromLTRB(
                                                  15.0, 10.0, 15.0, 10.0),
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0)),
                                              margin: EdgeInsets.only(
                                                  bottom: 10.0, right: 10,top:10,left: 10),
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