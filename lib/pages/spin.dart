import 'dart:async';
import 'dart:math';

import 'package:applovin_max/applovin_max.dart';
import 'package:christmas_cash/components/api/api_call.dart';
import 'package:christmas_cash/components/send/sendSpin.dart';
import 'package:christmas_cash/pages/referral.dart';
import 'package:flutter/material.dart';

import '../components/api/constants.dart';
import '../components/diaolog.dart';

class SpinWheel extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<SpinWheel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  Map<int, double> lookUp = {
    1: -0.125 * 0,
    2: -0.125 * 1,
    3: -0.125 * 2,
    4: -0.125 * 3,
    5: -0.125 * 4,
    6: -0.125 * 5,
    7: -0.125 * 6,
    8: -0.125 * 7,
  };

  Map<int, String> points = {
    1: "0",
    2: "2",
    3: "5",
    4: "0",
    5: "10",
    6: "5",
    7: "2",
    8: "15",
  };

  double endPos = 3;

  @override
  void initState() {
    super.initState();

    initializeInterstitialAds();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // Adjust the duration as needed
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: endPos + lookUp[NEXTWIN + 1]!,
    ).animate(_controller);
  }

  void _rotateImage() {
    _controller.reset();
    _controller.forward();

    Timer(const Duration(seconds: 4), () {
      // after 3 seconds call the API and show dialog
      // Show the score card dialog.
      showDialog(
        context: context,
        builder: (BuildContext context) => CustomDialog(
          backgroundImage: const AssetImage('assets/images/dialog_bg.png'),
          title: 'CLAIM SPIN',
          text: 'You have received ${points[NEXTWIN + 1]} points!',
          button1Text: 'SHARE',
          button2Text: 'CLAIM',
          onPressedButton1: () async {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const ReferralPage()));
          },
          onPressedButton2: () async {
            bool isReady = (await AppLovinMAX.isInterstitialReady(
                _interstitial_ad_unit_id))!;
            if (isReady) {
              AppLovinMAX.showInterstitial(_interstitial_ad_unit_id);
            }
          },
        ),
      );
    });
  }

  final String _interstitial_ad_unit_id =

      "eea179d90cfe563c";

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
        //TODO send API SPIN
        sendSpin("id", (p0) async {
          await getData(context);
          Navigator.pop(context);
          Navigator.pop(context);
        });
        // Load the first interstitial
        AppLovinMAX.loadInterstitial(_interstitial_ad_unit_id);
      },
    ));

    // Load the first interstitial
    AppLovinMAX.loadInterstitial(_interstitial_ad_unit_id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage("assets/images/game_bg.png"))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MaxAdView(
                adUnitId:"6fd16377c2f84e1d",
                adFormat: AdFormat.banner,
                listener: AdViewAdListener(
                    onAdLoadedCallback: (ad) {},
                    onAdLoadFailedCallback: (adUnitId, error) {},
                    onAdClickedCallback: (ad) {},
                    onAdExpandedCallback: (ad) {},
                    onAdCollapsedCallback: (ad) {})),
            const SizedBox(height: 20),
            Image.asset("assets/images/pointer.png", width: 30, height: 30),
            RotationTransition(
              turns: _animation,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Image.asset(
                  'assets/images/spin.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _rotateImage,
              child: const Text('SPIN'),
            ),
            const SizedBox(height: 20),
            MaxAdView(
                adUnitId: "6fd16377c2f84e1d",
                adFormat: AdFormat.banner,
                listener: AdViewAdListener(
                    onAdLoadedCallback: (ad) {},
                    onAdLoadFailedCallback: (adUnitId, error) {},
                    onAdClickedCallback: (ad) {},
                    onAdExpandedCallback: (ad) {},
                    onAdCollapsedCallback: (ad) {})),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
