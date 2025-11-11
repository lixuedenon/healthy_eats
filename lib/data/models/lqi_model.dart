// lib/data/models/lqi_model.dart
// Dart类文件

/// LQI生活质量指数数据模型
class LQI {
  // ==================== 总分 ====================

  /// LQI总分（0-100）
  final int totalScore;

  // ==================== 四大维度得分 ====================

  /// 健康指数（0-100）
  final int healthIndex;

  /// 情绪指数（0-100）
  final int emotionIndex;

  /// 预算优化（0-100）
  final int budgetOptimization;

  /// 便捷性（0-100）
  final int convenience;

  // ==================== 评级和建议 ====================

  /// 评级（优秀/良好/一般/需改善）
  final String rating;

  /// 目标提示信息
  final String goalMessage;

  /// 改善建议
  final String? improvementSuggestion;

  // ==================== 时间信息 ====================

  final DateTime calculatedAt;

  // ==================== 构造函数 ====================

  LQI({
    required this.totalScore,
    required this.healthIndex,
    required this.emotionIndex,
    required this.budgetOptimization,
    required this.convenience,
    required this.rating,
    required this.goalMessage,
    this.improvementSuggestion,
    required this.calculatedAt,
  });

  // ==================== JSON序列化 ====================

  factory LQI.fromJson(Map<String, dynamic> json) {
    return LQI(
      totalScore: json['totalScore'] as int,
      healthIndex: json['healthIndex'] as int,
      emotionIndex: json['emotionIndex'] as int,
      budgetOptimization: json['budgetOptimization'] as int,
      convenience: json['convenience'] as int,
      rating: json['rating'] as String,
      goalMessage: json['goalMessage'] as String,
      improvementSuggestion: json['improvementSuggestion'] as String?,
      calculatedAt: DateTime.parse(json['calculatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalScore': totalScore,
      'healthIndex': healthIndex,
      'emotionIndex': emotionIndex,
      'budgetOptimization': budgetOptimization,
      'convenience': convenience,
      'rating': rating,
      'goalMessage': goalMessage,
      'improvementSuggestion': improvementSuggestion,
      'calculatedAt': calculatedAt.toIso8601String(),
    };
  }

  // ==================== 工具方法 ====================

  /// 获取各维度得分Map
  Map<String, int> getDimensionScores() {
    return {
      '健康指数': healthIndex,
      '情绪指数': emotionIndex,
      '预算优化': budgetOptimization,
      '便捷性': convenience,
    };
  }

  /// 获取最高得分的维度
  String getHighestScoreDimension() {
    final scores = getDimensionScores();
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
    final scores = getDimensionScores();
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

  /// 判断是否达到目标（≥85分）
  bool isAboveTarget() {
    return totalScore >= 85;
  }

  /// 获取与目标的差距
  int getGapFromTarget() {
    return 85 - totalScore;
  }

  /// 获取进度百分比（0-1）
  double getProgress() {
    return totalScore / 100.0;
  }

  /// 判断某个维度是否达标
  bool isDimensionAboveStandard(String dimension, int standard) {
    final scores = getDimensionScores();
    final score = scores[dimension];
    if (score == null) return false;
    return score >= standard;
  }

  /// 获取简短描述
  String getShortDescription() {
    return 'LQI: $totalScore/100 · $rating';
  }

  /// 获取需要改善的维度列表（低于标准值的）
  List<String> getNeedImprovementDimensions(Map<String, int> standards) {
    List<String> needImprovement = [];
    final scores = getDimensionScores();

    scores.forEach((dimension, score) {
      final standard = standards[dimension] ?? 80;
      if (score < standard) {
        needImprovement.add(dimension);
      }
    });

    return needImprovement;
  }
}