import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:komun_apps/components/config.dart';
import 'package:komun_apps/components/constanta.dart';
import 'package:http/http.dart' as http;
import 'package:komun_apps/pages/chat/chatdetail.dart';
import 'package:komun_apps/pages/chat/create_chat.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Chat extends StatefulWidget {
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  bool prosesLoading;
  bool controllerSearchValue;
  TextEditingController controllerSearch = TextEditingController();
  String filter = "";
  ScrollController _scrollController = new ScrollController();
  int page = 20;
  bool isLoading = false;

  List<dynamic> dataUser;
  _getMoreData(int index, String filter) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var user = sharedPreferences.get('idUser');
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });
      var url = await http.post(Config.BASE_URL + "getChatRoom", body: {
        "start": "0",
        "length": index.toString(),
        "draw": "1",
        "searching": "$filter",
        "id": user
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

  Timer timer;
  @override
  void initState() {
    super.initState();
    controllerSearchValue = false;
    _getMoreData(page, filter);
    // _scrollController.addListener(() {
    //   if (_scrollController.position.pixels ==
    //       _scrollController.position.maxScrollExtent) {
    //     _getMoreData(page, filter);
    //   }
    // });
    timer = Timer.periodic(Duration(seconds: 2), (Timer t) {
      _getMoreData(page, filter);
    });
  }

  createMessage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => CreateChat()));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50.0),
        child: FloatingActionButton(
          onPressed: () {
            createMessage();
          },
          child: Icon(Icons.message),
        ),
      ),
       backgroundColor: Color(0xFFf4f4f4),
      body: SingleChildScrollView(
        child: Column(
          children: [
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
                    hintText: 'Pencarian',
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
                      });
                    } else {
                      setState(() {
                        controllerSearchValue = true;
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
                          return Container(
                            
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.white70
                            ),
                            margin: EdgeInsets.only(bottom: 5,left:3,right:3),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: dataUser[index]['fotoTujuan'] == null ? Image.asset("images/add-photo.png") : NetworkImage(
                                  Config.BASE_URL_IMAGE +
                                      "${dataUser[index]['fotoTujuan']}",
                                ),
                              ),
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    child: Text(
                                      "${dataUser[index]['namaTujuan']}",
                                      style: GoogleFonts.poppins(),
                                    ),
                                  ),
                                  Container(child: Text("${dataUser[index]['time']}",style: GoogleFonts.poppins(fontSize:12),),)
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ChatDetail(
                                          id: dataUser[index]['idRoom'],
                                          name: dataUser[index]['namaTujuan'],
                                          tujuan: dataUser[index]['idTo'])),
                                );
                              },
                            ),
                          );
                        }),
                  ),
          ],
        ),
      ),
    );
  }
}
