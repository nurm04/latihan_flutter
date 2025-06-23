import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = Tween<double>(begin: 0.0, end: math.pi / 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    )..addListener(() {
      setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 800), () {
        _controller.forward();
      });

      Future.delayed(const Duration(seconds: 3), () {
        final isLoggedIn = FirebaseAuth.instance.currentUser != null;
        Navigator.pushReplacementNamed(context, isLoggedIn ? '/home' : '/signin');
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildDoorImage({required bool isLeft}) {
    return Expanded(
      child: Transform(
        alignment: isLeft ? Alignment.centerRight : Alignment.centerLeft,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(isLeft ? _animation.value : -_animation.value),
        child: Image.asset(
          isLeft ? 'assets/images/pintu_kanan.jpg' : 'assets/images/pintu_kiri.jpg',
          fit: BoxFit.fill,
          height: double.infinity,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              _buildDoorImage(isLeft: false),
              _buildDoorImage(isLeft: true),
            ],
          ),
          Center(
            child: AnimatedOpacity(
              opacity: _animation.value > 0.3 ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: Text(
                'Lemari Lama',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF544C2A),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
