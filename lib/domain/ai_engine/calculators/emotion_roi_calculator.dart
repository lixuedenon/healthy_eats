// lib/domain/ai_engine/calculators/emotion_roi_calculator.dart
// Dart类文件

import '../../../data/models/nutrition_model.dart';
import '../../../data/models/meal_model.dart';
import '../../../data/models/emotion_roi_model.dart';
import '../../../core/constants/roi_standards.dart';
import '../../../core/constants/nutrition_constants.dart';

/// 情绪ROI计算器
///
/// 根据食物中的情绪调节营养素计算情绪ROI分数
class EmotionROICalculator {
  // ==================== 核心计算方法 ====================

  /// 计算餐食的情绪ROI
  static EmotionROI calculate(Meal meal) {
    return calculateFromNutrition(meal.nutrition);
  }

  /// 从营养成分计算情绪ROI
  static EmotionROI calculateFromNutrition(Nutrition nutrition) {
    // 计算各营养因子的贡献分数
    double magnesiumScore = _calculateMagnesiumScore(nutrition.magnesium);
    double vitaminBScore = _calculateVitaminBScore(
      nutrition.vitaminB6,
      nutrition.vitaminB12,
    );
    double tryptophanScore = _calculateTryptophanScore(nutrition.tryptophan);
    double omega3Score = _calculateOmega3Score(nutrition.omega3);

    // 计算各维度得分
    int antiAnxiety = _calculateAntiAnxiety(
      magnesiumScore,
      vitaminBScore,
      omega3Score,
    );

    int sleepAid = _calculateSleepAid(
      magnesiumScore,
      tryptophanScore,
    );

    int energyBoost = _calculateEnergyBoost(
      vitaminBScore,
      nutrition.iron,
    );

    int happiness = _calculateHappiness(
      tryptophanScore,
      omega3Score,
      vitaminBScore,
    );

    int antiFatigue = _calculateAntiFatigue(
      vitaminBScore,
      nutrition.iron,
      magnesiumScore,
    );

    // 计算总分（加权平均）
    int totalScore = ((antiAnxiety * 0.25) +
                     (sleepAid * 0.20) +
                     (energyBoost * 0.20) +
                     (happiness * 0.20) +
                     (antiFatigue * 0.15)).round();

    // 确定评级
    String rating = ROIStandards.getEmotionROIRating(totalScore);

    // 确定主要益处
    String primaryBenefit = _determinePrimaryBenefit({
      '抗焦虑': antiAnxiety,
      '助眠': sleepAid,
      '提神': energyBoost,
      '愉悦感': happiness,
      '抗疲劳': antiFatigue,
    });

    // 生成改善建议
    String? improvementSuggestion = _generateImprovementSuggestion(
      totalScore,
      magnesiumScore,
      vitaminBScore,
      tryptophanScore,
      omega3Score,
    );

    return EmotionROI(
      totalScore: totalScore,
      antiAnxiety: antiAnxiety,
      sleepAid: sleepAid,
      energyBoost: energyBoost,
      happiness: happiness,
      antiFatigue: antiFatigue,
      magnesiumContribution: magnesiumScore,
      vitaminBContribution: vitaminBScore,
      tryptophanContribution: tryptophanScore,
      omega3Contribution: omega3Score,
      rating: rating,
      primaryBenefit: primaryBenefit,
      improvementSuggestion: improvementSuggestion,
    );
  }

  // ==================== 营养因子贡献分数计算 ====================

  /// 计算镁的贡献分数（0-100）
  static double _calculateMagnesiumScore(double? magnesium) {
    if (magnesium == null) return 0;

    // 标准值：400mg/天，单餐约130mg
    const double standard = 130;
    double ratio = magnesium / standard;

    // 使用对数曲线，避免线性增长过快
    double score = (ratio * 100).clamp(0, 100);
    return score;
  }

  /// 计算B族维生素的贡献分数（0-100）
  static double _calculateVitaminBScore(double? b6, double? b12) {
    double score = 0;

    // B6标准：1.5mg/天，单餐约0.5mg
    if (b6 != null) {
      double b6Ratio = b6 / 0.5;
      score += (b6Ratio * 50).clamp(0, 50);
    }

    // B12标准：2.4μg/天，单餐约0.8μg
    if (b12 != null) {
      double b12Ratio = b12 / 0.8;
      score += (b12Ratio * 50).clamp(0, 50);
    }

    return score.clamp(0, 100);
  }

  /// 计算色氨酸的贡献分数（0-100）
  static double _calculateTryptophanScore(double? tryptophan) {
    if (tryptophan == null) return 0;

    // 标准值：250mg/天，单餐约85mg
    const double standard = 85;
    double ratio = tryptophan / standard;

    double score = (ratio * 100).clamp(0, 100);
    return score;
  }

  /// 计算Omega-3的贡献分数（0-100）
  static double _calculateOmega3Score(double? omega3) {
    if (omega3 == null) return 0;

    // 标准值：1.6g/天，单餐约0.5g
    const double standard = 0.5;
    double ratio = omega3 / standard;

    double score = (ratio * 100).clamp(0, 100);
    return score;
  }

  // ==================== 各维度得分计算 ====================

  /// 计算抗焦虑得分
  static int _calculateAntiAnxiety(
    double magnesiumScore,
    double vitaminBScore,
    double omega3Score,
  ) {
    // 加权计算：镁40%、B族30%、Omega-3 30%
    double score = magnesiumScore * 0.4 +
                   vitaminBScore * 0.3 +
                   omega3Score * 0.3;
    return score.round().clamp(0, 100);
  }

  /// 计算助眠得分
  static int _calculateSleepAid(
    double magnesiumScore,
    double tryptophanScore,
  ) {
    // 加权计算：镁50%、色氨酸50%
    double score = magnesiumScore * 0.5 + tryptophanScore * 0.5;
    return score.round().clamp(0, 100);
  }

  /// 计算提神得分
  static int _calculateEnergyBoost(
    double vitaminBScore,
    double? iron,
  ) {
    double ironScore = 0;
    if (iron != null) {
      // 铁标准：18mg/天，单餐约6mg
      double ironRatio = iron / 6.0;
      ironScore = (ironRatio * 100).clamp(0, 100);
    }

    // 加权计算：B族60%、铁40%
    double score = vitaminBScore * 0.6 + ironScore * 0.4;
    return score.round().clamp(0, 100);
  }

  /// 计算愉悦感得分
  static int _calculateHappiness(
    double tryptophanScore,
    double omega3Score,
    double vitaminBScore,
  ) {
    // 加权计算：色氨酸40%、Omega-3 30%、B族30%
    double score = tryptophanScore * 0.4 +
                   omega3Score * 0.3 +
                   vitaminBScore * 0.3;
    return score.round().clamp(0, 100);
  }

  /// 计算抗疲劳得分
  static int _calculateAntiFatigue(
    double vitaminBScore,
    double? iron,
    double magnesiumScore,
  ) {
    double ironScore = 0;
    if (iron != null) {
      double ironRatio = iron / 6.0;
      ironScore = (ironRatio * 100).clamp(0, 100);
    }

    // 加权计算：B族40%、铁30%、镁30%
    double score = vitaminBScore * 0.4 +
                   ironScore * 0.3 +
                   magnesiumScore * 0.3;
    return score.round().clamp(0, 100);
  }

  // ==================== 辅助方法 ====================

  /// 确定主要益处
  static String _determinePrimaryBenefit(Map<String, int> scores) {
    String maxKey = scores.keys.first;
    int maxValue = scores.values.first;

    scores.forEach((key, value) {
      if (value > maxValue) {
        maxValue = value;
        maxKey = key;
      }
    });

    return maxKey;
  }

  /// 生成改善建议
  static String? _generateImprovementSuggestion(
    int totalScore,
    double magnesiumScore,
    double vitaminBScore,
    double tryptophanScore,
    double omega3Score,
  ) {
    if (totalScore >= ROIStandards.EMOTION_ROI_EXCELLENT) {
      return null; // 已经很好，不需要建议
    }

    List<String> suggestions = [];

    // 找出得分较低的营养素
    if (magnesiumScore < 50) {
      suggestions.add('增加富含镁的食物（如${NutritionConstants.MAGNESIUM_RICH_FOODS.take(3).join('、')}）');
    }

    if (vitaminBScore < 50) {
      suggestions.add('增加富含B族维生素的食物（如${NutritionConstants.VITAMIN_B_RICH_FOODS.take(3).join('、')}）');
    }

    if (tryptophanScore < 50) {
      suggestions.add('增加富含色氨酸的食物（如${NutritionConstants.TRYPTOPHAN_RICH_FOODS.take(3).join('、')}）');
    }

    if (omega3Score < 50) {
      suggestions.add('增加富含Omega-3的食物（如${NutritionConstants.OMEGA3_RICH_FOODS.take(3).join('、')}）');
    }

    if (suggestions.isEmpty) {
      return '继续保持均衡饮食，适当增加情绪调节营养素。';
    }

    return suggestions.take(2).join('；');
  }

  // ==================== 批量计算 ====================

  /// 计算一天所有餐食的平均情绪ROI
  static EmotionROI calculateDailyAverage(List<Meal> meals) {
    if (meals.isEmpty) {
      return EmotionROI(
        totalScore: 0,
        antiAnxiety: 0,
        sleepAid: 0,
        energyBoost: 0,
        happiness: 0,
        antiFatigue: 0,
        magnesiumContribution: 0,
        vitaminBContribution: 0,
        tryptophanContribution: 0,
        omega3Contribution: 0,
        rating: '需改善',
        primaryBenefit: '无',
      );
    }

    // 累加所有餐食的营养成分
    Nutrition totalNutrition = Nutrition.empty;
    for (Meal meal in meals) {
      totalNutrition = totalNutrition + meal.nutrition;
    }

    return calculateFromNutrition(totalNutrition);
  }

  /// 计算一周的平均情绪ROI
  static Map<String, dynamic> calculateWeeklyStats(List<List<Meal>> weekMeals) {
    List<int> dailyScores = [];

    for (List<Meal> dayMeals in weekMeals) {
      EmotionROI dayROI = calculateDailyAverage(dayMeals);
      dailyScores.add(dayROI.totalScore);
    }

    if (dailyScores.isEmpty) {
      return {
        'averageScore': 0,
        'maxScore': 0,
        'minScore': 0,
        'trend': 'stable',
      };
    }

    int sum = dailyScores.reduce((a, b) => a + b);
    int average = (sum / dailyScores.length).round();
    int maxScore = dailyScores.reduce((a, b) => a > b ? a : b);
    int minScore = dailyScores.reduce((a, b) => a < b ? a : b);

    // 判断趋势
    String trend = 'stable';
    if (dailyScores.length >= 3) {
      int firstHalfAvg = (dailyScores.take(dailyScores.length ~/ 2).reduce((a, b) => a + b) /
                         (dailyScores.length ~/ 2)).round();
      int secondHalfAvg = (dailyScores.skip(dailyScores.length ~/ 2).reduce((a, b) => a + b) /
                          (dailyScores.length - dailyScores.length ~/ 2)).round();

      if (secondHalfAvg > firstHalfAvg + 5) {
        trend = 'improving';
      } else if (secondHalfAvg < firstHalfAvg - 5) {
        trend = 'declining';
      }
    }

    return {
      'averageScore': average,
      'maxScore': maxScore,
      'minScore': minScore,
      'trend': trend,
      'dailyScores': dailyScores,
    };
  }
}