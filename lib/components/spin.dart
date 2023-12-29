import 'package:flutter/material.dart';
import 'dart:math';

class RewardWheel extends StatefulWidget {
  const RewardWheel({Key? key}) : super(key: key);

  @override
  _RewardWheelState createState() => _RewardWheelState();
}

class _RewardWheelState extends State<RewardWheel>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  double _wheelAngle = 0.0;
  String _winningReward = '';

  final rewards = [
    'Free Pizza',
    '50% Discount',
    'Double Points',
    'Free Entry',
    'Mystery Reward',
    'Surprise Gift',
    '10% Off',
    'Free Coffee',
  ];

  void _spinWheel() {
    final random = Random();
    final targetAngle = random.nextInt(360) * pi / 180;

    // Set the number of rotations before stopping
    final rotations = 2 + Random().nextInt(3);

    _controller!.animateTo(targetAngle + rotations * 360 * pi / 180,
        duration: Duration(seconds: 3 + rotations), curve: Curves.easeOut);

    _controller!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        final index = ((_wheelAngle * 360 / pi) % rewards.length).toInt();
        _winningReward = rewards[index];
      }
    });
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this);

    _controller!.addListener(() {
      setState(() {
        _wheelAngle = _controller!.value;
      });
    });
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reward Wheel'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform.rotate(
            angle: _wheelAngle,
            child: Image.asset('assets/images/spin.png'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _spinWheel,
            child: const Text('Spin Now'),
          ),
          const SizedBox(height: 20),
          Text('Winning Reward: $_winningReward'),
        ],
      ),
    );
  }
}
