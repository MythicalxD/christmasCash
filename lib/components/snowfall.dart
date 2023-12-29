import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class Snowfall extends StatefulWidget {
  final BuildContext parentContext;

  Snowfall({required this.parentContext});

  @override
  _SnowfallState createState() => _SnowfallState();
}

class _SnowfallState extends State<Snowfall> {
  late List<Snowflake> snowflakes;

  @override
  void initState() {
    super.initState();
    snowflakes = List.generate(
      100,
      (index) => Snowflake(
        position: Offset(
          Random().nextDouble() *
              MediaQuery.of(widget.parentContext).size.width,
          Random().nextDouble() *
              MediaQuery.of(widget.parentContext).size.height,
        ),
        size: Random().nextDouble() * 4.0 + 2.0,
        parentContext: context,
      ),
    );

    Timer.periodic(const Duration(milliseconds: 16), (timer) {
      for (var flake in snowflakes) {
        flake.fall();
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SnowfallPainter(snowflakes),
      size: MediaQuery.of(widget.parentContext).size,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class SnowfallPainter extends CustomPainter {
  final List<Snowflake> snowflakes;

  SnowfallPainter(this.snowflakes);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (var flake in snowflakes) {
      canvas.drawCircle(flake.position, flake.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class Snowflake {
  late Offset position;
  late double size;
  late BuildContext parentContext;

  Snowflake(
      {required this.position,
      required this.size,
      required this.parentContext});

  void fall() {
    position = Offset(position.dx, position.dy + 1);
    if (position.dy > MediaQuery.of(parentContext).size.height) {
      position = Offset(
        Random().nextDouble() * MediaQuery.of(parentContext).size.width,
        0,
      );
    }
  }
}
