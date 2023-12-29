import 'dart:math';

import 'package:applovin_max/applovin_max.dart';
import 'package:christmas_cash/components/api/api_call.dart';
import 'package:christmas_cash/components/send/sendDaily.dart';
import 'package:christmas_cash/components/send/sendO.dart';
import 'package:christmas_cash/pages/home.dart';
import 'package:christmas_cash/pages/rootPage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'api/constants.dart';

class CustomDialog extends StatefulWidget {
  @override
  State<CustomDialog> createState() => _CustomDialogState();
}

bool isClaimCLicked = false;

class _CustomDialogState extends State<CustomDialog> {
  @override
  void initState() {
    super.initState();

    initializeInterstitialAds();
  }

  final String _interstitial_ad_unit_id1 =
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
          AppLovinMAX.loadInterstitial(_interstitial_ad_unit_id1);
        });
      },
      onAdDisplayedCallback: (ad) {},
      onAdDisplayFailedCallback: (ad, error) {},
      onAdClickedCallback: (ad) {},
      onAdHiddenCallback: (ad) {
        print("meow checin ==============");
        if (isClaimCLicked) {
          isClaimCLicked = false;
          sendDailyAPI("", (p0) async {
            await getData(context);
            Navigator.pop(context);
          });
        } else {
          sendAPIo(oClicked.toString(), (p0) async {
            await getData(context);
          });
          oClicked = 0;
        }
        AppLovinMAX.loadInterstitial(_interstitial_ad_unit_id1);
      },
    ));

    // Load the first interstitial
    AppLovinMAX.loadInterstitial(_interstitial_ad_unit_id1);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: 340,
        height: 320,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xfffff85c),
              Color(0xfff6ef52),
              Color(0xbffff400),
              Color(0xffffc600),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Example: Day 1
                buildDayWidget(1, "Day 1", "200"),

                const SizedBox(width: 7),
                // Example: Day 2
                buildDayWidget(2, "Day 2", "300"),
                const SizedBox(width: 7),
                // Example: Day 3
                buildDayWidget(3, "Day 3", "400"),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Example: Day 4
                buildDayWidget(4, "Day 4", "650"),
                const SizedBox(width: 7),
                // Example: Day 5
                buildDayWidget(5, "Day 5", "700"),
                const SizedBox(width: 7),
                // Example: Day 6
                buildDayWidget(6, "Day 6", "900"),
              ],
            ),
            const SizedBox(height: 20),

            // Example: Day 7 (id:7)
            GestureDetector(
              onTap: () async {
                //PLAY ADS
                isClaimCLicked = true;
                if (7 > DAILY) {
                  bool isReady = (await AppLovinMAX.isInterstitialReady(
                      _interstitial_ad_unit_id1))!;
                  if (isReady) {
                    AppLovinMAX.showInterstitial(_interstitial_ad_unit_id1);
                  }
                } else {
                  Fluttertoast.showToast(
                      msg: "Already Claimed",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0);
                }
              },
              child: Stack(
                children: [
                  Container(
                    width: 150,
                    height: 75,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: (7 <= DAILY)
                            ? const Color(0xff848484)
                            : const Color(0xffAE4F19)),
                  ),
                  Positioned(
                    top: 20,
                    left: 10,
                    child: Container(
                      width: 130,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: (7 <= DAILY)
                            ? const Color(0xffCFCFCF)
                            : const Color(0xffFDDFD6),
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 1,
                    left: 60,
                    child: Text(
                      "Day 7",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white),
                    ),
                  ),
                  Positioned(
                    top: 7,
                    left: 15,
                    child: Image.asset(
                      (7 <= DAILY)
                          ? "assets/images/check.png"
                          : "assets/images/daily_gift2.png",
                      width: 70,
                      height: 70,
                    ),
                  ),
                  Positioned(
                    top: 37,
                    left: 80,
                    child: Row(
                      children: [
                        const Text(
                          "1000",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Image.asset(
                          "assets/images/item_6.png",
                          width: 14.407992362976074,
                          height: 20.000001907348633,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildDayWidget(int id, String day, String value, {String? iconPath}) {
    return GestureDetector(
      onTap: () async {
        //PLAY ADS
        isClaimCLicked = true;
        if (id > DAILY) {
          bool isReady = (await AppLovinMAX.isInterstitialReady(
              _interstitial_ad_unit_id1))!;
          if (isReady) {
            AppLovinMAX.showInterstitial(_interstitial_ad_unit_id1);
          }
        } else {
          Fluttertoast.showToast(
              msg: "Already Claimed",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      },
      child: Stack(
        children: [
          Container(
            width: 82,
            height: 75,
            decoration: BoxDecoration(
              border: (id - 1 == DAILY && DONECLAIM == 0)
                  ? Border.all(
                      color:
                          Colors.black87, // You can set the border color here
                      width: 3.0, // You can set the border width here
                    )
                  : Border.all(
                      color:
                          Colors.black87, // You can set the border color here
                      width: 0.0, // You can set the border width here
                    ),
              borderRadius: BorderRadius.circular(20),
              color: (id <= DAILY)
                  ? const Color(0xff848484)
                  : (int.parse(value) > 400)
                      ? const Color(0xff3677B2)
                      : const Color(0xff0aa323),
            ),
          ),
          Positioned(
            top: 18,
            left: 6,
            child: Container(
              width: 70,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: (id <= DAILY)
                    ? const Color(0xffCFCFCF)
                    : (int.parse(value) > 400)
                        ? const Color(0xffC9F3FC)
                        : const Color(0xffc6f5bf),
              ),
            ),
          ),
          Positioned(
            top: 1,
            left: 25,
            child: Text(
              day,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white),
            ),
          ),
          Positioned(
            top: 20,
            left: 25,
            child: Image.asset(
              (id <= DAILY)
                  ? "assets/images/check.png"
                  : "assets/images/daily_gift.png",
              width: 30,
              height: 30,
            ),
          ),
          Positioned(
            top: 50,
            left: 25,
            child: Row(
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Image.asset(
                  "assets/images/item_6.png",
                  width: 14.407992362976074,
                  height: 20.000001907348633,
                ),
                if (iconPath != null)
                  Image.asset(
                    iconPath,
                    width: 50,
                    height: 37.5,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
