import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PayoutDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: const DecorationImage(
                image: AssetImage("assets/images/payout_dialog_bg.png"),
                fit: BoxFit.cover)),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                const Text("Payment Address",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    )),
                Container(
                    width: 300,
                    height: 55,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(33),
                        color: Colors.white)),
                const Text("Enter Email PayPal",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }
}
