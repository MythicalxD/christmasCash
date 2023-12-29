import 'package:applovin_max/applovin_max.dart';
import 'package:christmas_cash/components/api/api_call.dart';
import 'package:christmas_cash/components/api/constants.dart';
import 'package:christmas_cash/components/send/sendGame.dart';
import 'package:christmas_cash/pages/referral.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

import '../components/diaolog.dart';

class FallingButtonsGame extends StatefulWidget {
  const FallingButtonsGame({super.key});

  @override
  _FallingButtonsGameState createState() => _FallingButtonsGameState();
}

class ButtonItem {
  Offset position;
  String imagePath;

  ButtonItem({required this.position, required this.imagePath});
}

class _FallingButtonsGameState extends State<FallingButtonsGame> {
  List<ButtonItem> buttons = [];
  List<bool> buttonTouched = [];
  double buttonSize = 80.0;
  double screenHeight = 0.0;
  double screenWidth = 0.0;
  int totalPoints = 0;
  int gameTimeInSeconds = 10;
  int remainingTimeInSeconds = 10;
  Timer? gameTimer;
  double initialSpawnRate = 2.0;
  double buttonSpeed = 7.0;
  double spawnRate = 3.0;

  // Define a list of image paths
  List<String> itemImages = [
    'assets/images/item1.png',
    'assets/images/item2.png',
    'assets/images/item3.png',
    'assets/images/item4.png',
    'assets/images/item5.png',
    'assets/images/bomb.png',
  ];

  @override
  void initState() {
    super.initState();
    // Start the game timer.
    startGameTimer();

    initializeInterstitialAds();

    // Start spawning buttons.
    startButtonSpawner();
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  final String _interstitial_ad_unit_id =
      "9033a712347094c0";

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
        // Load the first interstitial
        sendGameAPI("id", (p0) {
          Navigator.pop(context);
          Navigator.pop(context);
        }, totalPoints);
        AppLovinMAX.loadInterstitial(_interstitial_ad_unit_id);
      },
    ));
    AppLovinMAX.loadInterstitial(_interstitial_ad_unit_id);
  }

  // Function to start the game timer.
  void startGameTimer() {
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTimeInSeconds > 0) {
          remainingTimeInSeconds--;

          // Gradually increase spawn rate as time runs out.
          if (remainingTimeInSeconds < 15) {
            spawnRate += 1;
            buttonSpeed += 0.2;
          }
        } else {
          // Game over logic can be added here.
          gameOver();
          timer.cancel(); // Stop the timer.
        }
      });
    });
  }

  // Function to spawn a new button at the top of the screen with a random image path.
  void spawnButton() {
    final randomX = Random().nextInt(screenWidth.toInt()).toDouble();
    final randomImagePath = itemImages[Random().nextInt(itemImages.length)];
    buttons.add(
        ButtonItem(position: Offset(randomX, 0), imagePath: randomImagePath));
    buttonTouched.add(false);
  }

  // Function to move the buttons down.
  void moveButtons() {
    for (var i = 0; i < buttons.length; i++) {
      buttons[i].position =
          Offset(buttons[i].position.dx, buttons[i].position.dy + buttonSpeed);
    }
  }

  // Function to remove buttons that are out of bounds or tapped.
  void removeButtons() {
    for (var i = buttons.length - 1; i >= 0; i--) {
      if (buttons[i].position.dy >= screenHeight || buttonTouched[i]) {
        if (buttonTouched[i]) {
          totalPoints++;
        }
        buttons.removeAt(i);
        buttonTouched.removeAt(i);
      }
    }
  }

  // Function to start spawning buttons at intervals.
  void startButtonSpawner() {
    Timer.periodic(Duration(milliseconds: 1000 ~/ spawnRate), (timer) {
      spawnButton();
    });

    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        moveButtons();
        removeButtons();
      });
    });
  }

  void gameOver() {
    // Stop spawning buttons.
    gameTimer?.cancel();

    // Show the score card dialog.
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
        backgroundImage: const AssetImage('assets/images/dialog_bg.png'),
        title: 'Game Over!',
        text: 'You have won the game and received $totalPoints points!',
        button1Text: 'Share',
        button2Text: 'Continue',
        onPressedButton1: () async {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const ReferralPage()));
        },
        onPressedButton2: () async {
          // show ads here
          bool isReady = (await AppLovinMAX.isInterstitialReady(
              _interstitial_ad_unit_id))!;
          if (isReady) {
            AppLovinMAX.showInterstitial(_interstitial_ad_unit_id);
          }
        },
      ),
    );

    //_showScoreCardDialog(context);
    // You can also reset the game or navigate to the home screen here.
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/game_bg.png',
              fit: BoxFit.cover, // Center crop the background image.
            ),
          ),
          Center(
            child: Stack(
              children: [
                Positioned(
                  top: 40,
                  left: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: <Widget>[
                            Text(
                              'Points: $totalPoints',
                              style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                    left: screenWidth - 130,
                    top: 40,
                    child: Container(
                      width: 122,
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
                            padding:
                                const EdgeInsets.only(bottom: 10, left: 30),
                            child: Text(
                              '$POINTS',
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: 10, right: 10),
                            child: Image.asset(
                              'assets/images/item_6.png',
                              width: 30,
                              height: 30,
                            ),
                          )
                        ],
                      ),
                    )),
                // Add your button widgets here using Positioned.
                for (var i = 0; i < buttons.length; i++)
                  Positioned(
                    left: buttons[i].position.dx,
                    top: buttons[i].position.dy,
                    child: GestureDetector(
                      onTap: () {
                        // Handle button tap.
                        setState(() {
                          buttonTouched[i] = true;

                          // Check if the clicked button is a bomb.
                          if (buttons[i].imagePath ==
                              'assets/images/bomb.png') {
                            gameOver();
                          }
                        });
                      },
                      child: Image.asset(
                        buttons[i].imagePath, // Use the assigned image path
                        width: buttonSize,
                        height: buttonSize,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
