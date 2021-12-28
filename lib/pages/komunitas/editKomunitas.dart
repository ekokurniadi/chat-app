import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:komun_apps/components/uploadImageDemo.dart';
import 'package:komun_apps/pages/home/home.dart';
import '../../components/Helper.dart';
import '../../components/config.dart';
import '../../components/constanta.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'dart:convert';

class EditKomunitas extends StatefulWidget {
  final String id;
  EditKomunitas({this.id});
  @override
  _EditKomunitasState createState() => _EditKomunitasState();
}

class _EditKomunitasState extends State<EditKomunitas> {
  bool prosesLogin = false;
  String imageUser;
  final TextEditingController _nama = new TextEditingController();
  final TextEditingController _tentang = new TextEditingController();
  final TextEditingController _kegiatan = new TextEditingController();
  final TextEditingController _info = new TextEditingController();
  final TextEditingController _lokasi = new TextEditingController();
  final TextEditingController _contact = new TextEditingController();

  _getHeader() async {
    final response = await http
        .post(Config.BASE_URL + "getByIdEdit", body: {"id": widget.id});
    final res = jsonDecode(response.body);
    if (res['status'] == 200) {
      setState(() {
        _nama.text = res['values']['nama_komunitas'];
        _info.text = res['values']['info'];
        _kegiatan.text = res['values']['kegiatan'];
        _lokasi.text = res['values']['lokasi'];
        _tentang.text = res['values']['tentang'];
        _contact.text = res['values']['contact'];
        imageUser = res['values']['cover'];
      });
    }
    return "Success";
  }
  final Helper helper = Helper();

  save() async {
    setState(() {
      prosesLogin = true;
    });
    final response = await http.post(Config.BASE_URL + "editKomunitas", body: {
      "id":widget.id,
      "nama": _nama.text,
      "tentang": _tentang.text,
      "kegiatan": _kegiatan.text,
      "info": _info.text,
      "lokasi": _lokasi.text,
      "contact": _contact.text,
    });
    final res = jsonDecode(response.body);
    if (res['status'] == "200") {
      setState(() {
        prosesLogin = false;
      });
      helper.alertLog(res['message']);
      Navigator.pop(context);
    } else {
      setState(() {
        prosesLogin = false;
      });
      helper.alertLog(res['message']);
    }
  }

  deleteGroup()async{
	  final response = await http.post(Config.BASE_URL + "delete_group",body:{
		  "id":widget.id
	  });
	  final res = jsonDecode(response.body);
	  if(res['status']==200){
		  helper.alertLog("Successfully delete your Community");
		   Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Home()));
	  }else{
		  helper.alertLog("Failed delete your Community");
		
	  }
  }

  showAlertDialog(BuildContext context) {  // set up the buttons
  Widget cancelButton = FlatButton(
    child: Text("Cancel"),
    onPressed:  () {
		Navigator.pop(context);
	},
  );
  Widget continueButton = FlatButton(
    child: Text("Continue"),
    onPressed:  () {
		deleteGroup();
	},
  );  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Peringatan"),
    content: Text("Would you like to continue delete your community ?"),
    actions: [
      cancelButton,
      continueButton,
    ],
  );  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}


  @override
  void initState() {
    super.initState();
    prosesLogin = false;
    _getHeader();
  }

  String text = "";
  void updateInformation(String information) {
    setState(() => text = information);
    setState(() {
      text = information;
    });
    _getHeader();
  }

  void toUpload() async {
    final information = await Navigator.push(
      context,
      MaterialPageRoute(
          fullscreenDialog: true,
          builder: (context) => UploadImageDemo(text: "0", id: widget.id)),
    );
    updateInformation(information);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: Text(
          "Edit Community",
          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
          inAsyncCall: prosesLogin,
          opacity: 0.5,
          progressIndicator: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Color(0xFF0c53a0)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.20,
                decoration: BoxDecoration(
                  color: Color(0xFF306bdd),
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(50),
                    bottomLeft: Radius.circular(50),
                  ),
                ),
                child: Center(
                  child: imageUser == null
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50.0),
                              color: Colors.white,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                toUpload();
                              },
                              child: Image.asset(
                              "images/empty.jpg",
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 90,
                            height: 90,
                            child: GestureDetector(
                              onTap: () {
                                 toUpload();
                              },
                              child: imageUser == null
                                  ? Image.asset(
                                      "images/empty.jpg",
                                      fit: BoxFit.cover,
                                    )
                                  : CircleAvatar(
                                      radius: 0,
                                      backgroundImage: NetworkImage(
                                        Config.BASE_URL_IMAGE +
                                            "$imageUser",
                                        scale: 10,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                ),
              ),
                Container(
                  margin: EdgeInsets.only(top: 14, left: 24, right: 24),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: primaryColor),
                      borderRadius: BorderRadius.circular(10)),
                  child: Center(
                    child: TextField(
                      
                      style: GoogleFonts.poppins(color: primaryColor),
                      controller: _nama,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(left: 24, top: 14.0),
                          hintText: "Name of Community",
                          hintStyle: GoogleFonts.poppins(color: Colors.blueGrey),
                          prefixIcon: Icon(
                            Icons.people_outline,
                            size: 23,
                            color: Colors.blueGrey,
                            
                          )),
                    ),
                  ),
                ),
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
                      controller: _tentang,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(left: 24, top: 14.0),
                          hintText: "About",
                          hintStyle: GoogleFonts.poppins(color: Colors.blueGrey),
                          prefixIcon: Icon(
                            Icons.album,
                            size: 23,
                            color: Colors.blueGrey,
                          )),
                    ),
                  ),
                ),
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
                      controller: _kegiatan,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(left: 24, top: 14.0),
                          hintText: "Activity",
                          hintStyle: GoogleFonts.poppins(color: Colors.blueGrey),
                          prefixIcon: Icon(
                            Icons.track_changes,
                            size: 23,
                            color: Colors.blueGrey,
                          )),
                    ),
                  ),
                ),
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
                      controller: _info,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(left: 24, top: 14.0),
                          hintText: "Info",
                          hintStyle: GoogleFonts.poppins(color: Colors.blueGrey),
                          prefixIcon: Icon(
                            Icons.info,
                            size: 23,
                            color: Colors.blueGrey,
                          )),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 14, left: 24, right: 24),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: primaryColor),
                      borderRadius: BorderRadius.circular(10)),
                  child: Center(
                    child: TextField(
                      style: GoogleFonts.poppins(color: primaryColor),
                      controller: _lokasi,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(left: 24, top: 14.0),
                          hintText: "Address",
                          hintStyle: GoogleFonts.poppins(color: Colors.blueGrey),
                          prefixIcon: Icon(
                            Icons.pin_drop,
                            size: 23,
                            color: Colors.blueGrey,
                          )),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 14, left: 24, right: 24),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: primaryColor),
                      borderRadius: BorderRadius.circular(10)),
                  child: Center(
                    child: TextField(
                      style: GoogleFonts.poppins(color: primaryColor),
                      controller: _contact,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(left: 24, top: 14.0),
                          hintText: "Contact",
                          hintStyle: GoogleFonts.poppins(color: Colors.blueGrey),
                          prefixIcon: Icon(
                            Icons.phone,
                            size: 23,
                            color: Colors.blueGrey,
                          )),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () =>save(),
                  child: Container(
                    margin: EdgeInsets.only(top: 14),
                    width: MediaQuery.of(context).size.width * 0.80,
                    height: 40,
                    decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                        child: Text("Submit",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: Colors.white))),
                  ),
                ),
				GestureDetector(
                  onTap: () =>showAlertDialog(context),
                  child: Container(
                    margin: EdgeInsets.only(top: 14),
                    width: MediaQuery.of(context).size.width * 0.80,
                    height: 40,
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                        child: Text("Delete",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: Colors.white))),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 5),
                  width: MediaQuery.of(context).size.width * 0.15,
                  height: 3,
                  decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(30)),
                ),
              ],
            ),
          )),
    );
  }
}
