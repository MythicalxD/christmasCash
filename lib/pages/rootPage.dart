import 'dart:async';
import 'dart:math';

import 'package:applovin_max/applovin_max.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:christmas_cash/components/api/api_call.dart';
import 'package:christmas_cash/pages/home.dart';
import 'package:christmas_cash/pages/onInternet.dart';
import 'package:christmas_cash/pages/payout.dart';
import 'package:christmas_cash/pages/referral.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import '../components/api/constants.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => HomePageState();
}

var isOnline = false;

class HomePageState extends State<RootPage> {
  @override
  void initState() {
    fetchdata();
    playSong();
    gloop();

    FirebaseAuth auth = FirebaseAuth.instance;
    getUserInfo();
    AppLovinMAX.setUserId(auth.currentUser!.uid);

    super.initState();
  }

  void gloop() async {
    await getData(context);
    Timer(const Duration(seconds: 4), () {
      gloop();
    });
  }

  void playSong() async {
    Random random = Random();
    if (random.nextInt(10) < 5) {
      AssetsAudioPlayer.newPlayer()
          .open(Audio("assets/songs/song1.mp3"), autoStart: true, volume: 0.5);
    } else {
      AssetsAudioPlayer.newPlayer()
          .open(Audio("assets/songs/song2.mp3"), autoStart: true, volume: 0.5);
    }
    Timer(const Duration(seconds: 110), () {
      playSong();
    });
  }

  void fetchdata() async {
    await getData1();
    await getData(context);
  }

  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const Home(),
    const ReferralPage(),
    const PayoutPage()
  ];

  void refresh() {
    setState(() {});
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // check internet connection

  Future<void> getData1() async {
    try {
      final response = await http.get(Uri.parse(BASEURL));
      if (response.body.toString() != version) {
        Fluttertoast.showToast(
            msg: "Please Update the Application",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        SystemNavigator.pop();
      }

      if (response.statusCode == 200) {
        setState(() {
          isOnline = true;
        });
      }
    } catch (err) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NoInternet()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages.elementAt(_selectedIndex),
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
                backgroundColor: Colors.green,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.share),
                label: 'Referral',
                backgroundColor: Colors.green,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.wallet),
                label: 'Payout',
                backgroundColor: Colors.green,
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.black87,
            onTap: _onItemTapped,
            type:
                BottomNavigationBarType.fixed, // Use this for fixed item sizes
          ),
        ),
      ),
    );
  }
}
