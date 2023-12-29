import 'package:flutter/material.dart';

class Offerwall extends StatelessWidget {
  const Offerwall({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Offerwall"),
      ),
      body: Center(
        child: Container(
            width: 250,
            decoration: BoxDecoration(
                color: Colors.green.shade300,
                border: Border.all(color: Colors.green.shade800, width: 2),
                borderRadius: BorderRadius.circular(12)),
            child: const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                "Coming Soon...",
                textAlign: TextAlign.center,
              ),
            )),
      ),
    );
  }
}
