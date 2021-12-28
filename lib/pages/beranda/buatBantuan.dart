import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:komun_apps/components/constanta.dart';
import 'package:http/http.dart' as http;
import 'package:komun_apps/pages/addMob.dart';
import 'package:komun_apps/pages/beranda/list_security.dart';
import '../../components/config.dart';
import '../../components/Helper.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

class BuatBantuan extends StatefulWidget {
  @override
  _BuatBantuanState createState() => _BuatBantuanState();
}

class _BuatBantuanState extends State<BuatBantuan> {
  final TextEditingController _location = new TextEditingController();
  final TextEditingController _note = new TextEditingController();
  final TextEditingController _security = new TextEditingController();
  DateTime selectedDateSurvey = DateTime.now();
  TextEditingController _tanggalSurvey = TextEditingController();
  TimeOfDay selectedTimeMeter = TimeOfDay.now();
  TextEditingController _jamMeter = TextEditingController();
  String text = "";
  final Helper helper = Helper();
  String idSecurity = "";
  Timer timer;
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 2), (Timer timer) async {
      await sendLocation();
    });
  }

  _selectDateSurvey(BuildContext context) async {
    final DateTime pickedDateSurvey = await showDatePicker(
        context: context,
        initialDate: selectedDateSurvey,
        firstDate: DateTime(2000),
        lastDate: DateTime(2199),
        initialDatePickerMode: DatePickerMode.day);
    if (pickedDateSurvey != null && pickedDateSurvey != selectedDateSurvey)
      setState(() {
        selectedDateSurvey = pickedDateSurvey;
        _tanggalSurvey.text =
            DateFormat('dd/MM/yyyy').format(selectedDateSurvey);
      });
  }

  // ignore: unused_field
  String _hour, _minute, _time, _second;
  Future<Null> _selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: selectedTimeMeter,
    );
    if (picked != null)
      setState(() {
        selectedTimeMeter = picked;
        _hour = selectedTimeMeter.hour.toString();
        _minute = selectedTimeMeter.minute.toString();
        _second = "00";
        _time = _hour + ':' + _minute + ':' + '00';
        _jamMeter.text = _time;
        // print(_time);
      });
  }

  void updateInformation2(String information) async {
    setState(() => text = information);
    final response =
        await http.post(Config.BASE_URL + "getByIDUser", body: {"id": text});
    setState(() {
      text = information;
      idSecurity = text;
    });
    final res = jsonDecode(response.body);
    if (res['status'] == 200) {
      _security.text = res['data'];
    } else {
      _security.text = "";
    }
  }

  void moveToSecondPage() async {
    final information = await Navigator.push(
      context,
      MaterialPageRoute(
          fullscreenDialog: true, builder: (context) => ModalCustomer()),
    );
    updateInformation2(information);
  }

  sendLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    final coordinates = new Coordinates(position.latitude, position.longitude);

    // mendapatkan alamat
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var alamat = addresses.first;
    setState(() {
      _location.text = alamat.addressLine.toString();
    });
  }

  void submit() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var userId = pref.getString("idUser");
    final response = await http.post(Config.BASE_URL + "buat_bantuan", body: {
      "waktu": DateFormat('yyyy-MM-dd').format(selectedDateSurvey).toString() +
          " " +
          _jamMeter.text.toString(),
      "keterangan": _note.text,
      "user_id": userId.toString(),
      "user_id_penolong": idSecurity.toString(),
      "status": "1",
      "lokasi": _location.text
    });
    final res = jsonDecode(response.body);

    print(res);

    if (res['status'] == 200) {
      helper.alertLog(res['message']);
      Navigator.pop(context);
    } else {
      helper.alertLog(res['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          elevation: 0,
          title: Text(
            "Create a help request",
            style: GoogleFonts.poppins(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(top: 14, left: 24, right: 24),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: primaryColor),
                    borderRadius: BorderRadius.circular(10)),
                child: Center(
                  child: TextField(
                    onTap: () => _selectDateSurvey(context),
                    readOnly: true,
                    controller: _tanggalSurvey,
                    style: GoogleFonts.poppins(color: primaryColor),
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(left: 24, top: 14.0),
                        hintText: "Date",
                        hintStyle: GoogleFonts.poppins(color: primaryColor),
                        prefixIcon: Icon(
                          Icons.date_range,
                          size: 23,
                          color: primaryColor,
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
                    readOnly: true,
                    controller: _jamMeter,
                    onTap: () {
                      _selectTime(context);
                    },
                    style: GoogleFonts.poppins(color: primaryColor),
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(left: 24, top: 14.0),
                        hintText: "Time",
                        hintStyle: GoogleFonts.poppins(color: primaryColor),
                        prefixIcon: Icon(
                          Icons.watch,
                          size: 23,
                          color: primaryColor,
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
                        2, // any number you need (It works as the rows for the textarea)
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    style: GoogleFonts.poppins(color: primaryColor),
                    controller: _location,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(left: 24, top: 14.0),
                        hintText: "Location",
                        hintStyle: GoogleFonts.poppins(color: primaryColor),
                        prefixIcon: Icon(
                          Icons.pin_drop,
                          size: 23,
                          color: primaryColor,
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
                        2, // any number you need (It works as the rows for the textarea)
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    style: GoogleFonts.poppins(color: primaryColor),
                    controller: _note,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(left: 24, top: 14.0),
                        hintText: "Note",
                        hintStyle: GoogleFonts.poppins(color: primaryColor),
                        prefixIcon: Icon(
                          Icons.note,
                          size: 23,
                          color: primaryColor,
                        )),
                  ),
                ),
              ),
              Visibility(
                  visible: false,
                  child: Container(
                    child: Text(idSecurity.toString()),
                  )),
              Container(
                margin: EdgeInsets.only(top: 14, left: 24, right: 24),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: primaryColor),
                    borderRadius: BorderRadius.circular(10)),
                child: Center(
                  child: TextField(
                    readOnly: true,
                    onTap: () => moveToSecondPage(),
                    style: GoogleFonts.poppins(color: primaryColor),
                    controller: _security,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(left: 24, top: 14.0),
                        hintText: "Choose Security",
                        hintStyle: GoogleFonts.poppins(color: primaryColor),
                        prefixIcon: Icon(
                          Icons.security,
                          size: 23,
                          color: primaryColor,
                        )),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  submit();
                },
                child: Container(
                  margin: EdgeInsets.only(top: 14, bottom: 5.0),
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
              Container(
                width: MediaQuery.of(context).size.width * 0.15,
                height: 3,
                decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(30)),
              ),
              AdMobPage(),
            ],
          ),
        ));
  }
}
