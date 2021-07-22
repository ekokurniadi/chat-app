import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:another_flushbar/flushbar.dart';

class Helper {
  void alertLog(String msg) {
    Fluttertoast.showToast(
        msg: "$msg",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.pink,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  void alertD(String msg, BuildContext context) {
    AwesomeDialog(
        context: context,
        animType: AnimType.LEFTSLIDE,
        headerAnimationLoop: false,
        dialogType: DialogType.SUCCES,
        title: 'Success',
        desc: "$msg",
        btnOkOnPress: () {
          debugPrint('OnClcik');
        },
        btnOkIcon: Icons.check_circle,
        onDissmissCallback: () {
          debugPrint('Dialog Dissmiss from callback');
        })
      ..show();
  }

  void alertE(String msg, BuildContext context) {
    AwesomeDialog(
        context: context,
        dialogType: DialogType.ERROR,
        animType: AnimType.RIGHSLIDE,
        headerAnimationLoop: false,
        title: 'Error',
        desc: "$msg",
        btnOkOnPress: () {
          debugPrint('OnClcik');
        },
        btnOkIcon: Icons.check_circle,
        onDissmissCallback: () {
          debugPrint('Dialog Dissmiss from callback');
        })
      ..show();
  }

  void alertSuccess(String message, BuildContext context) {
    Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      backgroundColor: Color(0xFF1ab0b0),
      title: "Success",
      message: "$message",
      duration: Duration(seconds: 3),
    )..show(context);
  }

  void alertError(String message, BuildContext context) {
    Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      backgroundColor: Colors.pink,
      title: "Error",
      message: "$message",
      duration: Duration(seconds: 3),
    )..show(context);
  }
}
