import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:komun_apps/components/config.dart';
import 'package:komun_apps/pages/komunitas/detailKomunitas.dart';
import 'package:komun_apps/pages/addMob.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabbar/tabbar.dart';
import '../../components/Helper.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';

class Beranda extends StatefulWidget {
  @override
  _BerandaState createState() => _BerandaState();
}

class _BerandaState extends State<Beranda> {
  bool controllerSearchValue;
  TextEditingController controllerSearch = TextEditingController();
  String filter = "";
  final tabController = PageController(initialPage: 0);
  final Helper helper = Helper();
  List<dynamic> dataBeranda;
  
  // ignore: unused_field
  BannerAd _bannerAd;
  // ignore: unused_field
  InterstitialAd _interstitialAd;
  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo();
  // ignore: unused_field
  int _coins = 0;
  // ignore: unused_field
  final _nativeAdController = NativeAdmobController();
  InterstitialAd createInterstitialAd() {
    return InterstitialAd(
        targetingInfo: targetingInfo,
        adUnitId: InterstitialAd.testAdUnitId,
        listener: (MobileAdEvent event) {
          print('interstitial event: $event');
        });
  }

  BannerAd createBannerAdd() {
    return BannerAd(
        targetingInfo: targetingInfo,
        adUnitId: BannerAd.testAdUnitId,
        size: AdSize.smartBanner,
        listener: (MobileAdEvent event) {
          print('Bnner Event: $event');
        });
  }

  _getMoreData(String filter) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var idUser = pref.getString("idUser");
    final data = await http.post(Config.BASE_URL + "getBeranda",
        body: {"filter": filter, "idUser": idUser});
    Map<String, dynamic> response = jsonDecode(data.body);
    setState(() {
      dataBeranda = response['values'];
    });
    return "Success";
  }

  List<dynamic> dataBerandaFollow;
  _getMoreDataFollow(String filter) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var idUser = pref.getString("idUser");
    final data = await http.post(Config.BASE_URL + "getBerandaFollow",
        body: {"filter": filter, "idUser": idUser});
    Map<String, dynamic> response = jsonDecode(data.body);
    setState(() {
      dataBerandaFollow = response['values'];
    });
    return "Success";
  }

  follow(index) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var idUser = pref.getString("idUser");
    final response = await http.post(Config.BASE_URL + "follow",
        body: {"idKomunitas": index.toString(), "idUser": idUser});
    final result = jsonDecode(response.body);
    if (result['status'] == 200) {
      helper.alertLog(result['message']);
      _getMoreData("");
      _getMoreDataFollow("");
    } else {
      helper.alertLog(result['message']);
      _getMoreData("");
      _getMoreDataFollow("");
    }
  }

  unfollow(index) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var idUser = pref.getString("idUser");
    final response = await http.post(Config.BASE_URL + "unfollow",
        body: {"idKomunitas": index.toString(), "idUser": idUser});
    final result = jsonDecode(response.body);
    if (result['status'] == 200) {
      helper.alertLog(result['message']);
      _getMoreData("");
      _getMoreDataFollow("");
    } else {
      helper.alertLog(result['message']);
      _getMoreData("");
      _getMoreDataFollow("");
    }
  }

  String idUser = "";
  String job = "";

  _getCurrentUser() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var user = sharedPreferences.get('idUser');
    var userJob = sharedPreferences.get('job');
    setState(() {
      idUser = user;
      job = userJob;
    });
  }

  @override
  void initState() {
    super.initState();
    _getMoreData("");
    _getMoreDataFollow("");
    _getCurrentUser();
    _bannerAd = createBannerAdd()..load();
    _interstitialAd = createInterstitialAd()..load();
    RewardedVideoAd.instance.load(
        adUnitId: RewardedVideoAd.testAdUnitId, targetingInfo: targetingInfo);
    RewardedVideoAd.instance.listener =
        (RewardedVideoAdEvent event, {String rewardType, int rewardAmount}) {
      print('Rewarded event: $event');
      if (event == RewardedVideoAdEvent.rewarded) {
        setState(() {
          _coins += rewardAmount;
        });
      }
    };
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
                      child: Text("All",
                          style: GoogleFonts.poppins(color: Color(0xFF306bdd))),
                    ),
                  ),
                  Tab(
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.transparent),
                      child: Text("Following",
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
          SingleChildScrollView(
            child: Column(
              children: [
                AdMobPage(),
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
                                "Nothing to show",
                                style: GoogleFonts.poppins(),
                              )
                            ],
                          ),
                        ),
                      )
                    : Container(
						 padding: EdgeInsets.only(bottom:60),
                        height: MediaQuery.of(context).size.height * 0.80,
                        child: ListView.builder(
                          itemCount: dataBeranda.length,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DetailKomunitas(
                                            index: dataBeranda[index]['id'])));
                              },
                              child: Container(
                                padding: EdgeInsets.all(8),
                                margin: EdgeInsets.only(
                                    right: 10, left: 10, bottom: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.8),
                                      spreadRadius: 2,
                                      blurRadius: 3,
                                      offset: Offset(
                                          0, 3), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                   Container(
									   width: 50,
									   height: 50,
									   child: Image.network(Config.BASE_URL_IMAGE + "${dataBeranda[index]['cover']}",fit: BoxFit.cover,),
								   ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(8),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.75,
                                          margin: EdgeInsets.only(left: 3),
                                          child: Text(
                                            "${dataBeranda[index]['namaKomunitas']}",
                                            style: GoogleFonts.poppins(),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.all(8),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.75,
                                          margin: EdgeInsets.only(left: 3),
                                          child: Text(
                                            "${dataBeranda[index]['tentang']}",
                                            style: GoogleFonts.poppins(
                                                fontSize: 12.0),
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(left: 3),
                                          child: Text(
                                            "${dataBeranda[index]['pengikut']} pengikut",
                                            style: GoogleFonts.poppins(
                                                fontSize: 12.0),
                                          ),
                                        ),
                                        Visibility(
                                          visible: idUser ==
                                                  dataBeranda[index]['idAdmin']
                                              ? false
                                              : true,
                                          child: GestureDetector(
                                            onTap: () {
                                              follow(dataBeranda[index]['id']);
                                            },
                                            child: Container(
                                              margin: EdgeInsets.all(5),
                                              padding: EdgeInsets.only(
                                                  top: 3,
                                                  bottom: 3,
                                                  left: 8,
                                                  right: 8),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  color: Colors.blue),
                                              child: Text(
                                                "Follow",
                                                style: GoogleFonts.poppins(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ],
            ),
          ),
          // tab diikuti
          SingleChildScrollView(
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
                          _getMoreDataFollow(filter);
                        });
                        if (value == "") {
                          setState(() {
                            controllerSearchValue = false;
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
                      onPressed: () {
                        controllerSearch.clear();
                        setState(() {
                          filter = "";
                          controllerSearchValue = false;
                        });
                        setState(() {
                          _getMoreDataFollow(filter);
                        });
                      },
                    ),
                  ),
                ),
                dataBerandaFollow == null
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
						 padding: EdgeInsets.only(bottom:60),
                        height: MediaQuery.of(context).size.height * 0.80,
                        child: ListView.builder(
                          itemCount: dataBerandaFollow.length,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DetailKomunitas(
                                            index: dataBerandaFollow[index]
                                                ['id'])));
                              },
                              child: Container(
                                padding: EdgeInsets.all(8),
                                margin: EdgeInsets.only(
                                    right: 10, left: 10, bottom: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.8),
                                      spreadRadius: 2,
                                      blurRadius: 3,
                                      offset: Offset(
                                          0, 3), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
									   width: 50,
									   height: 50,
									   child: Image.network(Config.BASE_URL_IMAGE + "${dataBerandaFollow[index]['cover']}",fit: BoxFit.cover,),
								   ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(8),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.75,
                                          margin: EdgeInsets.only(left: 3),
                                          child: Text(
                                            "${dataBerandaFollow[index]['namaKomunitas']}",
                                            style: GoogleFonts.poppins(),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.all(8),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.75,
                                          margin: EdgeInsets.only(left: 3),
                                          child: Text(
                                            "${dataBerandaFollow[index]['tentang']}",
                                            style: GoogleFonts.poppins(
                                                fontSize: 12.0),
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(left: 3),
                                          child: Text(
                                            "${dataBerandaFollow[index]['pengikut']} pengikut",
                                            style: GoogleFonts.poppins(
                                                fontSize: 12.0),
                                          ),
                                        ),
                                        Visibility(
                                          visible: idUser ==
                                                  dataBerandaFollow[index]
                                                      ['idAdmin']
                                              ? false
                                              : true,
                                          child: GestureDetector(
                                            onTap: () => unfollow(
                                                dataBerandaFollow[index]['id']),
                                            child: Container(
                                              margin: EdgeInsets.all(5),
                                              padding: EdgeInsets.only(
                                                  top: 3,
                                                  bottom: 3,
                                                  left: 8,
                                                  right: 8),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  color: Colors.red),
                                              child: Text(
                                                "Unfollow",
                                                style: GoogleFonts.poppins(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
