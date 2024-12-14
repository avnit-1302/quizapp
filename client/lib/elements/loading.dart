import 'package:flutter/material.dart';

/// A loading logo widget
class LogoLoading extends StatefulWidget {
  static const String path = 'assets/logo.png';

  final double size;

  const LogoLoading({super.key, this.size = 100});

  @override
  LogoLoadingState createState() => LogoLoadingState();
}

class LogoLoadingState extends State<LogoLoading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 20).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_animation.value),
          child: child,
        );
      },
      child: Image.asset(
        LogoLoading.path,
        width: widget.size,
        height: widget.size,
      ),
    );
  }
}
