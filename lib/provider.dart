import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

void saveUserData(Map userData) async {
  final localData = await SharedPreferences.getInstance();

  String user = jsonEncode(userData);
  localData.setString('userNew', user);
}

int calculateTotal(var allDetails) {
  int totalAmount = 0;
  for (var _alldetail in allDetails) {
    totalAmount = totalAmount + _alldetail['amount'] ?? 0;
  }
  return totalAmount;
}

class IsInList extends ChangeNotifier {
//  bool isInList = false;
  List allDetails = []; //cart items
  int totalAmount;
  Map userDetails;
  String userName;
  bool showSpinner = false;

  // adding user information when login
  void addUser(Map user) async {
    userDetails = user;
    saveUserData(user);
    notifyListeners();
  }
}
