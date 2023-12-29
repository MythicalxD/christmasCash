import 'package:applovin_max/applovin_max.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../components/api/constants.dart';

class NoInternet extends StatefulWidget {
  const NoInternet({super.key});

  @override
  State<NoInternet> createState() => _NoInternetState();
}

bool isOnline = false;

class _NoInternetState extends State<NoInternet> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: MaxAdView(
          adUnitId:"1ee162f3a0b28ea4",
          adFormat: AdFormat.banner,
          listener: AdViewAdListener(
              onAdLoadedCallback: (ad) {},
              onAdLoadFailedCallback: (adUnitId, error) {},
              onAdClickedCallback: (ad) {},
              onAdExpandedCallback: (ad) {},
              onAdCollapsedCallback: (ad) {})),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Unable to connect to server",
              style: TextStyle(
                  fontSize: 22,
                  fontFamily: "LilitaOne",
                  decoration: TextDecoration.underline)),
          Lottie.asset('animations/disconnect.json'),
        ],
      ),
    );
  }
}
