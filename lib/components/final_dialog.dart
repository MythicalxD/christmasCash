import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FinalDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: const DecorationImage(
                image: AssetImage("assets/images/final_dialog_bg.png"),
                fit: BoxFit.cover)),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(100)),
                  child: Center(
                    child: Image.asset("assets/images/paypal.png",
                        width: 60, height: 60),
                  ),
                )
              ],
            ),  
            Text("You have received 0.10\$.\nMerry Christmas",
                textAlign: TextAlign.center,
                style: GoogleFonts.candal(
                  textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.white),
                )),
            const SizedBox(height: 10),
            Image.asset("assets/images/claim.png", width: 100, height: 30)
          ],
        ),
      ),
    );
  }
}
