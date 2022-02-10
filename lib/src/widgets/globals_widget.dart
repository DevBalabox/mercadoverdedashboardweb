import 'package:flutter/material.dart';

messageToUser(key, String message) {
  final snackBar = SnackBar(content: Text(message));
  key.currentState.showSnackBar(snackBar);
  
}