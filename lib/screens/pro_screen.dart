import 'package:flutter/material.dart';
import '../helpers/ratings_manager.dart';

class ProScreen extends StatelessWidget {
  const ProScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A0A2E), Color(0xFF0A0A0F)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(children: [
              const SizedBox(height: 20),
              Row(children: [
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
              ]),
              const SizedBox(height: 30),
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFF8C00)]),
                  boxShadow: [
                    BoxShadow(
                        color: const Color(0xFFFFD700).withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 5)
                  ],
                ),
                child: const Icon(Icons.star_rounded,
                    color: Colors.white, size: 48),
              ),
              const SizedBox(height: 20),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFF8C00)])
                    .createShader(bounds),
                child: const Text('FaceScore PRO',
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white)),
              ),
              const SizedBox(height: 8),
              Text('Unlock the full experience',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.5), fontSize: 14)),
              const SizedBox(height: 40),
              ...[
                ['Unlimited daily ratings', Icons.all_inclusive],
                ['No ads ever', Icons.block],
                ['Instant detailed breakdown', Icons.analytics_rounded],
                ['Celebrity lookalike always unlocked', Icons.person_search_rounded],
                ['All glow up tips unlocked', Icons.auto_fix_high_rounded],
                ['Priority AI analysis', Icons.flash_on],
              ].map((item) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: const Color(0xFF13131A),
                      border: Border.all(
                          color: const Color(0xFFFFD700).withOpacity(0.2)),
                    ),
                    child: Row(children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFFD700).withOpacity(0.15),
                        ),
                        child: Icon(item[1] as IconData,
                            color: const Color(0xFFFFD700), size: 18),
                      ),
                      const SizedBox(width: 14),
                      Text(item[0] as String,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                      const Spacer(),
                      const Icon(Icons.check_circle_rounded,
                          color: Color(0xFF4CAF50), size: 18),
                    ]),
                  )),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () async {
                  // TODO: Implement real in-app purchase
                  // For now show coming soon
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: const Color(0xFF13131A),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      title: const Text('Coming Soon!',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                      content: Text(
                          'In-app purchases will be available after Play Store launch!',
                          style:
                              TextStyle(color: Colors.white.withOpacity(0.7))),
                      actions: [
                        GestureDetector(
                          onTap: () async {
                            // Demo mode - unlock pro for testing
                            await RatingsManager.setPro(true);
                            if (context.mounted) {
                              Navigator.pop(ctx);
                              Navigator.pop(context);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: const LinearGradient(colors: [
                                Color(0xFFFFD700),
                                Color(0xFFFF8C00)
                              ]),
                            ),
                            child: const Text('Try Pro (Demo)',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFF8C00)]),
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0xFFFFD700).withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 6))
                    ],
                  ),
                  child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star_rounded,
                            color: Colors.white, size: 22),
                        SizedBox(width: 10),
                        Text('Upgrade to PRO — \$1.99/month',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700)),
                      ]),
                ),
              ),
              const SizedBox(height: 16),
              Text('Cancel anytime. No hidden fees.',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.3), fontSize: 12)),
              const SizedBox(height: 30),
            ]),
          ),
        ),
      ),
    );
  }
}
