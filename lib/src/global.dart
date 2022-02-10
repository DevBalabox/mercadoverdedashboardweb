import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_verde/src/utils/theme.dart';

Future<Map> messageGrl(title, body) async {
  Get.snackbar('title', 'message');
}

Future<void> dialog(bool ok, context, message) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        title: ok
            ? Icon(
                Icons.check,
                size: 30,
                color: primaryGreen,
              )
            : Icon(
                Icons.close,
                color: Colors.red[600],
                size: 30,
              ),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[Text(message)],
          ),
        ),
      );
    },
  );
}
