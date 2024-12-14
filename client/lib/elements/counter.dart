import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A counter widget
class Counter extends ConsumerStatefulWidget {
  final VoidCallback onCountdownComplete;
  final int duration;
  final double? marginTop;
  final double width;
  final double height;
  final Color? color;

  const Counter({
    super.key,
    required this.onCountdownComplete,
    required this.duration,
    this.marginTop,
    this.width = 100,
    this.height = 100,
    this.color = Colors.transparent,
  });

  @override
  CounterState createState() => CounterState();
}

class CounterState extends ConsumerState<Counter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  late int _counter;

  @override
  void initState() {
    super.initState();
    _initializeCounter();
  }

  @override
  void didUpdateWidget(covariant Counter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.dispose();
      _initializeCounter();
    }
  }

  void _initializeCounter() {
    _counter = widget.duration;

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.duration),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );

    _controller.addListener(() {
      if (_controller.status == AnimationStatus.completed) {
        widget.onCountdownComplete();
      } else {
        setState(() {
          _counter =
              (widget.duration - (_controller.value * widget.duration).floor());
        });
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        widget.marginTop != null
            ? SizedBox(height: widget.marginTop)
            : SizedBox(height: 0),
        SizedBox(
          width: widget.width,
          height: widget.height,
          child: CustomPaint(
            painter: CirclePainter(
                _progressAnimation.value, widget.color ?? Colors.transparent),
            child: Center(
              child: Text(
                _counter > 0 ? _counter.toString() : '',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CirclePainter extends CustomPainter {
  final double progress;
  final Color middleCircleColor;

  CirclePainter(this.progress, this.middleCircleColor);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint middleCirclePaint = Paint()
      ..color = middleCircleColor
      ..style = PaintingStyle.fill;

    final Paint backgroundPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke;

    final Paint progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.orange, Colors.deepOrangeAccent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: size.width / 2,
      ))
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2;

    canvas.drawCircle(center, radius, middleCirclePaint);
    canvas.drawCircle(center, radius, backgroundPaint);

    double sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return progress != (oldDelegate as CirclePainter).progress;
  }
}
