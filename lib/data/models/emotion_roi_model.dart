// lib/data/models/emotion_roi_model.dart
// Dart类文件

/// 情绪ROI数据模型
class EmotionROI {
  // ==================== 总分 ====================

  /// 情绪ROI总分（0-100）
  final int totalScore;

  // ==================== 各维度得分 ====================

  /// 抗焦虑得分（0-100）
  final int antiAnxiety;

  /// 助眠得分（0-100）
  final int sleepAid;

  /// 提神得分（0-100）
  final int energyBoost;

  /// 愉悦感得分（0-100）
  final int happiness;

  /// 抗疲劳得分（0-100）
  final int antiFatigue;

  // ==================== 营养因子贡献 ====================

  /// 镁的贡献分数
  final double magnesiumContribution;

  /// B族维生素的贡献分数
  final double vitaminBContribution;

  /// 色氨酸的贡献分数
  final double tryptophanContribution;

  /// Omega-3的贡献分数
  final double omega3Contribution;

  // ==================== 评级和建议 ====================

  /// 评级（优秀/良好/一般/较差/需改善）
  final String rating;

  /// 主要益处描述
  final String primaryBenefit;

  /// 改善建议
  final String? improvementSuggestion;

  // ==================== 构造函数 ====================

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

  // ==================== JSON序列化 ====================

  factory EmotionROI.fromJson(Map<String, dynamic> json) {
    return EmotionROI(
      totalScore: json['totalScore'] as int,
      antiAnxiety: json['antiAnxiety'] as int,
      sleepAid: json['sleepAid'] as int,
      energyBoost: json['energyBoost'] as int,
      happiness: json['happiness'] as int,
      antiFatigue: json['antiFatigue'] as int,
      magnesiumContribution: (json['magnesiumContribution'] as num).toDouble(),
      vitaminBContribution: (json['vitaminBContribution'] as num).toDouble(),
      tryptophanContribution: (json['tryptophanContribution'] as num).toDouble(),
      omega3Contribution: (json['omega3Contribution'] as num).toDouble(),
      rating: json['rating'] as String,
      primaryBenefit: json['primaryBenefit'] as String,
      improvementSuggestion: json['improvementSuggestion'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalScore': totalScore,
      'antiAnxiety': antiAnxiety,
      'sleepAid': sleepAid,
      'energyBoost': energyBoost,
      'happiness': happiness,
      'antiFatigue': antiFatigue,
      'magnesiumContribution': magnesiumContribution,
      'vitaminBContribution': vitaminBContribution,
      'tryptophanContribution': tryptophanContribution,
      'omega3Contribution': omega3Contribution,
      'rating': rating,
      'primaryBenefit': primaryBenefit,
      'improvementSuggestion': improvementSuggestion,
    };
  }

  // ==================== 工具方法 ====================

  /// 获取各维度得分Map
  Map<String, int> getSubScores() {
    return {
      '抗焦虑': antiAnxiety,
      '助眠': sleepAid,
      '提神': energyBoost,
      '愉悦感': happiness,
      '抗疲劳': antiFatigue,
    };
  }

  /// 获取最高得分的维度
  String getHighestScoreDimension() {
    final scores = getSubScores();
    String highest = scores.keys.first;
    int maxScore = scores.values.first;

    scores.forEach((key, value) {
      if (value > maxScore) {
        maxScore = value;
        highest = key;
      }
    });

    return highest;
  }

  /// 获取最低得分的维度
  String getLowestScoreDimension() {
    final scores = getSubScores();
    String lowest = scores.keys.first;
    int minScore = scores.values.first;

    scores.forEach((key, value) {
      if (value < minScore) {
        minScore = value;
        lowest = key;
      }
    });

    return lowest;
  }

  /// 获取营养因子贡献Map
  Map<String, double> getNutrientContributions() {
    return {
      '镁': magnesiumContribution,
      'B族维生素': vitaminBContribution,
      '色氨酸': tryptophanContribution,
      'Omega-3': omega3Contribution,
    };
  }

  /// 判断总分是否达标（≥标准值）
  bool isAboveStandard(int standard) {
    return totalScore >= standard;
  }

  /// 获取与标准值的差距
  int getGapFromStandard(int standard) {
    return standard - totalScore;
  }

  /// 获取简短描述
  String getShortDescription() {
    return '情绪ROI: $totalScore/100 · $primaryBenefit';
  }
}