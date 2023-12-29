import 'dart:math';

import 'package:applovin_max/applovin_max.dart';
import 'package:christmas_cash/components/api/api_call.dart';
import 'package:christmas_cash/components/payout_card.dart';
import 'package:christmas_cash/components/send/sendPayout.dart';
import 'package:christmas_cash/components/snowfall.dart';
import 'package:flutter/material.dart';

import '../components/api/constants.dart';

class PayoutPage extends StatefulWidget {
  const PayoutPage({super.key});

  @override
  State<PayoutPage> createState() => _PayoutPageState();
}

final List<Locale> systemLocales = WidgetsBinding.instance.window.locales;

class MinimumAmountAndPoints {
  String amount;
  int points;

  MinimumAmountAndPoints({required this.amount, required this.points});
}

class _PayoutPageState extends State<PayoutPage> {
  double screenHeight = 0.0;
  double screenWidth = 0.0;

  @override
  void initState() {
    super.initState();
    initializeInterstitialAds();
  }

  void update(String param) async {
    Navigator.of(context).pop();
    await getData(context);
    setState(() {});
  }

  // Applovin 48eb01a343203f0d
  var _interstitialRetryAttempt = 0;
  final String _interstitial_ad_unit_id = "6fa8e1abea6c2b8e";

  void initializeInterstitialAds() {
    AppLovinMAX.setInterstitialListener(InterstitialListener(
      onAdLoadedCallback: (ad) {
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
        AppLovinMAX.loadInterstitial(_interstitial_ad_unit_id);
      },
    ));

    // Load the first interstitial
    AppLovinMAX.loadInterstitial(_interstitial_ad_unit_id);
  }

  final TextEditingController _textController = TextEditingController();

  void _showInputDialog(
      BuildContext context, String amount, String method, int points) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Payout $amount $method'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                (method == "Paypal")
                    ? Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100)),
                        child: Center(
                          child: Image.asset(
                              "assets/images/${(method == "Paypal") ? "paypal" : "item_6"}.png",
                              width: 60,
                              height: 60),
                        ),
                      )
                    : Container(),
                TextField(
                  controller: _textController,
                  decoration:
                      const InputDecoration(labelText: 'Enter payout Email'),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    // Do something with the input value
                    String inputValue = _textController.text;
                    bool isReady = (await AppLovinMAX.isInterstitialReady(
                        _interstitial_ad_unit_id))!;
                    if (isReady) {
                      AppLovinMAX.showInterstitial(_interstitial_ad_unit_id);
                    }
                    sendPayout(amount, method, inputValue, points,
                        (String p) => {update(p)});
                  },
                  child: const Text('PAYOUT'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;

    String countryCode = systemLocales.first.countryCode!;

    MinimumAmountAndPoints getMinimumAmountAndPoints() {
      switch (countryCode) {
        case 'BR':
          return MinimumAmountAndPoints(amount: '1 R\$', points: 10000);
        case 'VN':
          return MinimumAmountAndPoints(amount: '1,200 đ', points: 2500);
        case 'IN':
          return MinimumAmountAndPoints(amount: '80 INR', points: 30000);
        case 'PH':
          return MinimumAmountAndPoints(amount: '5.5 PHP', points: 5000);
        case 'MX':
          return MinimumAmountAndPoints(amount: '1.7 MXN', points: 5000);
        case 'RU':
          return MinimumAmountAndPoints(amount: '8.0 RUB', points: 5000);
        case 'ID':
          return MinimumAmountAndPoints(amount: '1,500 IDR', points: 5000);
        default:
          // Default minimum amount and points for unknown country codes
          return MinimumAmountAndPoints(amount: '0.1 USD', points: 5000);
      }
    }

    MinimumAmountAndPoints getMinimumAmountAndPoints1() {
      switch (countryCode) {
        case 'BR':
          return MinimumAmountAndPoints(amount: '4.88 R\$', points: 30000);
        case 'VN':
          return MinimumAmountAndPoints(amount: '24,000 đ', points: 30000);
        case 'IN':
          return MinimumAmountAndPoints(amount: '100 INR', points: 45000);
        case 'PH':
          return MinimumAmountAndPoints(amount: '55 PHP', points: 30000);
        case 'MX':
          return MinimumAmountAndPoints(amount: '17.2 MXN', points: 30000);
        case 'RU':
          return MinimumAmountAndPoints(amount: '90 RUB', points: 30000);
        case 'ID':
          return MinimumAmountAndPoints(amount: '15,000 IDR', points: 30000);
        default:
          // Default minimum amount and points for unknown country codes
          return MinimumAmountAndPoints(amount: '1 USD', points: 30000);
      }
    }

    MinimumAmountAndPoints getMinimumAmountAndPoints2() {
      switch (countryCode) {
        case 'BR':
          return MinimumAmountAndPoints(amount: '24.41 R\$', points: 100000);
        case 'VN':
          return MinimumAmountAndPoints(amount: '121,000 đ', points: 100000);
        case 'IN':
          return MinimumAmountAndPoints(amount: '400 INR', points: 100000);
        case 'PH':
          return MinimumAmountAndPoints(amount: '277 PHP', points: 100000);
        case 'MX':
          return MinimumAmountAndPoints(amount: '86 MXN', points: 100000);
        case 'RU':
          return MinimumAmountAndPoints(amount: '450 RUB', points: 100000);
        case 'ID':
          return MinimumAmountAndPoints(amount: '77,300 IDR', points: 100000);
        default:
          // Default minimum amount and points for unknown country codes
          return MinimumAmountAndPoints(amount: '5 USD', points: 100000);
      }
    }

    MinimumAmountAndPoints getMinimumAmountAndPoints3() {
      switch (countryCode) {
        case 'BR':
          return MinimumAmountAndPoints(amount: '74 R\$', points: 200000);
        case 'VN':
          return MinimumAmountAndPoints(amount: '364,350 đ', points: 200000);
        case 'IN':
          return MinimumAmountAndPoints(amount: '1250 INR', points: 200000);
        case 'PH':
          return MinimumAmountAndPoints(amount: '830 PHP', points: 200000);
        case 'MX':
          return MinimumAmountAndPoints(amount: '260 MXN', points: 200000);
        case 'RU':
          return MinimumAmountAndPoints(amount: '1350 RUB', points: 200000);
        case 'ID':
          return MinimumAmountAndPoints(amount: '232,185 IDR', points: 200000);
        default:
          // Default minimum amount and points for unknown country codes
          return MinimumAmountAndPoints(amount: '15 USD', points: 200000);
      }
    }

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/payout_bg.png',
              fit: BoxFit.cover, // Center crop the background image.
            ),
          ),
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
          // SNOWFALL
          Snowfall(parentContext: context),
          Padding(
            padding: const EdgeInsets.only(top: 110),
            child: SingleChildScrollView(
              child: SizedBox(
                width: screenWidth,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Paypal
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          width: screenWidth,
                          alignment: AlignmentDirectional.centerStart,
                          child: Image.asset("assets/images/paypal_title.png",
                              width: 128, height: 55),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              _showInputDialog(
                                  context,
                                  getMinimumAmountAndPoints().amount,
                                  "Paypal",
                                  getMinimumAmountAndPoints().points);
                            },
                            child: PayoutCard(
                              Points:
                                  getMinimumAmountAndPoints().points.toString(),
                              Amount: getMinimumAmountAndPoints().amount,
                              method: "Paypal",
                              path: "assets/images/paypal.png",
                              isHot: true,
                            ),
                          ),
                          const SizedBox(width: 20),
                          GestureDetector(
                            onTap: () {
                              _showInputDialog(
                                  context,
                                  getMinimumAmountAndPoints1().amount,
                                  "Paypal",
                                  getMinimumAmountAndPoints1().points);
                            },
                            child: PayoutCard(
                              Points: getMinimumAmountAndPoints1()
                                  .points
                                  .toString(),
                              Amount: getMinimumAmountAndPoints1().amount,
                              method: "Paypal",
                              path: "assets/images/paypal.png",
                              isHot: true,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              _showInputDialog(
                                  context,
                                  getMinimumAmountAndPoints2().amount,
                                  "Paypal",
                                  getMinimumAmountAndPoints2().points);
                            },
                            child: PayoutCard(
                              Points: getMinimumAmountAndPoints2()
                                  .points
                                  .toString(),
                              Amount: getMinimumAmountAndPoints2().amount,
                              method: "Paypal",
                              path: "assets/images/paypal.png",
                              isHot: false,
                            ),
                          ),
                          const SizedBox(width: 20),
                          GestureDetector(
                            onTap: () {
                              _showInputDialog(
                                  context,
                                  getMinimumAmountAndPoints3().amount,
                                  "Paypal",
                                  getMinimumAmountAndPoints3().points);
                            },
                            child: PayoutCard(
                              Points: getMinimumAmountAndPoints3()
                                  .points
                                  .toString(),
                              Amount: getMinimumAmountAndPoints3().amount,
                              method: "Paypal",
                              path: "assets/images/paypal.png",
                              isHot: false,
                            ),
                          ),
                        ],
                      ),

                      // Bitcoin
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          width: screenWidth,
                          alignment: AlignmentDirectional.centerStart,
                          child: Image.asset("assets/images/bitcoin_title.png",
                              width: 128, height: 55),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              _showInputDialog(context, "1", "Bitcoin", 15000);
                            },
                            child: const PayoutCard(
                              Points: "15,000",
                              Amount: "1\$",
                              method: "Bitcoin",
                              path: "assets/images/bitcoin.png",
                              isHot: false,
                            ),
                          ),
                          const SizedBox(width: 20),
                          GestureDetector(
                            onTap: () {
                              _showInputDialog(context, "5", "Bitcoin", 40000);
                            },
                            child: const PayoutCard(
                              Points: "40,000",
                              Amount: "5\$",
                              method: "Bitcoin",
                              path: "assets/images/bitcoin.png",
                              isHot: false,
                            ),
                          ),
                        ],
                      ),

                      MaxAdView(
                          adUnitId: "6fd16377c2f84e1d",
                          adFormat: AdFormat.banner,
                          listener: AdViewAdListener(
                              onAdLoadedCallback: (ad) {},
                              onAdLoadFailedCallback: (adUnitId, error) {},
                              onAdClickedCallback: (ad) {},
                              onAdExpandedCallback: (ad) {},
                              onAdCollapsedCallback: (ad) {})),

                      // USDT
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          width: screenWidth,
                          alignment: AlignmentDirectional.centerStart,
                          child: Image.asset("assets/images/usdt_title.png",
                              width: 128, height: 55),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              _showInputDialog(context, "0.5", "USDT", 9000);
                            },
                            child: const PayoutCard(
                              Points: "9000",
                              Amount: "0.5\$",
                              method: "USDT",
                              path: "assets/images/usdt.png",
                              isHot: true,
                            ),
                          ),
                          const SizedBox(width: 20),
                          GestureDetector(
                            onTap: () {
                              _showInputDialog(context, "1", "USDT", 15000);
                            },
                            child: const PayoutCard(
                              Points: "15,000",
                              Amount: "1\$",
                              method: "USDT",
                              path: "assets/images/usdt.png",
                              isHot: false,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              _showInputDialog(context, "2", "USDT", 30000);
                            },
                            child: const PayoutCard(
                              Points: "30,000",
                              Amount: "2\$",
                              method: "USDT",
                              path: "assets/images/usdt.png",
                              isHot: false,
                            ),
                          ),
                          const SizedBox(width: 20),
                          GestureDetector(
                            onTap: () {
                              _showInputDialog(context, "10", "USDT", 90000);
                            },
                            child: const PayoutCard(
                              Points: "90,000",
                              Amount: "10\$",
                              method: "USDT",
                              path: "assets/images/usdt.png",
                              isHot: false,
                            ),
                          ),
                        ],
                      ),

                      MaxAdView(
                          adUnitId: "6fd16377c2f84e1d",
                          adFormat: AdFormat.banner,
                          listener: AdViewAdListener(
                              onAdLoadedCallback: (ad) {},
                              onAdLoadFailedCallback: (adUnitId, error) {},
                              onAdClickedCallback: (ad) {},
                              onAdExpandedCallback: (ad) {},
                              onAdCollapsedCallback: (ad) {})),

                      // Amazon
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          width: screenWidth,
                          alignment: AlignmentDirectional.centerStart,
                          child: Image.asset("assets/images/amazon_title.png",
                              width: 128, height: 55),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              _showInputDialog(context, "1", "Amazon", 15000);
                            },
                            child: const PayoutCard(
                              Points: "15,000",
                              Amount: "1\$",
                              method: "Amazon",
                              path: "assets/images/amazon.png",
                              isHot: false,
                            ),
                          ),
                          const SizedBox(width: 20),
                          GestureDetector(
                            onTap: () {
                              _showInputDialog(context, "10", "Amazon", 90000);
                            },
                            child: const PayoutCard(
                              Points: "90,000",
                              Amount: "10\$",
                              method: "Amazon",
                              path: "assets/images/amazon.png",
                              isHot: false,
                            ),
                          ),
                        ],
                      ),

                      MaxAdView(
                          adUnitId: "6fd16377c2f84e1d",
                          adFormat: AdFormat.banner,
                          listener: AdViewAdListener(
                              onAdLoadedCallback: (ad) {},
                              onAdLoadFailedCallback: (adUnitId, error) {},
                              onAdClickedCallback: (ad) {},
                              onAdExpandedCallback: (ad) {},
                              onAdCollapsedCallback: (ad) {})),

                      // Google
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          width: screenWidth,
                          alignment: AlignmentDirectional.centerStart,
                          child: Image.asset("assets/images/google_title.png",
                              width: 128, height: 55),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              _showInputDialog(context, "1", "Google", 15000);
                            },
                            child: const PayoutCard(
                              Points: "15,000",
                              Amount: "1\$",
                              method: "Google",
                              path: "assets/images/google.png",
                              isHot: false,
                            ),
                          ),
                          const SizedBox(width: 20),
                          GestureDetector(
                            onTap: () {
                              _showInputDialog(context, "10", "Google", 90000);
                            },
                            child: const PayoutCard(
                              Points: "90,000",
                              Amount: "10\$",
                              method: "Google",
                              path: "assets/images/google.png",
                              isHot: false,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
