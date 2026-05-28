import 'package:flutter/material.dart';
import 'dart:async';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
    _textController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _logoController, curve: Curves.elasticOut));
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeIn));
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 600), () { _textController.forward(); });
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ));
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Container(
        decoration: const BoxDecoration(gradient: RadialGradient(center: Alignment.center, radius: 1.2, colors: [Color(0xFF1A0A2E), Color(0xFF0A0A0F)])),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(scale: _logoScale, child: FadeTransition(opacity: _logoOpacity, child: Container(
                width: 110, height: 110,
                decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [Color(0xFFFF6B9D), Color(0xFF7B61FF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  boxShadow: [BoxShadow(color: const Color(0xFFFF6B9D).withOpacity(0.5), blurRadius: 40, spreadRadius: 5)]),
                child: const Icon(Icons.face_retouching_natural, size: 58, color: Colors.white),
              ))),
              const SizedBox(height: 28),
              SlideTransition(position: _textSlide, child: FadeTransition(opacity: _textOpacity, child: Column(children: [
                ShaderMask(shaderCallback: (bounds) => const LinearGradient(colors: [Color(0xFFFF6B9D), Color(0xFF7B61FF)]).createShader(bounds),
                  child: const Text('FaceScore AI', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1.2))),
                const SizedBox(height: 8),
                Text('Discover Your True Potential', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.5), letterSpacing: 2.0)),
              ]))),
              const SizedBox(height: 60),
              FadeTransition(opacity: _textOpacity, child: SizedBox(width: 36, height: 36,
                child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFFFF6B9D).withOpacity(0.7))))),
            ],
          ),
        ),
      ),
    );
  }
}
