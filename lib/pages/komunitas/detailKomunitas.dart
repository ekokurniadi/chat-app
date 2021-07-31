import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:komun_apps/components/constanta.dart';
import '../../components/config.dart';

class DetailKomunitas extends StatefulWidget {
  String index;

  DetailKomunitas({this.index});
  @override
  _DetailKomunitasState createState() => _DetailKomunitasState();
}

class _DetailKomunitasState extends State<DetailKomunitas> {
  bool prosesGetById = false;
  String namaKomunitas = "";
  String tentang = "";
  String info = "";
  String pengikut = "0";
  String lokasi = "";
  String cover = "";
  String contact = "";
  String post = "";
  String idUser ="";
  _getHeader() async {
    final response = await http
        .post(Config.BASE_URL + "getById", body: {"id": widget.index});
    final res = jsonDecode(response.body);
    print(res);
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
      });
    }
    return "Success";
  }

  List<dynamic> album;
  _getDetailAlbum() async {
    final response = await http
        .post(Config.BASE_URL + "getAlbum", body: {"id": widget.index});
    Map<String, dynamic> res = jsonDecode(response.body);
    print(res);
    setState(() {
      album = res['values'];
    });
    // print(album);
    return "Success";
  }

  @override
  void initState() {
    super.initState();
    _getHeader();
    _getDetailAlbum();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: Text(
          "Detail Komunitas",
          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.25,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      child: Image.network(
                        Config.BASE_URL_IMAGE + "$cover",
                        fit: BoxFit.fill,
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
                                  color: Colors.pink
                                ),
                                padding: EdgeInsets.all(5),
                                child: Text("$post Post",
                                    style: GoogleFonts.poppins(color:Colors.white)),
                              ),
                              Container(
                                padding: EdgeInsets.all(5),
                                child: Text("$pengikut Pengikut",
                                    style: GoogleFonts.poppins()),
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 5),
                            child: Text("$namaKomunitas",
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
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
                "Postingan",
                style: GoogleFonts.poppins(color: Colors.blueGrey),
              ),
            ),
            album == null
                ? Center(
                    child: Text("Belum ada Postingan dari komunitas ini"),
                  )
                : Container(
                    height: MediaQuery.of(context).size.height * 0.80,
                    child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4),
                        itemCount: album.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            color: Colors.blue,
                            padding: EdgeInsets.all(3),
                            margin: EdgeInsets.all(1),
                            child: Center(
                              child: Image.network(
                                Config.BASE_URL_IMAGE + album[index]['foto'],
                                fit: BoxFit.contain,
                              ),
                            ),
                          );
                        }),
                  )
          ],
        ),
      ),
    );
  }
}
