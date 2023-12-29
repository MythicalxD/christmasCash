import 'dart:convert';

import 'package:christmas_cash/components/letterHelper.dart';
import 'package:christmas_cash/pages/home.dart';
import 'package:flutter/material.dart';

import '../components/api/api_call.dart';
import 'letterfull.dart';

class LetterPage extends StatelessWidget {
  LetterPage({super.key});

  double screenWidth = 0.0;

  // Parse the JSON string
  Map<String, dynamic> jsonMap = jsonDecode(letter);

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/game_bg.png"),
                fit: BoxFit.cover)),
        width: double.infinity,
        height: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Number of columns
              crossAxisSpacing: 8.0, // Spacing between columns
              mainAxisSpacing: 8.0, // Spacing between rows
            ),
            itemCount: jsonMap.length,
            itemBuilder: (BuildContext context, int index) {
              Letter data = jsonMap[index];

              return Card(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyLetterView(data: data),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/letter1.png',
                            // Replace with your actual image URL
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(height: 8.0),
                          const SizedBox(height: 4.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Reward: \$${data.reward}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const Icon(Icons.attach_money, size: 18),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
