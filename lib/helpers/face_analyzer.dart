import 'dart:io';
import 'dart:math';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceAnalyzer {
  static final FaceDetector _detector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      enableLandmarks: true,
      enableContours: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  // Returns null if no face detected
  static Future<FaceResult?> analyzeFace(String imagePath) async {
    final inputImage = InputImage.fromFile(File(imagePath));
    final faces = await _detector.processImage(inputImage);

    if (faces.isEmpty) return null;

    // Use the largest face detected
    final face = faces.reduce((a, b) =>
        a.boundingBox.width > b.boundingBox.width ? a : b);

    return _calculateScore(face);
  }

  static FaceResult _calculateScore(Face face) {
    final random = Random();
    double score = 5.0;
    double symmetryScore = 5.0;
    double eyeScore = 5.0;
    double skinScore = 5.0;
    double jawScore = 5.0;
    double lipsScore = 5.0;
    double noseScore = 5.0;

    // Face symmetry from head euler angles
    final headEulerY = face.headEulerAngleY ?? 0;
    final symmetryPenalty = headEulerY.abs() / 10;
    symmetryScore = (8.5 - symmetryPenalty + random.nextDouble()).clamp(4.0, 10.0);

    // Eye scores from open probability
    final leftEyeOpen = face.leftEyeOpenProbability ?? 0.8;
    final rightEyeOpen = face.rightEyeOpenProbability ?? 0.8;
    final eyeAvg = (leftEyeOpen + rightEyeOpen) / 2;
    eyeScore = (eyeAvg * 7 + random.nextDouble() * 3).clamp(4.0, 10.0);

    // Smiling adds to score
    final smiling = face.smilingProbability ?? 0.5;
    final smileBonus = smiling * 2;

    // Random variation for other features
    skinScore = (5.0 + random.nextDouble() * 4 + smileBonus * 0.3).clamp(4.0, 10.0);
    jawScore = (5.0 + random.nextDouble() * 4).clamp(4.0, 10.0);
    lipsScore = (5.0 + random.nextDouble() * 4 + smileBonus * 0.5).clamp(4.0, 10.0);
    noseScore = (5.0 + random.nextDouble() * 4).clamp(4.0, 10.0);

    // Overall score weighted average
    score = (symmetryScore * 0.25 +
             eyeScore * 0.20 +
             skinScore * 0.15 +
             jawScore * 0.15 +
             lipsScore * 0.15 +
             noseScore * 0.10 +
             smileBonus * 0.3).clamp(1.0, 10.0);

    // Round to 1 decimal
    score = double.parse(score.toStringAsFixed(1));

    return FaceResult(
      overallScore: score,
      symmetry: double.parse(symmetryScore.toStringAsFixed(1)),
      eyes: double.parse(eyeScore.toStringAsFixed(1)),
      skin: double.parse(skinScore.toStringAsFixed(1)),
      jawline: double.parse(jawScore.toStringAsFixed(1)),
      lips: double.parse(lipsScore.toStringAsFixed(1)),
      nose: double.parse(noseScore.toStringAsFixed(1)),
      celebrity: _getRandomCelebrity(),
      matchPercent: 55 + random.nextInt(35),
    );
  }

  static String _getRandomCelebrity() {
    final celebrities = [
      'Chris Hemsworth', 'Margot Robbie', 'Timothée Chalamet',
      'Zendaya', 'Henry Cavill', 'Gal Gadot', 'Tom Holland',
      'Scarlett Johansson', 'Ryan Reynolds', 'Jennifer Lawrence',
      'Brad Pitt', 'Angelina Jolie', 'Chris Evans', 'Emma Watson',
      'Leonardo DiCaprio', 'Natalie Portman', 'Idris Elba',
      'Priyanka Chopra', 'Jason Momoa', 'Lupita Nyong\'o',
    ];
    return celebrities[Random().nextInt(celebrities.length)];
  }

  static void dispose() {
    _detector.close();
  }
}

class FaceResult {
  final double overallScore;
  final double symmetry;
  final double eyes;
  final double skin;
  final double jawline;
  final double lips;
  final double nose;
  final String celebrity;
  final int matchPercent;

  FaceResult({
    required this.overallScore,
    required this.symmetry,
    required this.eyes,
    required this.skin,
    required this.jawline,
    required this.lips,
    required this.nose,
    required this.celebrity,
    required this.matchPercent,
  });
}
