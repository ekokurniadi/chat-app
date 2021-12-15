import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:komun_apps/pages/chat/chatdetail.dart';
import 'package:komun_apps/pages/new_chat/chat_room.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabbar/tabbar.dart';
import '../../components/Helper.dart';
import 'package:http/http.dart' as http;
import '../../components/config.dart';
import 'dart:convert';
import 'dart:async';

class CariBantuan extends StatefulWidget {
  @override
  _CariBantuanState createState() => _CariBantuanState();
}

class _CariBantuanState extends State<CariBantuan> {
  final tabController = PageController(initialPage: 0);
  final Helper helper = Helper();
  bool isLoading = false;
  bool prosesLoading = false;
  String idRoom = "";
  String namaPenerima = "";
  String idPenerima = "";
  String idPesan = "";
  Timer timer;
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _getMoreDataMembantu();
      _getMoreDataBantuan();
    });
  }

  List<dynamic> dataMembantu;
  _getMoreDataMembantu() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var idUser = pref.getString("idUser");
    final data = await http
        .post(Config.BASE_URL + "getMembantu", body: {"idUser": idUser});
    Map<String, dynamic> response = jsonDecode(data.body);
    setState(() {
      dataMembantu = response['values'];
    });

    return "Success";
  }

  List<dynamic> dataBantuan;
  _getMoreDataBantuan() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var idUser = pref.getString("idUser");
    final data = await http
        .post(Config.BASE_URL + "getBantuan", body: {"idUser": idUser});
    Map<String, dynamic> response = jsonDecode(data.body);
    setState(() {
      dataBantuan = response['values'];
    });

    return "Success";
  }

   createMessage(String recepientId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var user = sharedPreferences.get('idUser');
    setState(() {
      prosesLoading = true;
    });
    final response = await http.post(Config.BASE_URL + "buat_pesan", body: {
      "pengirim": user,
      "penerima": recepientId,
    });
    final res = jsonDecode(response.body);
	print(res);
    if (res['status'] == "200") {
      setState(() {
        prosesLoading = false;
        idPesan = res['id_pesan'];
        idPenerima = res['penerima'];
      });
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => ChatRoom(idPesan)));
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          bottom: PreferredSize(
              child: TabbarHeader(
                backgroundColor: Colors.white,
                tabs: [
                  Tab(
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.transparent),
                      child: Text("Assist",
                          style: GoogleFonts.poppins(color: Color(0xFF306bdd))),
                    ),
                  ),
                  Tab(
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.transparent),
                      child: Text("Get Help",
                          style: GoogleFonts.poppins(color: Color(0xFF306bdd))),
                    ),
                  ),
                ],
                indicatorColor: Color(0xFF306bdd),
                foregroundColor: Colors.white,
                controller: tabController,
              ),
              preferredSize: Size.fromHeight(kToolbarHeight * 0))),
      body: TabbarContent(
        controller: tabController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          // membantu
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: dataMembantu == null
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
                                  "Nothing to show",
                                  style: GoogleFonts.poppins(),
                                )
                              ],
                            ),
                          ),
                        )
                      : Container(
                          height: MediaQuery.of(context).size.height,
                          child: ListView.builder(
                              itemCount: dataMembantu.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Card(
                                  margin: EdgeInsets.all(8),
                                  elevation: 2,
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    width: MediaQuery.of(context).size.width,
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(
                                                top: 8, left: 8),
                                            child: Text(
                                              "${dataMembantu[index]['userPemohon']}",
                                              style: GoogleFonts.poppins(),
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(
                                                top: 8, left: 8),
                                            child: Row(
                                              children: [
                                                Text(
                                                  "${dataMembantu[index]['tanggal']}",
                                                  style: GoogleFonts.poppins(),
                                                ),
                                                Text(" / "),
                                                Text(
                                                  "${dataMembantu[index]['jam']}",
                                                  style: GoogleFonts.poppins(),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(
                                                top: 8, left: 8),
                                            child: Text(
                                              "${dataMembantu[index]['keterangan']}",
                                              style: GoogleFonts.poppins(),
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(
                                                top: 8, left: 8),
                                            child: Text(
                                              "${dataMembantu[index]['alamat']}",
                                              style: GoogleFonts.poppins(),
                                            ),
                                          ),
                                          Divider(),
                                          Container(
                                            child: Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    print("Terima");
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.only(
                                                        top: 3,
                                                        left: 8,
                                                        bottom: 3,
                                                        right: 8),
                                                    decoration: BoxDecoration(
                                                        color: Colors.green),
                                                    child: Center(
                                                      child: Text(
                                                        "Accept",
                                                        style:
                                                            GoogleFonts.poppins(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    print("Tolak");
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.only(
                                                        top: 3,
                                                        left: 8,
                                                        bottom: 3,
                                                        right: 8),
                                                    decoration: BoxDecoration(
                                                        color: Colors.red),
                                                    child: Center(
                                                      child: Text(
                                                        "Reject",
                                                        style:
                                                            GoogleFonts.poppins(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        ]),
                                  ),
                                );
                              }),
                        ),
                )
              ],
            ),
          ),
          //   bantuan saya
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: dataBantuan == null
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
                                  "Nothing to show",
                                  style: GoogleFonts.poppins(),
                                )
                              ],
                            ),
                          ),
                        )
                      : Container(
                          height: MediaQuery.of(context).size.height,
                          child: ListView.builder(
                              itemCount: dataBantuan.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Card(
                                  margin: EdgeInsets.all(8),
                                  elevation: 2,
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    width: MediaQuery.of(context).size.width,
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(
                                                top: 8, left: 8),
                                            child: Text(
                                              "Nama Pemohon : ${dataBantuan[index]['userPemohon']}",
                                              style: GoogleFonts.poppins(),
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(
                                                top: 8, left: 8),
                                            child: Row(
                                              children: [
                                                Text(
                                                  "Date : ${dataBantuan[index]['tanggal']}",
                                                  style: GoogleFonts.poppins(),
                                                ),
                                                Text(" / "),
                                                Text(
                                                  "Time : ${dataBantuan[index]['jam']}",
                                                  style: GoogleFonts.poppins(),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(
                                                top: 8, left: 8),
                                            child: Text(
                                              "Note : ${dataBantuan[index]['keterangan']}",
                                              style: GoogleFonts.poppins(),
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(
                                                top: 8, left: 8),
                                            child: Text(
                                              "Address : ${dataBantuan[index]['alamat']}",
                                              style: GoogleFonts.poppins(),
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(
                                                top: 8, left: 8),
                                            child: Text(
                                              "Assistant : ${dataBantuan[index]['pembantu']}",
                                              style: GoogleFonts.poppins(),
                                            ),
                                          ),
                                          Divider(),
                                          Container(
                                            child: Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    print("Batalkan");
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.only(
                                                        top: 3,
                                                        left: 8,
                                                        bottom: 3,
                                                        right: 8),
                                                    decoration: BoxDecoration(
                                                        color: Colors.red),
                                                    child: Center(
                                                      child: Text(
                                                        "Cancel",
                                                        style:
                                                            GoogleFonts.poppins(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    createMessage(
                                                        dataBantuan[index]
                                                            ['recipient']);
                                                  },
                                                  child: Container(
                                                    margin: EdgeInsets.only(
                                                        left: 8),
                                                    padding: EdgeInsets.only(
                                                        top: 3,
                                                        left: 8,
                                                        bottom: 3,
                                                        right: 8),
                                                    decoration: BoxDecoration(
                                                        color: Colors.green),
                                                    child: Center(
                                                      child: Text(
                                                        "Chat",
                                                        style:
                                                            GoogleFonts.poppins(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ]),
                                  ),
                                );
                              }),
                        ),
                )
              ],
            ),
          ),
        ],
      ),
    //   floatingActionButton: Padding(
    //     padding: const EdgeInsets.only(bottom: 50),
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.end,
    //       children: [
    //         FloatingActionButton.extended(
    //           label: Text("Help"),
    //           onPressed: () {
    //             print("hello");
    //           },
    //           icon: Icon(Icons.help),
    //         ),
    //         SizedBox(height: 5),
    //         FloatingActionButton.extended(
    //           label: Text("List Security"),
    //           onPressed: () {
    //             print("hello");
    //           },
    //           icon: Icon(Icons.list),
    //         ),
    //       ],
    //     ),
    //   ),
    );
  }
}
