import 'dart:async';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';

import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';

class AdMobInPageLogin extends StatefulWidget {
  @override
  _AdMobInPageLoginState createState() => _AdMobInPageLoginState();
}

class _AdMobInPageLoginState extends State<AdMobInPageLogin> {
  final _nativeAdController = NativeAdmobController();
  // ignore: unused_field
  double _height = 0;
  StreamSubscription _subscription;
  @override
  void initState() {
    _subscription = _nativeAdController.stateChanged.listen(_onStateChanged);
    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    _nativeAdController.dispose();
    super.dispose();
  }

  void _onStateChanged(AdLoadState state) {
    switch (state) {
      case AdLoadState.loading:
        setState(() {
          _height = 0;
        });
        break;

      case AdLoadState.loadCompleted:
        setState(() {
          _height = 330;
        });
        break;

      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(8),
        height: 330,
        color: Colors.transparent,
        child: NativeAdmob(
          adUnitID: NativeAd.testAdUnitId,
          controller: _nativeAdController,
          type: NativeAdmobType.full,
          loading: Center(child: CircularProgressIndicator()),
          error: Text('failed to load'),
        ));
  }
}
