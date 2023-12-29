import 'package:christmas_cash/components/letterHelper.dart';
import 'package:flutter/material.dart';

import 'home.dart';

class MyLetterView extends StatelessWidget {
  final Letter data;

  MyLetterView({required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Letter View'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.reward,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(
              data.content,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reward: \$${data.reward}',
                  style: const TextStyle(fontSize: 18),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Implement the logic to claim the reward
                    // For demonstration purposes, just print a message
                    print('Reward claimed for letter with id ${data.id}');
                  },
                  child: const Text('Claim Reward'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
