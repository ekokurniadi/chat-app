import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:komun_apps/components/constanta.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import '../../components/config.dart';
import '../../components/Helper.dart';

class CreateBroadcastMessageCommunity extends StatefulWidget {
  @override
  _CreateBroadcastMessageCommunityState createState() =>
      _CreateBroadcastMessageCommunityState();
}

class _CreateBroadcastMessageCommunityState
    extends State<CreateBroadcastMessageCommunity> {
  List selected = [];
  List selectedforUi;
  List dataUser;
  bool prosesLoading;
  bool controllerSearchValue;
  TextEditingController controllerSearch = TextEditingController();
  TextEditingController _pesan = TextEditingController();
  String filter = "";
  ScrollController _scrollController = new ScrollController();
  int page = 20;
  bool isLoading = false;
  final Helper helper = Helper();
  _getMoreData(int index, String filter) async {
    // SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    // var user = sharedPreferences.get('idUser');
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });
      var url = await http.post(Config.BASE_URL + "fetch_komunitas", body: {
        "start": "0",
        "length": index.toString(),
        "draw": "1",
        "searching": "$filter",
      });
      // final response = jsonDecode(url.body);
      final response = jsonDecode(url.body);

      print("$index");

      setState(() {
        dataUser = response['data'];
        isLoading = false;
        page++;
      });
    }
  }

  test() async {
    final response = await http.post(Config.BASE_URL + "broadcastMessage",
        body: {"arrayId": selected.toString(), "pesan": _pesan.text});
    final res = jsonDecode(response.body);
    print(res);
  }

  @override
  void initState() {
    super.initState();
    prosesLoading = false;
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
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          elevation: 0,
          title: Text(
            "Broadcast Message",
            style: GoogleFonts.poppins(color: Colors.white),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.red,
          label: Text("Pilih Komunitas"),
          onPressed: () {
            showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                builder: (context) {
                  return StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                    return Container(
                      height: MediaQuery.of(context).size.height * 0.80,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                
                              },
                              child: Container(
                                margin: EdgeInsets.all(8),
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Center(
                                  child: Text(
                                    "Tutup dan simpan",
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  top: 8, left: 8, right: 8, bottom: 8),
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 3,
                                    blurRadius: 2,
                                    offset: Offset(
                                        0, 2), // changes position of shadow
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
                                  onChanged: (value) async {
                                    setState(() {
                                      filter = controllerSearch.text;
                                      _getMoreData(page, filter);
                                    });
                                    if (value == "") {
                                      setState(() {
                                        controllerSearchValue = true;
                                        _getMoreData(page, filter);
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
                                  onPressed: () async {
                                    controllerSearch.clear();
                                    setState(() {
                                      filter = "";
                                      controllerSearchValue = false;
                                    });
                                    setState(() {
                                      _getMoreData(page, "");
                                    });
                                  },
                                ),
                              ),
                            ),
                            Wrap(
                              children: dataUser.map((e) {
                                if (e['isChecked'] == true) {
                                  return Card(
                                    elevation: 2,
                                    color: primaryColor,
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        e['nama_komunitas'],
                                        style: GoogleFonts.poppins(
                                            color: Colors.white),
                                      ),
                                    ),
                                  );
                                } else {
                                  return Container();
                                }
                              }).toList(),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Column(
                              children: dataUser.map((e) {
                                return CheckboxListTile(
                                    value: e['isChecked'],
                                    title: Text(e['nama_komunitas']),
                                    onChanged: (bool newValue) {
                                      setState(() {
                                        e['isChecked'] = newValue;
                                      });
                                      if (e['isChecked'] == true) {
                                        selected.add(
                                          e['id'],
                                        );
                                      } else {
                                        selected.removeLast();
                                      }
                                      print(selected);
                                    });
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    );
                  });
                });
          },
          icon: Icon(Icons.people_outline),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 14, left: 24, right: 24),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: primaryColor),
                    borderRadius: BorderRadius.circular(10)),
                child: Center(
                  child: TextField(
                    minLines:
                        6, // any number you need (It works as the rows for the textarea)
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    style: GoogleFonts.poppins(color: primaryColor),
                    controller: _pesan,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(left: 24, top: 14.0),
                      hintText: "Type your message...",
                      hintStyle: GoogleFonts.poppins(color: Colors.blueGrey),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () => _pesan.text.length <= 0 || selected.length == 0
                    ? helper.alertLog("Nothing to send")
                    : test(),
                child: Container(
                  margin: EdgeInsets.only(top: 5),
                  width: MediaQuery.of(context).size.width * 0.80,
                  height: 40,
                  decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(10)),
                  child: Center(
                      child: Text("SEND",
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: Colors.white))),
                ),
              ),
            ],
          ),
        ));
  }
}
