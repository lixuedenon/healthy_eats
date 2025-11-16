// lib/data/models/emotion_roi_model.dart
// Dart类文件

/// 情绪ROI数据模型
class EmotionROI {
  final int totalScore;
  final int antiAnxiety;
  final int sleepAid;
  final int energyBoost;
  final int happiness;
  final int antiFatigue;

  final double magnesiumContribution;
  final double vitaminBContribution;
  final double tryptophanContribution;
  final double omega3Contribution;

  final String rating;
  final String primaryBenefit;
  final String? improvementSuggestion;

  EmotionROI({
    required this.totalScore,
    required this.antiAnxiety,
    required this.sleepAid,
    required this.energyBoost,
    required this.happiness,
    required this.antiFatigue,
    required this.magnesiumContribution,
    required this.vitaminBContribution,
    required this.tryptophanContribution,
    required this.omega3Contribution,
    required this.rating,
    required this.primaryBenefit,
    this.improvementSuggestion,
  });
}