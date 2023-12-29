import 'package:applovin_max/applovin_max.dart';
import 'package:christmas_cash/pages/rootPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../components/api/constants.dart';
import 'login.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Handle back button press to navigate to the main home screen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const RootPage()),
          (Route<dynamic> route) => false,
        );
        return false; // Return false to prevent the default system back button handling
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Setting")),
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/game_bg.png"),
                  fit: BoxFit.cover)),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CustomButton(label: 'Contact Us'),
                      CustomButton(label: 'Privacy Policy'),
                      CustomButton(label: 'Terms & Conditions'),
                      CustomButton(label: 'About Us'),
                      CustomButton(label: 'Logout'),
                    ],
                  ),
                ),
                Center(
                  child: MaxAdView(
                      adUnitId: "99960e8f2b7e798a",
                      adFormat: AdFormat.mrec,
                      listener: AdViewAdListener(
                          onAdLoadedCallback: (ad) {},
                          onAdLoadFailedCallback: (adUnitId, error) {},
                          onAdClickedCallback: (ad) {},
                          onAdExpandedCallback: (ad) {},
                          onAdCollapsedCallback: (ad) {})),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String label;

  const CustomButton({required this.label});

  @override
  Widget build(BuildContext context) {
    var email = "Christmas2023.group@gmail.com";

    return GestureDetector(
      onTap: () async {
        // Handle button press
        if (label == "Logout") {
          final FirebaseAuth _auth = FirebaseAuth.instance;
          await _auth.signOut();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
        if (label == "Privacy Policy") {
          _launchURL(
              'https://christmashcash.blogspot.com/2023/12/privacy-police.html');
        }
        if (label == "Terms & Conditions") {
          _launchURL(
              'https://christmashcash.blogspot.com/2023/12/terms-and-conditions.html');
        }
        if (label == "About Us") {
          _launchURL(
              'https://christmashcash.blogspot.com/2023/12/about-us.html');
        }
        if (label == "Contact Us") {
          void _launchMailClient() async {
            var mailUrl = 'mailto:$email';
            try {
              await launch(mailUrl);
            } catch (e) {
              Fluttertoast.showToast(
                  msg: "Email copied!",
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
              await Clipboard.setData(ClipboardData(text: email));
            }
          }

          _launchMailClient();
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              label,
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 17),
            ),
          ),
        ),
      ),
    );
  }
}

_launchURL(String url1) async {
  final Uri url = Uri.parse(url1);
  if (!await launchUrl(url)) {
    throw Exception('Could not launch privacy-policy');
  }
}
