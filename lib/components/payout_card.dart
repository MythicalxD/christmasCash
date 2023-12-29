import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PayoutCard extends StatelessWidget {
  final String Points;
  final String Amount;
  final String method;
  final String path;
  final bool isHot;

  const PayoutCard(
      {super.key,
      required this.Points,
      required this.Amount,
      required this.method,
      required this.path,
      required this.isHot});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 15),
          child: Container(
            width: 150,
            height: 190,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/payout_card.png'),
                // Replace with your image path
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10, top: 32),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(path),
                          // Replace with your image path
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, right: 10),
                    child: Text(
                      Amount,
                      style: GoogleFonts.candal(
                          textStyle: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6, right: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/item_6.png",
                          width: 17,
                          height: 25,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4, right: 5),
                          child: Text(
                            Points,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Visibility(
          visible: isHot,
          child: Positioned(
              top: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.only(left: 100),
                child: Transform.rotate(
                  angle: 0.3,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/hot.png'),
                        // Replace with your image path
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              )),
        ),
      ],
    );
  }
}
