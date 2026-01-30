// import 'dart:async';

// import 'package:shared_preferences/shared_preferences.dart';

// class SharedPreferenceService {
//   static setStringValue(String token) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     prefs.setString('user_id', token);
//   }

//   static Future<String> getUserId() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString('user_id') ?? '';
//   }

//   static setIsOwner(bool role) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     prefs.setBool('user_role', role);
//   }

//   static Future<bool> getIsOwner() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getBool('user_role') ?? false;
//   }

//   static unsetEverything() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     prefs.clear();
//   }
// }
