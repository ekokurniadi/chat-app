import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:komun_apps/components/Helper.dart';
import 'package:komun_apps/components/constanta.dart';
import 'package:komun_apps/components/uploadImage.dart';
import 'package:komun_apps/pages/komunitas/editKomunitas.dart';
import 'package:komun_apps/pages/user/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/config.dart';

class DetailKomunitas extends StatefulWidget {
  final String index;

  DetailKomunitas({this.index});
  @override
  _DetailKomunitasState createState() => _DetailKomunitasState();
}

class _DetailKomunitasState extends State<DetailKomunitas> {
  final Helper helper = Helper();
  bool prosesGetById = false;
  String namaKomunitas = "";
  String tentang = "";
  String info = "";
  String pengikut = "0";
  String lokasi = "";
  String cover = "";
  String contact = "";
  String post = "";
  String idUser = "";
  String admin = "";
  _getHeader() async {
    final response = await http
        .post(Config.BASE_URL + "getById", body: {"id": widget.index});
    final res = jsonDecode(response.body);

    if (res['status'] == 200) {
      setState(() {
        namaKomunitas = res['values']['nama_komunitas'];
        info = res['values']['info'];
        pengikut = res['values']['pengikut'];
        lokasi = res['values']['lokasi'];
        cover = res['values']['cover'];
        tentang = res['values']['tentang'];
        contact = res['values']['contact'];
        post = res['values']['post'];
        admin = res['values']['admin'];
      });
    }
    return "Success";
  }

  List<dynamic> album;
  _getDetailAlbum() async {
    final response = await http
        .post(Config.BASE_URL + "getAlbum", body: {"id": widget.index});
    Map<String, dynamic> res = jsonDecode(response.body);

    setState(() {
      album = res['values'];
    });
    // print(album);
    return "Success";
  }

  delete(id, foto) async {
    final response = await http.post(Config.BASE_URL + "deleteAlbumById",
        body: {"id": id, "foto": foto});
    final res = jsonDecode(response.body);
    if (res['status'] == 200) {
      helper.alertLog(res['message']);
      _getDetailAlbum();
      _getHeader();
    }
  }

  void showImages(networkImage, id) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            insetPadding: EdgeInsets.zero,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Photo',
                ),
                Visibility(
                  visible: admin == idUser ? true : false,
                  child: IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        delete(id, networkImage);
                      }),
                )
              ],
            ),
            content: Container(
              width: MediaQuery.of(context).size.width * 0.90,
              height: MediaQuery.of(context).size.height * 0.50,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(Config.BASE_URL_IMAGE + "$networkImage"),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          );
        });
  }

  _getCurrentUser() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var user = sharedPreferences.get('idUser');
    print("usernya: $user");
    setState(() {
      idUser = user;
    });
  }

  String text = "";
  void updateInformation(String information) {
    setState(() => text = information);
    setState(() {
      text = information;
    });
    _getDetailAlbum();
    _getHeader();
  }

  void toUpload() async {
    final information = await Navigator.push(
      context,
      MaterialPageRoute(
          fullscreenDialog: true,
          builder: (context) => UploadImage(text: "album", id: widget.index)),
    );
    updateInformation(information);
  }

  void toEdit() async {
    final information = await Navigator.push(
      context,
      MaterialPageRoute(
          fullscreenDialog: true,
          builder: (context) => EditKomunitas(id: widget.index)),
    );
    updateInformation(information);
  }

  @override
  void initState() {
    super.initState();
    _getHeader();
    _getDetailAlbum();
    _getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: Text(
          "$namaKomunitas",
          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),
      floatingActionButton: idUser == admin
          ? FloatingActionButton(
              onPressed: () {
                toUpload();
              },
              child: Icon(Icons.add_a_photo),
            )
          : Container(),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                        Config.BASE_URL_IMAGE + "$cover",
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: Colors.pink),
                                padding: EdgeInsets.all(5),
                                child: Text("$post Post",
                                    style: GoogleFonts.poppins(
                                        color: Colors.white)),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        fullscreenDialog: true,
                                        builder: (context) =>
                                            User(id: widget.index)),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: primaryColor,
                                  ),
                                  padding: EdgeInsets.all(5),
                                  child: Text("$pengikut Followers",
                                      style: GoogleFonts.poppins(
                                          color: Colors.white)),
                                ),
                              ),
                              idUser == admin
                                  ? IconButton(
                                      icon: Icon(Icons.more_horiz),
                                      onPressed: () {
                                        toEdit();
                                      })
                                  : Container()
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 5),
                            child: Text("$namaKomunitas",
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500)),
                          ),
                          Container(
                            padding: EdgeInsets.all(5),
                            width: MediaQuery.of(context).size.width * 0.70,
                            child:
                                Text("$tentang", style: GoogleFonts.poppins()),
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 5),
                            child: Text("$info", style: GoogleFonts.poppins()),
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 5),
                            child:
                                Text("$contact", style: GoogleFonts.poppins()),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Divider(),
            Container(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Feeds",
                style: GoogleFonts.poppins(color: Colors.blueGrey),
              ),
            ),
            album == null
                ? Center(
                    child: Text("Nothing to show"),
                  )
                : Container(
                    height: MediaQuery.of(context).size.height * 0.80,
                    child: GridView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3),
                        itemCount: album.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              showImages("${album[index]['foto']}",
                                  album[index]['id']);
                            },
                            child: Container(
                              color: Colors.blueGrey,
                              padding: EdgeInsets.all(2),
                              margin: EdgeInsets.all(0.5),
                              child: Image.network(
                                Config.BASE_URL_IMAGE + album[index]['foto'],
                                fit: BoxFit.fill,
                              ),
                            ),
                          );
                        }),
                  ),
            Container(
              height: 100,
            )
          ],
        ),
      ),
    );
  }
}
