import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:applovin_max/applovin_max.dart';
import 'package:christmas_cash/components/api/api_call.dart';
import 'package:christmas_cash/components/checkIn.dart';
import 'package:christmas_cash/components/final_dialog.dart';
import 'package:christmas_cash/components/send/sendO.dart';
import 'package:christmas_cash/pages/game.dart';
import 'package:christmas_cash/pages/letter.dart';
import 'package:christmas_cash/pages/offerwall.dart';
import 'package:christmas_cash/pages/payout.dart';
import 'package:christmas_cash/pages/settings.dart';
import 'package:christmas_cash/pages/spin.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

import '../components/api/constants.dart';
import '../components/letterHelper.dart';
import '../components/snowfall.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

int oClicked = 0;

class MyJsonData {
  int id;
  String content;
  String title;
  double reward;
  bool claimed;

  MyJsonData({
    required this.id,
    required this.content,
    required this.title,
    required this.reward,
    required this.claimed,
  });

  factory MyJsonData.fromJson(Map<String, dynamic> json) {
    return MyJsonData(
      id: json['id'],
      content: json['content'],
      title: json['title'],
      reward: json['reward'].toDouble(),
      // Assuming 'reward' is a double in JSON
      claimed: json['claimed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'title': title,
      'reward': reward,
      'claimed': claimed,
    };
  }
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  double screenHeight = 0.0;
  double screenWidth = 0.0;

  // Christmas epoch time (replace with actual epoch time)
  static const int CHRISTMAS = 1703448000;

  // Get current epoch time in milliseconds
  int currentEpochTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;

  late Timer _timer;
  int _seconds = 0;
  bool isGameClicked = false;

  bool o1v = false;
  bool o2v = false;
  bool o3v = false;
  bool o4v = false;
  bool o5v = false;
  bool o6v = false;

  late AnimationController _controller;
  late Animation<double> _animation;

  Future<void> updatePage() async {
    await getData(context);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    //_startTimer();

    updatePage();

    initializeRewardedAd();
    initializeInterstitialAds();

    // Set up the animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    // Define the animation using Tween with a small rotation angle
    _animation = Tween<double>(begin: -0.05, end: 0.05).animate(_controller);

    // Start the animation
    _controller.repeat(reverse: true);
  }

  void _startTimer() {
    _seconds = CHRISTMAS - (DateTime.now().millisecondsSinceEpoch ~/ 1000);
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_seconds > 0) {
            _seconds = _seconds - 1;
          } else {
            _timer.cancel(); // Stop the timer when it reaches zero
          }
        },
      ),
    );
  }

  final String _interstitial_ad_unit_id = "6fa8e1abea6c2b8e";

  var _interstitialRetryAttempt = 0;

  void initializeInterstitialAds() {
    AppLovinMAX.setInterstitialListener(InterstitialListener(
      onAdLoadedCallback: (ad) {
        // Interstitial ad is ready to be shown. AppLovinMAX.isInterstitialReady(_interstitial_ad_unit_id) will now return 'true'

        // Reset retry attempt
        _interstitialRetryAttempt = 0;
      },
      onAdLoadFailedCallback: (adUnitId, error) {
        // Interstitial ad failed to load
        // We recommend retrying with exponentially higher delays up to a maximum delay (in this case 64 seconds)
        _interstitialRetryAttempt = _interstitialRetryAttempt + 1;

        int retryDelay = pow(2, min(6, _interstitialRetryAttempt)).toInt();

        Future.delayed(Duration(milliseconds: retryDelay * 1000), () {
          AppLovinMAX.loadInterstitial(_interstitial_ad_unit_id);
        });
      },
      onAdDisplayedCallback: (ad) {},
      onAdDisplayFailedCallback: (ad, error) {},
      onAdClickedCallback: (ad) {},
      onAdHiddenCallback: (ad) {
        if (oClicked != 0) {
          sendAPIo(oClicked.toString(), (p0) async {
            await getData(context);
            updatePage();
          });
          oClicked = 0;
        } else if (isGameClicked) {
          isGameClicked = false;
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const FallingButtonsGame()));
        }

        // Load the first interstitial
        AppLovinMAX.loadInterstitial(_interstitial_ad_unit_id);
      },
    ));

    // Load the first interstitial
    AppLovinMAX.loadInterstitial(_interstitial_ad_unit_id);
  }

  final String _rewarded_ad_unit_id =
      "9a86a6b213a84704";

  var _rewardedAdRetryAttempt = 0;

  void initializeRewardedAd() {
    AppLovinMAX.setRewardedAdListener(RewardedAdListener(
        onAdLoadedCallback: (ad) {
          // Rewarded ad is ready to be shown. AppLovinMAX.isRewardedAdReady(_rewarded_ad_unit_id) will now return 'true'

          // Reset retry attempt
          _rewardedAdRetryAttempt = 0;
        },
        onAdLoadFailedCallback: (adUnitId, error) {
          // Rewarded ad failed to load
          // We recommend retrying with exponentially higher delays up to a maximum delay (in this case 64 seconds)
          _rewardedAdRetryAttempt = _rewardedAdRetryAttempt + 1;

          int retryDelay = pow(2, min(6, _rewardedAdRetryAttempt)).toInt();

          Future.delayed(Duration(milliseconds: retryDelay * 1000), () {
            AppLovinMAX.loadRewardedAd(_rewarded_ad_unit_id);
          });
        },
        onAdDisplayedCallback: (ad) {},
        onAdDisplayFailedCallback: (ad, error) {},
        onAdClickedCallback: (ad) {},
        onAdHiddenCallback: (ad) {
          loadRewardedAd();
        },
        onAdReceivedRewardCallback: (ad, reward) {
          Fluttertoast.showToast(
              msg: "Reward Received",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);

          Timer(const Duration(seconds: 3), () {
            updatePage();
          });
        }));

    loadRewardedAd();
  }

  void loadRewardedAd() {
    AppLovinMAX.loadRewardedAd(_rewarded_ad_unit_id);
  }

  Future<void> callRandomly() async {
    // Generate a random number between 0 and 1
    double randomValue = Random().nextDouble();

    // Check if the random number is less than 0.5
    if (false) {
      isGameClicked = true;
      // play ads here randomly
      bool isReady =
          (await AppLovinMAX.isInterstitialReady(_interstitial_ad_unit_id))!;
      if (isReady) {
        AppLovinMAX.showInterstitial(_interstitial_ad_unit_id);
      }
    } else {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const FallingButtonsGame()));
    }
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    int days = _seconds ~/ (24 * 3600);
    int hours = (_seconds % (24 * 3600)) ~/ 3600;
    int minutes = (_seconds % 3600) ~/ 60;
    int seconds = _seconds % 60;

    // calculate the remaining time (future - current)
    int ads20Timer = ADS20 - DateTime.now().millisecondsSinceEpoch ~/ 1000;
    int spinTimer = SPIN - DateTime.now().millisecondsSinceEpoch ~/ 1000;
    int gameTimer = GAME - DateTime.now().millisecondsSinceEpoch ~/ 1000;

    //calculate the time for the tree gifts
    o1v = ((o1 - DateTime.now().millisecondsSinceEpoch ~/ 1000) < 0)
        ? true
        : false;
    o2v = ((o2 - DateTime.now().millisecondsSinceEpoch ~/ 1000) < 0)
        ? true
        : false;
    o3v = ((o3 - DateTime.now().millisecondsSinceEpoch ~/ 1000) < 0)
        ? true
        : false;
    o4v = ((o4 - DateTime.now().millisecondsSinceEpoch ~/ 1000) < 0)
        ? true
        : false;
    o5v = ((o5 - DateTime.now().millisecondsSinceEpoch ~/ 1000) < 0)
        ? true
        : false;
    o6v = ((o6 - DateTime.now().millisecondsSinceEpoch ~/ 1000) < 0)
        ? true
        : false;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/Home.png',
              fit: BoxFit.cover, // Center crop the background image.
            ),
          ),

          // SNOWFALL
          Snowfall(parentContext: context),
          Positioned(
              left: screenWidth - 145,
              top: 40,
              child: Container(
                width: 140,
                height: 73,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/point_bg.png'),
                    // Replace with your image path
                    fit: BoxFit.cover,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10, left: 30),
                      child: Text(
                        '$POINTS',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10, right: 10),
                      child: Image.asset(
                        'assets/images/item_6.png',
                        width: 30,
                        height: 30,
                      ),
                    )
                  ],
                ),
              )),
          Positioned(
              left: 10,
              top: 45,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingsPage()));
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/settings.png'),
                      // Replace with your image path
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              )),
          Positioned(
              left: 60,
              top: 45,
              child: GestureDetector(
                onTap: () async {
                  await getData(context);
                  setState(() {
                    Fluttertoast.showToast(
                        msg: "Page Refreshed ✅",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  });
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/refresh.png'),
                      // Replace with your image path
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              )),
          Positioned(
              left: (screenWidth / 2) - 45,
              top: 70,
              child: GestureDetector(
                onTap: () {
                  if ((_seconds < 0)) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return FinalDialog();
                      },
                    );
                  } else {
                    Fluttertoast.showToast(
                        msg: "Please wait...",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  }
                },
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/timer.png'),
                      // Replace with your image path
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              )),
          Positioned(
              left: (_seconds < 0)
                  ? (screenWidth / 2) - 65
                  : (screenWidth / 2) - 30,
              top: 155,
              child: Text(
                (_seconds < 0)
                    ? 'Merry Christmas'
                    : '$days days\n$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                textAlign: TextAlign.center,
                style: GoogleFonts.novaMono(
                    textStyle: const TextStyle(
                        fontSize: 17,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold)),
              )),

          // Main tasks --------------------------------------------------------

          Positioned(
              left: 10,
              top: 195,
              child: GestureDetector(
                onTap: () {
                  if (gameTimer < 0) {
                    callRandomly();
                  }
                },
                child: Container(
                  width: 65,
                  height: 65,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/task1.png'),
                      // Replace with your image path
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              )),

          Positioned(
              left: 10,
              top: 120,
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CustomDialog();
                    },
                  );
                },
                child: Container(
                  width: 65,
                  height: 65,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/task2.png'),
                      // Replace with your image path
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              )),

          Positioned(
              left: 10,
              top: 280,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Offerwall()));
                },
                child: Container(
                  width: 65,
                  height: 65,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/task3.png'),
                      // Replace with your image path
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              )),

          Positioned(
              left: 10,
              top: 360,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LetterPage()));
                },
                child: Container(
                  width: 65,
                  height: 65,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/task4.png'),
                      // Replace with your image path
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              )),

          // Main task on the right side -------------------------------------

          Positioned(
              left: screenWidth - 85,
              top: 140,
              child: GestureDetector(
                onTap: () async {
                  bool isReady = (await AppLovinMAX.isRewardedAdReady(
                      _rewarded_ad_unit_id))!;
                  if (isReady) {
                    AppLovinMAX.showRewardedAd(_rewarded_ad_unit_id);
                  }
                },
                child: Container(
                  width: 65,
                  height: 65,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/task5.png'),
                      // Replace with your image path
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              )),

          Positioned(
            top: 257,
            left: (gameTimer < 0) ? 25 : 30,
            child: (gameTimer < 0)
                ? Text("PLAY",
                    style: GoogleFonts.odorMeanChey(
                      textStyle: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold),
                    ))
                : CountdownTimerWidget(
                    duration: (gameTimer < 0) ? 0 : gameTimer),
          ),

          Positioned(
            top: 203,
            left: (ads20Timer < 0) ? screenWidth - 75 : screenWidth - 65,
            child: (ads20Timer < 0)
                ? Text("WATCH",
                    style: GoogleFonts.odorMeanChey(
                      textStyle: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold),
                    ))
                : CountdownTimerWidget(
                    duration: (ads20Timer < 0) ? 0 : ads20Timer),
          ),

          Positioned(
            top: 293,
            left: (spinTimer < 0) ? screenWidth - 68 : screenWidth - 65,
            child: (spinTimer < 0)
                ? Text("PLAY",
                    style: GoogleFonts.odorMeanChey(
                      textStyle: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold),
                    ))
                : CountdownTimerWidget(
                    duration: (spinTimer < 0) ? 0 : spinTimer),
          ),

          Positioned(
              left: screenWidth - 85,
              top: 230,
              child: GestureDetector(
                onTap: () {
                  if ((spinTimer > 0)) {
                    Fluttertoast.showToast(
                        msg: "Please wait...",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  } else {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SpinWheel()));
                  }
                },
                child: Container(
                  width: 65,
                  height: 65,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/task6.png'),
                      // Replace with your image path
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              )),

          Positioned(
              left: screenWidth - 85,
              top: 320,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PayoutPage()));
                },
                child: Container(
                  width: 65,
                  height: 65,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/task7.png'),
                      // Replace with your image path
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              )),

          // Gifts on the tree ===========================================

          Positioned(
              left: (screenWidth / 2) - 150,
              bottom: 200,
              child: RotationTransition(
                turns: _animation,
                child: Visibility(
                  visible: o1v,
                  child: GestureDetector(
                    onTap: () async {
                      bool isReady = (await AppLovinMAX.isInterstitialReady(
                          _interstitial_ad_unit_id))!;
                      if (isReady) {
                        AppLovinMAX.showInterstitial(_interstitial_ad_unit_id);
                      } else {
                        initializeInterstitialAds();
                      }
                      oClicked = 1;
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/treeItem1.png'),
                          // Replace with your image path
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              )),

          Positioned(
              left: (screenWidth / 2) - 40,
              bottom: 170,
              child: RotationTransition(
                turns: _animation,
                child: Visibility(
                  visible: o2v,
                  child: GestureDetector(
                    onTap: () async {
                      oClicked = 2;
                      bool isReady = (await AppLovinMAX.isInterstitialReady(
                          _interstitial_ad_unit_id))!;
                      if (isReady) {
                        AppLovinMAX.showInterstitial(_interstitial_ad_unit_id);
                      } else {
                        initializeInterstitialAds();
                      }
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/treeItem2.png'),
                          // Replace with your image path
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              )),

          Positioned(
              right: (screenWidth / 2) - 150,
              bottom: 200,
              child: RotationTransition(
                turns: _animation,
                child: Visibility(
                  visible: o3v,
                  child: GestureDetector(
                    onTap: () async {
                      oClicked = 3;
                      bool isReady = (await AppLovinMAX.isInterstitialReady(
                          _interstitial_ad_unit_id))!;
                      if (isReady) {
                        AppLovinMAX.showInterstitial(_interstitial_ad_unit_id);
                      } else {
                        initializeInterstitialAds();
                      }
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/treeItem3.png'),
                          // Replace with your image path
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              )),

          Positioned(
              left: (screenWidth / 2) - 80,
              bottom: 300,
              child: RotationTransition(
                turns: _animation,
                child: Visibility(
                  visible: o4v,
                  child: GestureDetector(
                    onTap: () async {
                      oClicked = 4;
                      bool isReady = (await AppLovinMAX.isInterstitialReady(
                          _interstitial_ad_unit_id))!;
                      if (isReady) {
                        AppLovinMAX.showInterstitial(_interstitial_ad_unit_id);
                      } else {
                        initializeInterstitialAds();
                      }
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/treeItem4.png'),
                          // Replace with your image path
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              )),

          Positioned(
              left: (screenWidth / 2) - 30,
              bottom: 400,
              child: RotationTransition(
                turns: _animation,
                child: Visibility(
                  visible: o5v,
                  child: GestureDetector(
                    onTap: () async {
                      oClicked = 5;
                      bool isReady = (await AppLovinMAX.isInterstitialReady(
                          _interstitial_ad_unit_id))!;
                      if (isReady) {
                        AppLovinMAX.showInterstitial(_interstitial_ad_unit_id);
                      } else {
                        initializeInterstitialAds();
                      }
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/treeItem5.png'),
                          // Replace with your image path
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              )),

          Positioned(
              right: (screenWidth / 2) - 100,
              bottom: 300,
              child: RotationTransition(
                turns: _animation,
                child: Visibility(
                  visible: o6v,
                  child: GestureDetector(
                    onTap: () async {
                      oClicked = 6;
                      bool isReady = (await AppLovinMAX.isInterstitialReady(
                          _interstitial_ad_unit_id))!;
                      if (isReady) {
                        AppLovinMAX.showInterstitial(_interstitial_ad_unit_id);
                      } else {
                        initializeInterstitialAds();
                      }
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/treeItem6.png'),
                          // Replace with your image path
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              )),

          // Mini Trees on the bottom ====================================

          Positioned(
              left: screenWidth - 90,
              bottom: 70,
              child: Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/mini_tree.png'),
                    // Replace with your image path
                    fit: BoxFit.cover,
                  ),
                ),
              )),

          Positioned(
              left: screenWidth - 50,
              bottom: 120,
              child: Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/mini_tree.png'),
                    // Replace with your image path
                    fit: BoxFit.cover,
                  ),
                ),
              )),

          Positioned(
              left: screenWidth - 200,
              bottom: 100,
              child: Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/mini_tree.png'),
                    // Replace with your image path
                    fit: BoxFit.cover,
                  ),
                ),
              )),

          Positioned(
              left: screenWidth - 140,
              bottom: 60,
              child: Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/mini_tree.png'),
                    // Replace with your image path
                    fit: BoxFit.cover,
                  ),
                ),
              )),

          Positioned(
              left: 30,
              bottom: 110,
              child: Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/mini_tree.png'),
                    // Replace with your image path
                    fit: BoxFit.cover,
                  ),
                ),
              )),

          Positioned(
              left: 100,
              bottom: 90,
              child: Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/mini_tree.png'),
                    // Replace with your image path
                    fit: BoxFit.cover,
                  ),
                ),
              )),

          Positioned(
              left: 10,
              bottom: 60,
              child: Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/mini_tree.png'),
                    // Replace with your image path
                    fit: BoxFit.cover,
                  ),
                ),
              )),

          Positioned(
              left: 40,
              bottom: 40,
              child: Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/mini_tree.png'),
                    // Replace with your image path
                    fit: BoxFit.cover,
                  ),
                ),
              )),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class CountdownTimerWidget extends StatefulWidget {
  final int duration;

  CountdownTimerWidget({required this.duration});

  @override
  _CountdownTimerWidgetState createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  late Timer _timer;
  int _secondsRemaining = 0;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.duration;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer.cancel(); // Stop the timer when it reaches zero
        // You can add any action you want to perform after the timer finishes here
      }
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_formatTime(_secondsRemaining),
              style: GoogleFonts.odibeeSans(
                textStyle: const TextStyle(
                    fontSize: 17,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold),
              )),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer to avoid memory leaks
    super.dispose();
  }
}
