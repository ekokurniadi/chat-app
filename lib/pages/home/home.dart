import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:komun_apps/pages/beranda/beranda.dart';

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

  @override
  void initState() {
    super.initState();
    bottomNavBarIndex = 0;
    jumlahNotif = 0;
    pageController = PageController(initialPage: bottomNavBarIndex);
  }

  @override
  void dispose() {
    super.dispose();
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
              icon: Stack(
                children: [
                  Icon(
                    CupertinoIcons.mail_solid,
                    color: Colors.white,
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
                              ? Colors.red
                              : Colors.transparent),
                    ),
                  )
                ],
              ),
              onPressed: null)
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
              child: Column(children: [
                CircleAvatar(child: Image.asset("images/user-login.png"),),
                Container(child: Text("Komun Apps",style: GoogleFonts.poppins(color: Colors.white),),)
              ],),
            ),
            ListTile(
              title: Text("Buat Komunitas"),
              onTap: () {
                print("buat komunitas");
              },
            ),
            ListTile(
              title: Text("Daftar Sebagai Keamanan"),
              onTap: () {
                  print("daftar sebagai keamanan");
              },
            )
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(top: 18.0),
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
                title: Text('Beranda',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                activeColor: Color(0xFF306bdd),
                inactiveColor: Color(0xFF70747F),
                textAlign: TextAlign.start),
            BottomNavyBarItem(
                icon: Icon(Icons.people),
                title: Text('Bantuan',
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
                          color: ntf != 0 ? Colors.red : Colors.transparent),
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
      body: Align(
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
                Beranda()
              ],
            )
          ],
        ),
      ),
    );
  }
}
