import 'dart:math';

import 'package:applovin_max/applovin_max.dart';
import 'package:christmas_cash/components/api/api_call.dart';
import 'package:christmas_cash/components/api/constants.dart';
import 'package:christmas_cash/firebase_options.dart';
import 'package:christmas_cash/pages/login.dart';
import 'package:christmas_cash/pages/rootPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../components/api/firebase_api.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

bool isInited = false;

class _SplashScreenState extends State<SplashScreen> {
  void startApplovin() async {
    // init Applovin

    // init firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // init messages
    await FirebaseApi().initNotification();

    await AppLovinMAX.initialize(
        "I48p6l9aAACduX2fy_lga8ThTBTdkznuy5Oc8y2z6ByvhZJuUEpETnIa4GJaC3RIvOW76HJCzrTzTJJQtU930f");

    //AppLovinMAX.showMediationDebugger();

    // Get the FirebaseAuth instance
    FirebaseAuth auth = FirebaseAuth.instance;

    if (auth.currentUser != null) {
      getUserInfo();
      AppLovinMAX.setUserId(auth.currentUser!.uid);
    }

    if (auth.currentUser == null) {
      gotoHome();
    } else {
      gotoLogin();
    }
  }

  void gotoHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void gotoLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const RootPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    startApplovin();
    return Material(
      child: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
          image: AssetImage("assets/images/splash_screen.png"),
          fit: BoxFit.cover,
        )),
      ),
    );
  }
}
