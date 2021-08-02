import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:komun_apps/components/constanta.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import '../../components/config.dart';

class User extends StatefulWidget {
  final String id;

  User({this.id});

  @override
  _UserState createState() => _UserState();
}

class _UserState extends State<User> {
  bool prosesLoading;
  bool controllerSearchValue;
  TextEditingController controllerSearch = TextEditingController();
  String filter = "";
  ScrollController _scrollController = new ScrollController();
  int page = 20;
  bool isLoading = false;

  List<dynamic> dataUser;
  _getMoreData(int index, String filter) async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });
      var url = await http.post(Config.BASE_URL + "fetch_data", body: {
        "start": "0",
        "length": index.toString(),
        "draw": "1",
        "searching": "$filter",
        "id": widget.id
      });
      // final response = jsonDecode(url.body);
      Map<String, dynamic> response = jsonDecode(url.body);

      print("$index");
      setState(() {
        dataUser = response["data"];
        isLoading = false;
        page++;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    controllerSearchValue = false;
    _getMoreData(page, filter);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getMoreData(page, filter);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: isLoading ? 1.0 : 00,
          child: new CircularProgressIndicator(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: Text(
          "Daftar Pengikut",
          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
          inAsyncCall: isLoading,
          child: SingleChildScrollView(
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
                            itemCount: dataUser.length == null
                                ? 0
                                : dataUser.length + 1,
                            itemBuilder: (BuildContext context, int index) {
                              if (index == dataUser.length ||
                                  dataUser.length == null) {
                                return _buildProgressIndicator();
                              } else {
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      Config.BASE_URL_IMAGE +
                                          "${dataUser[index][3]}",
                                    ),
                                  ),
                                  title: Row(
                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        child: Text(
                                          "${dataUser[index][2]}",
                                          style: GoogleFonts.poppins(),
                                        ),
                                      ),
                                      IconButton(
                                          icon: Icon(CupertinoIcons.mail_solid,color: Colors.blueGrey,),
                                          onPressed: (){})
                                    ],
                                  ),
                                  onTap: (){
                                    print("Hello");
                                  },
                                );
                              }
                            }),
                      ),
              ],
            ),
          )),
    );
  }
}