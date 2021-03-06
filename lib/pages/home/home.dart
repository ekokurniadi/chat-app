import 'dart:async';
import 'dart:convert';

import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:komun_apps/components/function.dart';
import 'package:komun_apps/pages/bantuan/daftarKeamanan.dart';
import 'package:komun_apps/pages/beranda/beranda.dart';
import 'package:komun_apps/pages/beranda/cariBantuan.dart';
// ignore: unused_import
import 'package:komun_apps/pages/chat/chat.dart';
import 'package:komun_apps/pages/komunitas/index.dart';
import 'package:komun_apps/pages/login.dart';
import 'package:komun_apps/pages/new_chat/list_chat.dart';
import 'package:komun_apps/pages/notif/notif.dart';
// ignore: unused_import
import 'package:komun_apps/pages/panduan/komun.dart';
import 'package:komun_apps/pages/panduan/panduan_komun.dart';
import 'package:komun_apps/pages/profile/profile.dart';
import 'package:komun_apps/pages/setting/setting.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/Helper.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import '../../components/config.dart';
class Home extends StatefulWidget {
  // const Home({ Key? key }) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int jumlahNotif;
  int ntf;
  int bottomNavBarIndex;
  PageController pageController;
  final Helper helper = Helper();
  bool prosesLogout = false;
  FirebaseMessaging fm = FirebaseMessaging();
  _HomeState() {
    fm.configure(
      onLaunch: (Map<String, dynamic> msg) async {
        // print("ketika sedang berjalan");
        // print(msg);

        if (msg['data']['screen'] == 'list_trx' &&
            msg['notification']['body'] != null) {
          helper.alertLog(msg['notification']['body']);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Home()),
          );
        } else if (msg['data']['screen'] == 'list_notif') {
          helper.alertLog(msg['notification']['body']);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Home()),
          );
        }
      },
      onResume: (Map<String, dynamic> msg) async {
        // print("ketika sedang berjalan");
        // print(msg);

        if (msg['data']['screen'] == 'list_trx' &&
            msg['notification']['body'] != null) {
          helper.alertLog(msg['notification']['body']);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Home()),
          );
        } else if (msg['data']['screen'] == 'list_notif') {
          helper.alertLog(msg['notification']['body']);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Home()),
          );
        }
      },
      onMessage: (Map<String, dynamic> msg) async {
        // print("ketika sedang berjalan");
        // print(msg);
        if (msg['data']['screen'] == 'list_trx' &&
            msg['notification']['body'] != null) {
          helper.alertLog(msg['notification']['body']);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Home()),
          );
        } else if (msg['data']['screen'] == 'list_notif') {
          helper.alertLog(msg['notification']['body']);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Home()),
          );
        }
      },
    );
  }
  Timer timer;
  final Functional functional = Functional();
  @override
  void initState() {
    super.initState();
    bottomNavBarIndex = 0;
    jumlahNotif = 0;
    ntf = 0;
    pageController = PageController(initialPage: bottomNavBarIndex);
    prosesLogout = false;
	getNotif();
    timer = Timer.periodic(Duration(seconds: 2), (Timer timer) async {
      await loca();
	  await getNotif();
    });
  }

  List<dynamic> dataList;
  Future<String> getNotif() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var idUser = pref.getString("idUser");
    final response = await http.post(Config.BASE_URL + "getNotif",
        body: {"id": idUser, "deleted": "0"});
    Map<String, dynamic> map = jsonDecode(response.body);
    setState(() {
      dataList = map["values"];
	  ntf = dataList == null ? 0 : dataList.length ;
    });
  
    return "Success";
  }

  loca() {
    functional.sendLocation();
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  logOut() async {
    setState(() {
      prosesLogout = true;
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.remove("idUser");
      preferences.remove("nama");
      preferences.remove("username");
      preferences.remove("level");
    });
    setState(() {
      prosesLogout = false;
    });
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => Login()));
    helper.alertLog("Successfully Log Out !");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Color(0xFF0c53a0),
        // automaticallyImplyLeading: false,
        title: Text("Komun", style: GoogleFonts.poppins()),
        actions: [
          IconButton(
              icon: Icon(
                CupertinoIcons.padlock_solid,
                color: Colors.white,
              ),
              onPressed: () => logOut())
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF0c53a0),
              ),
              child: Column(
                children: [
                  Image.asset(
                    "images/LOGO-NEW.png.png",
                    width: 100,
                  ),
                  Container(
                    child: Text(
                      "Komun Apps",
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
            ListTile(
              title: Text("Create Community"),
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Index()));
              },
            ),
            ListTile(
              title: Text("Register as security"),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => DaftarKeamanan()));
              },
            ),
            ListTile(
              title: Text("Setting"),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Setting()));
              },
            ),
            ListTile(
              title: Text("Terms and Conditions"),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => PanduanKomun()));
              },
            ),
            // ListTile(
            //   title: Text("About Komun Apps"),
            //   onTap: () {
            //     Navigator.push(
            //         context, MaterialPageRoute(builder: (context) => Komun()));
            //   },
            // ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(top: 80.0),
        child: BottomNavyBar(
          showElevation: true,
          itemCornerRadius: 24,
          selectedIndex: bottomNavBarIndex,
          onItemSelected: (index) => setState(() {
            bottomNavBarIndex = index;
            pageController.animateToPage(index,
                duration: Duration(milliseconds: 300), curve: Curves.ease);
          }),
          items: [
            BottomNavyBarItem(
                icon: Icon(CupertinoIcons.home),
                title: Text('Home',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                activeColor: Color(0xFF306bdd),
                inactiveColor: Color(0xFF70747F),
                textAlign: TextAlign.start),
            BottomNavyBarItem(
                icon: Stack(
                  children: [
                    Icon(
                      CupertinoIcons.mail_solid,
                    ),
                    Positioned(
                      // draw a red marble
                      top: 0.0,
                      right: 0.0,
                      child: Visibility(
                        visible: jumlahNotif == 0 ? false : true,
                        child: new Icon(Icons.brightness_1,
                            size: 12.0,
                            color: jumlahNotif != 0
                                ? Colors.transparent
                                : Colors.transparent),
                      ),
                    )
                  ],
                ),
                title: Text('Chat',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                activeColor: Color(0xFF306bdd),
                inactiveColor: Color(0xFF70747F),
                textAlign: TextAlign.start),
            BottomNavyBarItem(
                icon: Icon(Icons.people),
                title: Text('Get Help',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                activeColor: Color(0xFF306bdd),
                inactiveColor: Color(0xFF70747F),
                textAlign: TextAlign.start),
            BottomNavyBarItem(
                icon: Stack(children: <Widget>[
                  Icon(
                    bottomNavBarIndex == 2
                        ? Icons.notifications
                        : Icons.notifications_none,
                  ),
                  Positioned(
                    // draw a red marble
                    top: 0.0,
                    right: 0.0,
                    child: Visibility(
                      visible: ntf == 0 ? false : true,
                      child: new Icon(Icons.brightness_1,
                          size: 12.0,
                          color: ntf != 0
                              ? Colors.red
                              : Colors.transparent),
                    ),
                  )
                ]),
                title: Text('Notification',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                activeColor: Color(0xFF306bdd),
                inactiveColor: Color(0xFF70747F),
                textAlign: TextAlign.start),
            BottomNavyBarItem(
                icon: Icon(Icons.perm_identity),
                title: Text('Profile',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                activeColor: Color(0xFF306bdd),
                inactiveColor: Color(0xFF70747F),
                textAlign: TextAlign.start),
          ],
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: prosesLogout,
        opacity: 0.5,
        progressIndicator: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Color(0xFF0c53a0)),
        ),
        child: Align(
          alignment: AlignmentDirectional.bottomCenter,
          child: Stack(
            children: [
              PageView(
                controller: pageController,
                onPageChanged: (index) {
                  setState(() {
                    bottomNavBarIndex = index;
                  });
                },
                children: [
                  Beranda(),
                  ListChat(),
                  CariBantuan(),
                  NotificationPage(),
                  Profile()
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
