import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:math';
import 'home_screen.dart';

class ResultScreen extends StatefulWidget {
  final String imagePath;
  final double score;
  const ResultScreen({super.key, required this.imagePath, required this.score});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with TickerProviderStateMixin {
  late AnimationController _scoreController;
  late AnimationController _cardController;
  late Animation<double> _scoreAnimation;
  late Animation<double> _cardFade;
  late Animation<Offset> _cardSlide;
  bool _detailsUnlocked = false;
  bool _lookalikesUnlocked = false;
  bool _glowupUnlocked = false;
  late Map<String, double> _breakdown;
  late String _verdict;
  late String _verdictEmoji;
  late Color _verdictColor;

  @override
  void initState() {
    super.initState();
    _scoreController = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);
    _cardController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _scoreAnimation = Tween<double>(begin: 0, end: widget.score).animate(CurvedAnimation(parent: _scoreController, curve: Curves.easeOutCubic));
    _cardFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeIn));
    _cardSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOutCubic));
    _generateBreakdown();
    _setVerdict();
    Future.delayed(const Duration(milliseconds: 200), () { _scoreController.forward(); _cardController.forward(); });
  }

  void _generateBreakdown() {
    final random = Random();
    final base = widget.score;
    _breakdown = {'Symmetry': _clamp(base + (random.nextDouble() - 0.5) * 2), 'Jawline': _clamp(base + (random.nextDouble() - 0.5) * 2), 'Eyes': _clamp(base + (random.nextDouble() - 0.5) * 2), 'Nose': _clamp(base + (random.nextDouble() - 0.5) * 2), 'Lips': _clamp(base + (random.nextDouble() - 0.5) * 2), 'Skin': _clamp(base + (random.nextDouble() - 0.5) * 2)};
  }

  double _clamp(double val) => val.clamp(1.0, 10.0);

  void _setVerdict() {
    if (widget.score >= 9.0) { _verdict = 'Legendary'; _verdictEmoji = '👑'; _verdictColor = const Color(0xFFFFD700); }
    else if (widget.score >= 8.0) { _verdict = 'Stunning'; _verdictEmoji = '🔥'; _verdictColor = const Color(0xFFFF6B9D); }
    else if (widget.score >= 7.0) { _verdict = 'Attractive'; _verdictEmoji = '✨'; _verdictColor = const Color(0xFF7B61FF); }
    else if (widget.score >= 6.0) { _verdict = 'Above Average'; _verdictEmoji = '😎'; _verdictColor = const Color(0xFF4FC3F7); }
    else { _verdict = 'Average'; _verdictEmoji = '🙂'; _verdictColor = const Color(0xFF4CAF50); }
  }

  @override
  void dispose() { _scoreController.dispose(); _cardController.dispose(); super.dispose(); }

  void _showAdDialog(String feature, VoidCallback onUnlock) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF13131A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(children: [const Icon(Icons.play_circle_fill, color: Color(0xFFFF6B9D), size: 26), const SizedBox(width: 10), const Text('Watch Ad', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))]),
      content: Text('Watch a short ad to unlock  for free!', style: TextStyle(color: Colors.white.withOpacity(0.7))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Maybe Later', style: TextStyle(color: Colors.white.withOpacity(0.4)))),
        GestureDetector(onTap: () { Navigator.pop(ctx); onUnlock(); }, child: Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: const LinearGradient(colors: [Color(0xFFFF6B9D), Color(0xFF7B61FF)])),
          child: const Text('Watch Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)))),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF12071E), Color(0xFF0A0A0F)])),
        child: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.symmetric(horizontal: 24), child: FadeTransition(opacity: _cardFade, child: SlideTransition(position: _cardSlide, child: Column(children: [
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            GestureDetector(onTap: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (_) => false),
              child: Container(width: 40, height: 40, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.08)), child: const Icon(Icons.home_rounded, color: Colors.white, size: 20))),
            ShaderMask(shaderCallback: (bounds) => const LinearGradient(colors: [Color(0xFFFF6B9D), Color(0xFF7B61FF)]).createShader(bounds),
              child: const Text('Your Result', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white))),
            Container(width: 40, height: 40, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.08)), child: const Icon(Icons.share_rounded, color: Colors.white, size: 20)),
          ]),
          const SizedBox(height: 28),
          Container(width: double.infinity, decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1E0A35), Color(0xFF0D0D1F)]),
            border: Border.all(color: const Color(0xFFFF6B9D).withOpacity(0.3), width: 1.5), boxShadow: [BoxShadow(color: const Color(0xFF7B61FF).withOpacity(0.2), blurRadius: 30, spreadRadius: 2)]),
            child: Column(children: [
              ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(26)), child: SizedBox(height: 220, width: double.infinity, child: Image.file(File(widget.imagePath), fit: BoxFit.cover))),
              Padding(padding: const EdgeInsets.all(24), child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
                  AnimatedBuilder(animation: _scoreAnimation, builder: (context, _) => ShaderMask(shaderCallback: (bounds) => LinearGradient(colors: [_verdictColor, const Color(0xFF7B61FF)]).createShader(bounds),
                    child: Text(_scoreAnimation.value.toStringAsFixed(1), style: const TextStyle(fontSize: 72, fontWeight: FontWeight.w900, color: Colors.white, height: 1)))),
                  Text('/10', style: TextStyle(fontSize: 24, color: Colors.white.withOpacity(0.4), fontWeight: FontWeight.w600)),
                ]),
                const SizedBox(height: 12),
                Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: _verdictColor.withOpacity(0.15), border: Border.all(color: _verdictColor.withOpacity(0.4))),
                  child: Text('  ', style: TextStyle(color: _verdictColor, fontSize: 16, fontWeight: FontWeight.w700))),
              ])),
            ])),
          const SizedBox(height: 24),
          _buildLockedSection('Detailed Breakdown', Icons.analytics_rounded, _detailsUnlocked, () => _showAdDialog('Detailed Breakdown', () => setState(() => _detailsUnlocked = true)),
            Column(children: _breakdown.entries.map((e) => Padding(padding: const EdgeInsets.only(bottom: 14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(e.key, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)), Text(e.value.toStringAsFixed(1), style: const TextStyle(color: Color(0xFFFF6B9D), fontSize: 13, fontWeight: FontWeight.w700))]),
              const SizedBox(height: 6),
              ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: e.value / 10, backgroundColor: Colors.white.withOpacity(0.08), valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6B9D)), minHeight: 6)),
            ]))).toList())),
          const SizedBox(height: 16),
          _buildLockedSection('Celebrity Lookalike', Icons.person_search_rounded, _lookalikesUnlocked, () => _showAdDialog('Celebrity Lookalike', () => setState(() => _lookalikesUnlocked = true)),
            Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: LinearGradient(colors: [const Color(0xFFFF6B9D).withOpacity(0.1), const Color(0xFF7B61FF).withOpacity(0.1)])),
              child: Row(children: [Container(width: 56, height: 56, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Color(0xFFFF6B9D), Color(0xFF7B61FF)])), child: const Icon(Icons.star_rounded, color: Colors.white, size: 28)),
                const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Chris Hemsworth', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)), const SizedBox(height: 4), Text('74% similarity match', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13))])),
                Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: const LinearGradient(colors: [Color(0xFFFF6B9D), Color(0xFF7B61FF)])), child: const Text('74%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15))),
              ]))),
          const SizedBox(height: 16),
          _buildLockedSection('Glow Up Tips', Icons.auto_fix_high_rounded, _glowupUnlocked, () => _showAdDialog('Glow Up Tips', () => setState(() => _glowupUnlocked = true)),
            Column(children: ['Hydrate more — glowing skin starts from within 💧', 'Your bone structure is great — work on posture 💪', 'Eyebrow grooming will dramatically enhance your look 👁️', 'Skincare routine: cleanser, toner, moisturizer daily ✨'].map((tip) =>
              Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14), decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: Colors.white.withOpacity(0.04), border: Border.all(color: Colors.white.withOpacity(0.06))),
                child: Text(tip, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, height: 1.4)))).toList())),
          const SizedBox(height: 24),
          GestureDetector(onTap: () => Navigator.pop(context), child: Container(width: double.infinity, height: 54,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white.withOpacity(0.15)), color: Colors.white.withOpacity(0.04)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.refresh_rounded, color: Colors.white.withOpacity(0.7), size: 20), const SizedBox(width: 10), Text('Try Another Photo', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 15, fontWeight: FontWeight.w600))]))),
          const SizedBox(height: 30),
        ]))))),
      ),
    );
  }

  Widget _buildLockedSection(String title, IconData icon, bool isUnlocked, VoidCallback onUnlock, Widget unlockedContent) {
    return Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: const Color(0xFF13131A), border: Border.all(color: Colors.white.withOpacity(0.06))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [Icon(icon, color: const Color(0xFFFF6B9D), size: 20), const SizedBox(width: 10), Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700))]),
          if (!isUnlocked) GestureDetector(onTap: onUnlock, child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: const LinearGradient(colors: [Color(0xFFFF6B9D), Color(0xFF7B61FF)])),
            child: const Row(children: [Icon(Icons.play_circle_fill, color: Colors.white, size: 14), SizedBox(width: 5), Text('Unlock', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700))])))
          else const Icon(Icons.lock_open_rounded, color: Color(0xFF4CAF50), size: 18),
        ]),
        if (!isUnlocked) ...[const SizedBox(height: 16), Container(width: double.infinity, height: 60, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.white.withOpacity(0.03)),
          child: Center(child: Text('🔒  Watch a short ad to unlock', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13))))]
        else ...[const SizedBox(height: 16), unlockedContent],
      ]));
  }
}
