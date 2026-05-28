import 'package:flutter/material.dart';
import 'dart:io';
import '../helpers/face_analyzer.dart';
import 'result_screen.dart';

class RatingScreen extends StatefulWidget {
  final String imagePath;
  const RatingScreen({super.key, required this.imagePath});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen>
    with TickerProviderStateMixin {
  late AnimationController _scanController;
  late AnimationController _progressController;
  late Animation<double> _scanPosition;
  late Animation<double> _progressValue;

  String _statusText = 'Detecting face...';
  int _progressPercent = 0;
  bool _isComplete = false;
  bool _isAnalyzing = true;

  final List<String> _scanSteps = [
    'Detecting face...',
    'Analyzing facial structure...',
    'Measuring symmetry...',
    'Evaluating features...',
    'Calculating attractiveness score...',
    'Generating results...',
  ];

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
        duration: const Duration(seconds: 4), vsync: this);
    _progressController = AnimationController(
        duration: const Duration(seconds: 4), vsync: this);
    _scanPosition = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _scanController, curve: Curves.linear));
    _progressValue = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _progressController, curve: Curves.easeInOut));
    _scanController.repeat();
    _progressController.forward();
    _progressController.addListener(() {
      final percent = (_progressController.value * 100).round();
      final stepIndex =
          ((_progressController.value * (_scanSteps.length - 1)).floor())
              .clamp(0, _scanSteps.length - 1);
      if (mounted) {
        setState(() {
          _progressPercent = percent;
          _statusText = _scanSteps[stepIndex];
        });
      }
    });
    _progressController.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        await _analyzeImage();
      }
    });
  }

  Future<void> _analyzeImage() async {
    if (mounted) setState(() { _statusText = 'Running AI analysis...'; });

    final result = await FaceAnalyzer.analyzeFace(widget.imagePath);

    if (!mounted) return;

    if (result == null) {
      // No face detected
      _scanController.stop();
      _showNoFaceDialog();
      return;
    }

    setState(() { _isComplete = true; _isAnalyzing = false; });

    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) =>
              ResultScreen(imagePath: widget.imagePath, result: result),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  void _showNoFaceDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF13131A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Text('😅', style: TextStyle(fontSize: 24)),
          SizedBox(width: 8),
          Text('No Face Detected',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ]),
        content: Text(
            'We couldn\'t detect a face in this photo. Please use a clear front-facing photo with good lighting.',
            style: TextStyle(color: Colors.white.withOpacity(0.7))),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B9D), Color(0xFF7B61FF)]),
              ),
              child: const Text('Try Again',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF12071E), Color(0xFF0A0A0F)],
          ),
        ),
        child: SafeArea(
          child: Column(children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.08)),
                    child: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white, size: 18),
                  ),
                ),
                const SizedBox(width: 16),
                const Text('Analyzing...',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700)),
              ]),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(children: [
                  // Scan area
                  Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: const Color(0xFFFF6B9D).withOpacity(0.4),
                          width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Stack(children: [
                        Positioned.fill(
                            child: Image.file(File(widget.imagePath),
                                fit: BoxFit.cover)),
                        Positioned.fill(
                            child: Container(
                                color: Colors.black.withOpacity(0.3))),
                        if (_isAnalyzing)
                          AnimatedBuilder(
                            animation: _scanPosition,
                            builder: (context, child) => Positioned(
                              top: _scanPosition.value * 290,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 3,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [
                                    Colors.transparent,
                                    const Color(0xFFFF6B9D).withOpacity(0.8),
                                    const Color(0xFF7B61FF).withOpacity(0.8),
                                    Colors.transparent,
                                  ]),
                                  boxShadow: [
                                    BoxShadow(
                                        color: const Color(0xFFFF6B9D)
                                            .withOpacity(0.6),
                                        blurRadius: 10)
                                  ],
                                ),
                              ),
                            ),
                          ),
                        if (_isComplete)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22),
                                  color:
                                      const Color(0xFF4CAF50).withOpacity(0.2)),
                              child: const Center(
                                  child: Icon(Icons.check_circle_rounded,
                                      color: Color(0xFF4CAF50), size: 60)),
                            ),
                          ),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 40),
                  AnimatedBuilder(
                    animation: _progressValue,
                    builder: (context, _) => Column(children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_statusText,
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 14)),
                            Text('$_progressPercent%',
                                style: const TextStyle(
                                    color: Color(0xFFFF6B9D),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700)),
                          ]),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: _progressValue.value,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFFF6B9D)),
                          minHeight: 8,
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 30),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: ['Symmetry', 'Jawline', 'Eyes', 'Nose', 'Lips', 'Skin', 'Overall']
                        .asMap()
                        .entries
                        .map((entry) {
                      final delay = entry.key * 0.1;
                      return AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, child) {
                          final isActive = _progressController.value > delay;
                          return AnimatedOpacity(
                            opacity: isActive ? 1.0 : 0.2,
                            duration: const Duration(milliseconds: 300),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: isActive
                                    ? const LinearGradient(colors: [
                                        Color(0xFFFF6B9D),
                                        Color(0xFF7B61FF)
                                      ])
                                    : null,
                                color: isActive
                                    ? null
                                    : Colors.white.withOpacity(0.08),
                              ),
                              child: Text(entry.value,
                                  style: TextStyle(
                                      color: isActive
                                          ? Colors.white
                                          : Colors.white54,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
