import 'package:applovin_max/applovin_max.dart';
import 'package:christmas_cash/components/api/api_call.dart';
import 'package:christmas_cash/components/send/sendReferral.dart';
import 'package:christmas_cash/pages/rootPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';

import '../components/api/constants.dart';
import '../components/snowfall.dart';

class ReferralPage extends StatefulWidget {
  const ReferralPage({Key? key}) : super(key: key);

  @override
  State<ReferralPage> createState() => _ReferralPageState();
}

class _ReferralPageState extends State<ReferralPage> {
  double screenHeight = 0.0;
  double screenWidth = 0.0;

  final myController = TextEditingController();

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text)).then((value) => {
          Fluttertoast.showToast(
              msg: "Referral code copied to Clipboard",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0)
        });
  }

  void _onDonePressed() {
    // Implement the action you want to take when the "Done" button is pressed
    String enteredText = _textController.text;
    sendReferralAPI(enteredText, (p0) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const RootPage()));
    });
    // Add your logic here
  }

  String getStroreUrl() {
    const String appPackageName = "com.earn.christmas_cash";
    return "https://play.google.com/store/apps/details?id=$appPackageName";
  }

  String textVal = "";

  final TextEditingController _textController = TextEditingController();

  void _showInputDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: const Text('Enter Referral Code'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: _textController,
                    decoration: const InputDecoration(labelText: 'Enter here'),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () async {
                      _onDonePressed();
                    },
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/Home.png',
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: 70,
              left: 20,
              child: MaxAdView(
                  adUnitId:  "6fd16377c2f84e1d",
                  adFormat: AdFormat.banner,
                  listener: AdViewAdListener(
                      onAdLoadedCallback: (ad) {},
                      onAdLoadFailedCallback: (adUnitId, error) {},
                      onAdClickedCallback: (ad) {},
                      onAdExpandedCallback: (ad) {},
                      onAdCollapsedCallback: (ad) {})),
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
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 10, top: 20),
                child: GestureDetector(
                  onTap: () {
                    String referralCode = REFERRAL;
                    String message =
                        'Check out Christmas Cash! 🎄💰Do simple tasks and play fun games to win Rewards, get free payout like PayPal, crypto, gift cards  and more!Complete simple tasks to earn instant \$1 !Download now: ${getStroreUrl()} \nEnter Referral Code: $referralCode to get 200 Points instantly.';
                    shareApp(message);
                  },
                  child: SizedBox(
                    width: 300,
                    height: 730,
                    child: Image.asset("assets/images/referral_card.png"),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 436, left: 20, right: 10),
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    copyToClipboard(REFERRAL);
                  },
                  child: Text(
                    REFERRAL,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 571, right: 5),
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    (REFEREDBY)
                        ? _showInputDialog(context)
                        : Fluttertoast.showToast(
                            msg: "Already Claimed",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0);
                  },
                  child: SizedBox(
                    width: 170,
                    child: Text((REFEREDBY) ? "ENTER CODE" : "CLAIMED",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Color(0xFF0D2784),
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void shareApp(String message) async {
  Share.share(message, subject: 'CHRISTMAS CASH FREE REWARDS');
}
