import 'dart:async';
import 'dart:convert';

import 'package:christmas_cash/components/api/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

String? getUserInfo() {
  // Get the FirebaseAuth instance
  FirebaseAuth auth = FirebaseAuth.instance;
  if (auth.currentUser != null) {
    uid = auth.currentUser!.uid;
  } else {
    print("user not signedIn!");
  }
  return uid;
}

String? uid;
int POINTS = 0;
int TICKETS = 0;
int BAN = 0;
String REFERRAL = "";
bool REFEREDBY = false;
int REFERRALNUM = 0;
int NEXTWIN = 1;

int DAILY = 0;
int DONECLAIM = 0;
int PAYOUTLOCK = 0;
int GIFT = 0;
int SPIN = 0;
int GAME = 0;

// timer for gifts
int ADS20 = 0;

// Making Titan wale variables
int o1 = 0;
int o2 = 0;
int o3 = 0;
int o4 = 0;
int o5 = 0;
int o6 = 0;

String letter = "";

var isLoading = true;

Future<void> getData(BuildContext context) async {
  try {
    final response =
        await http.get(Uri.parse('$BASEURL/dash/getInfo/${getUserInfo()}'));
    if (response.statusCode == 200) {
      // remove loading animation
      isLoading = false;

      final jsonResponse = json.decode(response.body);

      // Unpack the JSON response to your global variables
      POINTS = jsonResponse['points'];
      REFERRAL = jsonResponse['referral'];
      DAILY = jsonResponse['streak'];
      DONECLAIM = jsonResponse['claimedToday'];
      NEXTWIN = jsonResponse['nextWinning'];
      GAME = jsonResponse['gameTime'];

      // ADS timer
      ADS20 = jsonResponse['ads20Time'];
      SPIN = jsonResponse['spinTime'];
      BAN = jsonResponse['ban'];

      o1 = jsonResponse['o1'];
      o2 = jsonResponse['o2'];
      o3 = jsonResponse['o3'];
      o4 = jsonResponse['o4'];
      o5 = jsonResponse['o5'];
      o6 = jsonResponse['o6'];

      Map<String, dynamic> jsonMap = jsonDecode(jsonResponse['letters']);
      letter = jsonMap['c'].toString();

      if ((jsonResponse['referredBy'] ?? "null") == 'null') {
        REFEREDBY = true;
      } else {
        REFEREDBY = false;
      }

      if (BAN == 1) {
        Fluttertoast.showToast(
            msg: "Your account is suspended!",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        SystemNavigator.pop();
      }

      //print(response.body);
    } else {
      // Handle the error if the request fails
      if (response.body == 'INVALID UID') {
        final FirebaseAuth _auth = FirebaseAuth.instance;
        await _auth.signOut();
      }
    }
  } catch (err) {
    print(err);
  }
}
