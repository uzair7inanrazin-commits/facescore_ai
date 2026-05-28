import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'rating_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  int _freeRatingsLeft = 2;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(duration: const Duration(seconds: 2), vsync: this)..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source, maxWidth: 1080, maxHeight: 1080, imageQuality: 90);
    if (image != null && mounted) {
      Navigator.push(context, PageRouteBuilder(
        pageBuilder: (_, __, ___) => RatingScreen(imagePath: image.path),
        transitionsBuilder: (_, animation, __, child) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child),
        transitionDuration: const Duration(milliseconds: 500),
      )).then((_) { if (_freeRatingsLeft > 0) setState(() => _freeRatingsLeft--); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF12071E), Color(0xFF0A0A0F)])),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  Container(width: 38, height: 38, decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [Color(0xFFFF6B9D), Color(0xFF7B61FF)]), boxShadow: [BoxShadow(color: const Color(0xFFFF6B9D).withOpacity(0.4), blurRadius: 12)]),
                    child: const Icon(Icons.face_retouching_natural, size: 22, color: Colors.white)),
                  const SizedBox(width: 10),
                  ShaderMask(shaderCallback: (bounds) => const LinearGradient(colors: [Color(0xFFFF6B9D), Color(0xFF7B61FF)]).createShader(bounds),
                    child: const Text('FaceScore AI', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white))),
                ]),
                Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: LinearGradient(colors: [const Color(0xFFFF6B9D).withOpacity(0.2), const Color(0xFF7B61FF).withOpacity(0.2)]), border: Border.all(color: const Color(0xFFFF6B9D).withOpacity(0.3))),
                  child: Row(children: [const Icon(Icons.star, color: Color(0xFFFFD700), size: 14), const SizedBox(width: 4), Text('PRO', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12, fontWeight: FontWeight.w700))])),
              ]),
              const SizedBox(height: 36),
              ScaleTransition(scale: _pulseAnimation, child: Container(
                width: double.infinity, height: 260,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1E0A35), Color(0xFF0D0D1F)]),
                  border: Border.all(color: const Color(0xFFFF6B9D).withOpacity(0.25), width: 1.5), boxShadow: [BoxShadow(color: const Color(0xFF7B61FF).withOpacity(0.2), blurRadius: 30, spreadRadius: 2)]),
                child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(width: 90, height: 90, decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [const Color(0xFFFF6B9D).withOpacity(0.15), const Color(0xFF7B61FF).withOpacity(0.15)]), border: Border.all(color: const Color(0xFFFF6B9D).withOpacity(0.3), width: 2)),
                    child: Icon(Icons.add_a_photo_rounded, size: 40, color: Colors.white.withOpacity(0.8))),
                  const SizedBox(height: 18),
                  const Text('Rate Your Face', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 8),
                  Text('AI-powered face analysis in seconds', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.5))),
                ])),
              )),
              const SizedBox(height: 28),
              Row(children: [
                Expanded(child: GestureDetector(onTap: () => _pickImage(ImageSource.camera), child: Container(height: 60, decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), gradient: const LinearGradient(colors: [Color(0xFFFF6B9D), Color(0xFFFF8E53)]), boxShadow: [BoxShadow(color: const Color(0xFFFF6B9D).withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))]),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.camera_alt_rounded, color: Colors.white, size: 22), SizedBox(width: 8), Text('Camera', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15))])))),
                const SizedBox(width: 16),
                Expanded(child: GestureDetector(onTap: () => _pickImage(ImageSource.gallery), child: Container(height: 60, decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), gradient: const LinearGradient(colors: [Color(0xFF7B61FF), Color(0xFF4FC3F7)]), boxShadow: [BoxShadow(color: const Color(0xFF7B61FF).withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))]),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.photo_library_rounded, color: Colors.white, size: 22), SizedBox(width: 8), Text('Gallery', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15))])))),
              ]),
              const SizedBox(height: 28),
              Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: const Color(0xFF13131A), border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3))),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.bolt, color: Color(0xFFFFD700), size: 20), const SizedBox(width: 8),
                  Text(' free ratings left today', style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(width: 8), Text('• Watch ad for more', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                ])),
              const SizedBox(height: 28),
            ]),
          ),
        ),
      ),
    );
  }
}
