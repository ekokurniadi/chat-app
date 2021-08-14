import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:komun_apps/pages/notif/createBroadcastMessageCommunity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/config.dart';
import '../../components/Helper.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<dynamic> dataList;
  final Helper helper = Helper();
  String levelUser = "";
  Future<String> getNotif() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var idUser = pref.getString("idUser");
    final response = await http.post(Config.BASE_URL + "getNotif",
        body: {"id": idUser, "deleted": "0"});
    Map<String, dynamic> map = jsonDecode(response.body);
    setState(() {
      dataList = map["values"];
    });
    // print(dataList);
    return "Success";
  }

  _getCurrent() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var level = pref.getString("level");
    setState(() {
      levelUser = level;
    });
  }

  Timer timeNotif;
  @override
  void initState() {
    super.initState();
    getNotif();
    _getCurrent();
    timeNotif = Timer.periodic(Duration(seconds: 2), (Timer tim) => getNotif());
  }

  _updateNotif(String id, String status, String delete) async {
    final response =
        await http.post(Config.BASE_URL + "updateStatusNotif", body: {
      "id": id,
      "status": status,
      "deleted": delete,
    });
    final res = jsonDecode(response.body);
    if (res["status"] == 200) {
      helper.alertSuccess(res['message'], context);
    }
  }

  @override
  void dispose() {
    super.dispose();
    timeNotif?.cancel();
  }

  createBroadcastMessage(){
     Navigator.push(
        context, MaterialPageRoute(builder: (context) => CreateBroadcastMessageCommunity()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: levelUser == "user"
          ? Padding(
              padding: const EdgeInsets.only(bottom: 50.0),
              child: FloatingActionButton(
                onPressed: () {
                  createBroadcastMessage();
                },
                child: Icon(Icons.message),
              ),
            )
          : Container(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            dataList == null
                ? Center(
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "images/empty.jpg",
                            fit: BoxFit.contain,
                            width: 250,
                          ),
                          Text(
                            "Tidak ada data",
                            style: GoogleFonts.poppins(),
                          )
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: dataList.length,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          top: 2.0,
                          left: 5.0,
                          right: 5.0,
                        ),
                        child: Card(
                          elevation: 2,
                          child: ClipPath(
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: EdgeInsets.all(8.0),
                                    child: Text(
                                      "${dataList[index][0]}",
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Divider(),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          child: Text(
                                              "${dataList[index][2]} / ${dataList[index][3]}",
                                              style: TextStyle(
                                                fontSize: 13.0,
                                              )),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            _updateNotif(
                                                dataList[index][4], "1", "1");
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(5.0),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(50.0),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.delete,
                                                  size: 12.0,
                                                  color: Colors.white,
                                                ),
                                                Text(
                                                  "Hapus",
                                                  style: TextStyle(
                                                      fontSize: 12.0,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.white),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        dataList[index][1] == "0"
                                            ? GestureDetector(
                                                onTap: () {
                                                  _updateNotif(
                                                      dataList[index][4],
                                                      "1",
                                                      "0");
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(5.0),
                                                  decoration: BoxDecoration(
                                                    color: Colors.green,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50.0),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.check,
                                                        size: 12.0,
                                                        color: Colors.white,
                                                      ),
                                                      Text(
                                                        " Sudah dibaca",
                                                        style: TextStyle(
                                                            fontSize: 12.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : Container(),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
