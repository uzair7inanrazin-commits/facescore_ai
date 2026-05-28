import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../helpers/ratings_manager.dart';
import '../helpers/ad_helper.dart';
import 'rating_screen.dart';
import 'pro_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  int _freeRatingsLeft = 2;
  bool _isPro = false;
  final ImagePicker _picker = ImagePicker();
  BannerAd? _bannerAd;
  bool _bannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _pulseController =
        AnimationController(duration: const Duration(seconds: 2), vsync: this)
          ..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _loadRatings();
    _loadBannerAd();
  }

  Future<void> _loadRatings() async {
    final left = await RatingsManager.getRatingsLeft();
    final pro = await RatingsManager.isPro();
    if (mounted) setState(() { _freeRatingsLeft = left; _isPro = pro; });
  }

  void _loadBannerAd() {
    _bannerAd = AdHelper.createBannerAd()
      ..load().then((_) {
        if (mounted) setState(() => _bannerAdLoaded = true);
      });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_freeRatingsLeft <= 0 && !_isPro) {
      _showNoRatingsDialog();
      return;
    }
    final XFile? image = await _picker.pickImage(
        source: source, maxWidth: 1080, maxHeight: 1080, imageQuality: 90);
    if (image != null && mounted) {
      await RatingsManager.useRating();
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => RatingScreen(imagePath: image.path),
          transitionsBuilder: (_, animation, __, child) => SlideTransition(
            position: Tween<Offset>(
                    begin: const Offset(0, 1), end: Offset.zero)
                .animate(CurvedAnimation(
                    parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      ).then((_) => _loadRatings());
    }
  }

  void _showNoRatingsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF13131A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('No Ratings Left',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700)),
        content: Text(
            'You\'ve used your ${ RatingsManager.freeRatingsPerDay} free ratings today. Watch an ad for a bonus rating or upgrade to Pro!',
            style: TextStyle(color: Colors.white.withOpacity(0.7))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: TextStyle(color: Colors.white.withOpacity(0.4))),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pop(ctx);
              AdHelper.showRewardedAd(
                onRewarded: () async {
                  await RatingsManager.addBonusRating();
                  _loadRatings();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text('Bonus rating unlocked!'),
                    backgroundColor: const Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    behavior: SnackBarBehavior.floating,
                  ));
                },
                onFailed: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Ad not available, try again later'),
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      behavior: SnackBarBehavior.floating,
                    )),
              );
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B9D), Color(0xFF7B61FF)]),
              ),
              child: const Text('Watch Ad',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
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
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(children: [
                    const SizedBox(height: 20),
                    _buildHeader(),
                    const SizedBox(height: 36),
                    _buildMainCard(),
                    const SizedBox(height: 28),
                    _buildActionButtons(),
                    const SizedBox(height: 20),
                    _buildRatingsCounter(),
                    const SizedBox(height: 20),
                    _buildFeaturesList(),
                    const SizedBox(height: 20),
                  ]),
                ),
              ),
              if (_bannerAdLoaded && _bannerAd != null)
                SizedBox(
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B9D), Color(0xFF7B61FF)]),
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFFFF6B9D).withOpacity(0.4),
                    blurRadius: 12)
              ],
            ),
            child: const Icon(Icons.face_retouching_natural,
                size: 22, color: Colors.white),
          ),
          const SizedBox(width: 10),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFFFF6B9D), Color(0xFF7B61FF)])
                .createShader(bounds),
            child: const Text('FaceScore AI',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white)),
          ),
        ]),
        GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ProScreen())).then((_) => _loadRatings()),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: _isPro
                  ? const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFF8C00)])
                  : LinearGradient(colors: [
                      const Color(0xFFFF6B9D).withOpacity(0.2),
                      const Color(0xFF7B61FF).withOpacity(0.2)
                    ]),
              border: Border.all(
                  color: _isPro
                      ? const Color(0xFFFFD700)
                      : const Color(0xFFFF6B9D).withOpacity(0.3)),
            ),
            child: Row(children: [
              Icon(Icons.star,
                  color: _isPro ? Colors.white : const Color(0xFFFFD700),
                  size: 14),
              const SizedBox(width: 4),
              Text(_isPro ? 'PRO ✓' : 'GO PRO',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildMainCard() {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: Container(
        width: double.infinity,
        height: 240,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E0A35), Color(0xFF0D0D1F)],
          ),
          border: Border.all(
              color: const Color(0xFFFF6B9D).withOpacity(0.25), width: 1.5),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF7B61FF).withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: 2)
          ],
        ),
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [
                  const Color(0xFFFF6B9D).withOpacity(0.15),
                  const Color(0xFF7B61FF).withOpacity(0.15)
                ]),
                border: Border.all(
                    color: const Color(0xFFFF6B9D).withOpacity(0.3), width: 2),
              ),
              child: Icon(Icons.add_a_photo_rounded,
                  size: 36, color: Colors.white.withOpacity(0.8)),
            ),
            const SizedBox(height: 16),
            const Text('Rate Your Face',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white)),
            const SizedBox(height: 8),
            Text('Real AI face analysis powered by ML Kit',
                style: TextStyle(
                    fontSize: 12, color: Colors.white.withOpacity(0.5))),
          ]),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(children: [
      Expanded(
        child: GestureDetector(
          onTap: () => _pickImage(ImageSource.camera),
          child: Container(
            height: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient:
                  const LinearGradient(colors: [Color(0xFFFF6B9D), Color(0xFFFF8E53)]),
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFFFF6B9D).withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6))
              ],
            ),
            child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_rounded, color: Colors.white, size: 22),
                  SizedBox(width: 8),
                  Text('Camera',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                ]),
          ),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: GestureDetector(
          onTap: () => _pickImage(ImageSource.gallery),
          child: Container(
            height: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                  colors: [Color(0xFF7B61FF), Color(0xFF4FC3F7)]),
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFF7B61FF).withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6))
              ],
            ),
            child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library_rounded,
                      color: Colors.white, size: 22),
                  SizedBox(width: 8),
                  Text('Gallery',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                ]),
          ),
        ),
      ),
    ]);
  }

  Widget _buildRatingsCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF13131A),
        border:
            Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.bolt, color: Color(0xFFFFD700), size: 20),
        const SizedBox(width: 8),
        Text(
          _isPro
              ? 'Unlimited ratings (PRO)'
              : '$_freeRatingsLeft free ratings left today',
          style: const TextStyle(
              color: Color(0xFFFFD700),
              fontWeight: FontWeight.w600,
              fontSize: 13),
        ),
        if (!_isPro) ...[
          const SizedBox(width: 8),
          Text('• Watch ad for more',
              style:
                  TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
        ]
      ]),
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      {'icon': Icons.analytics_rounded, 'text': 'AI Score out of 10', 'locked': false},
      {'icon': Icons.remove_red_eye_rounded, 'text': 'Detailed Face Breakdown', 'locked': true},
      {'icon': Icons.person_search_rounded, 'text': 'Celebrity Lookalike', 'locked': true},
      {'icon': Icons.auto_fix_high_rounded, 'text': 'Glow Up Tips', 'locked': true},
      {'icon': Icons.face_retouching_natural, 'text': 'Real ML Kit Face Detection', 'locked': false},
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('FEATURES',
          style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2)),
      const SizedBox(height: 12),
      ...features.map((f) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: const Color(0xFF13131A),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(children: [
              Icon(f['icon'] as IconData,
                  color: f['locked'] as bool
                      ? Colors.white.withOpacity(0.3)
                      : const Color(0xFFFF6B9D),
                  size: 20),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(f['text'] as String,
                      style: TextStyle(
                          color: f['locked'] as bool
                              ? Colors.white.withOpacity(0.35)
                              : Colors.white.withOpacity(0.85),
                          fontSize: 14,
                          fontWeight: FontWeight.w500))),
              if (f['locked'] as bool)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFFFF6B9D).withOpacity(0.15),
                  ),
                  child: const Row(children: [
                    Icon(Icons.play_circle_fill,
                        color: Color(0xFFFF6B9D), size: 13),
                    SizedBox(width: 4),
                    Text('Watch Ad',
                        style: TextStyle(
                            color: Color(0xFFFF6B9D),
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ]),
                )
              else
                const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF4CAF50), size: 18),
            ]),
          )),
    ]);
  }
}
