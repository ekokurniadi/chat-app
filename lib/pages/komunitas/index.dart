import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:komun_apps/components/constanta.dart';
import 'package:komun_apps/pages/komunitas/buatKomunitas.dart';
import 'package:komun_apps/pages/komunitas/detailKomunitas.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/config.dart';

class Index extends StatefulWidget {
  @override
  _IndexState createState() => _IndexState();
}

class _IndexState extends State<Index> {
  bool controllerSearchValue;
  TextEditingController controllerSearch = TextEditingController();
  String filter = "";
  List<dynamic> dataBeranda;
  _getMoreData(String filter) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var idUser = pref.getString("idUser");
    final data = await http.post(Config.BASE_URL + "getKomunitasByuserID",
        body: {"filter": filter, "idUser": idUser});
    Map<String, dynamic> response = jsonDecode(data.body);
    setState(() {
      dataBeranda = response['values'];
    });
    return "Success";
  }

  String text = "";
  void updateInformation(String information) {
    setState(() => text = information);
    setState(() {
      text = information;
    });
    _getMoreData("");
  }

  void toCreate() async {
    final information = await Navigator.push(
      context,
      MaterialPageRoute(
          fullscreenDialog: true, builder: (context) => BuatKomunitas()),
    );
    updateInformation(information);
  }

  @override
  void initState() {
    super.initState();
    _getMoreData("");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: Text(
          "List Of Community",
          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          toCreate();
        },
        child: Icon(Icons.add),
      ),
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
                    hintText: 'Search',
                    hintStyle: GoogleFonts.poppins(),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    setState(() {
                      filter = controllerSearch.text;
                      _getMoreData(filter);
                    });
                    if (value == "") {
                      setState(() {
                        controllerSearchValue = false;
                        _getMoreData(filter);
                      });
                    } else {
                      setState(() {
                        controllerSearchValue = true;
                        _getMoreData(filter);
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
                      _getMoreData(filter);
                    });
                  },
                ),
              ),
            ),
            dataBeranda == null
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
                            "Data not found",
                            style: GoogleFonts.poppins(),
                          )
                        ],
                      ),
                    ),
                  )
                : Container(
                    height: MediaQuery.of(context).size.height * 0.80,
                    child: ListView.builder(
                      itemCount: dataBeranda.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          padding: EdgeInsets.all(8),
                          margin:
                              EdgeInsets.only(right: 10, left: 10, bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.8),
                                spreadRadius: 2,
                                blurRadius: 3,
                                offset:
                                    Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 0,
                                backgroundImage: NetworkImage(
                                  Config.BASE_URL_IMAGE +
                                      "${dataBeranda[index]['cover']}",
                                  scale: 10,
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    width: MediaQuery.of(context).size.width *
                                        0.75,
                                    margin: EdgeInsets.only(left: 3),
                                    child: Text(
                                      "${dataBeranda[index]['namaKomunitas']}",
                                      style: GoogleFonts.poppins(),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    width: MediaQuery.of(context).size.width *
                                        0.75,
                                    margin: EdgeInsets.only(left: 3),
                                    child: Text(
                                      "${dataBeranda[index]['tentang']}",
                                      style:
                                          GoogleFonts.poppins(fontSize: 12.0),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 3),
                                    child: Text(
                                      "${dataBeranda[index]['pengikut']} pengikut",
                                      style:
                                          GoogleFonts.poppins(fontSize: 12.0),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  DetailKomunitas(
                                                      index: dataBeranda[index]
                                                          ['id'])));
                                    },
                                    child: Container(
                                      margin: EdgeInsets.all(5),
                                      padding: EdgeInsets.only(
                                          top: 3, bottom: 3, left: 8, right: 8),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          color: Colors.blue),
                                      child: Text(
                                        "Detail",
                                        style: GoogleFonts.poppins(
                                            color: Colors.white),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  )
          ],
        ),
      ),
    );
  }
}
