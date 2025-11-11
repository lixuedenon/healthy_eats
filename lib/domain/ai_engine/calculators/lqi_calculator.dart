// lib/domain/ai_engine/calculators/lqi_calculator.dart
// Dart类文件

import '../../../data/models/lqi_model.dart';
import '../../../data/models/meal_model.dart';
import '../../../data/models/emotion_roi_model.dart';
import '../../../core/constants/roi_standards.dart';
import 'emotion_roi_calculator.dart';
import 'nutrition_calculator.dart';

/// LQI生活质量指数计算器
///
/// 综合评估健康指数、情绪指数、预算优化、便捷性四大维度
class LQICalculator {
  // ==================== 核心计算方法 ====================

  /// 计算每日LQI
  static LQI calculateDaily({
    required List<Meal> meals,
    required int targetCalories,
    required int targetProtein,
    required int targetCarbs,
    required int targetFat,
    double? totalBudget,
  }) {
    // 1. 计算健康指数
    int healthIndex = _calculateHealthIndex(
      meals: meals,
      targetCalories: targetCalories,
      targetProtein: targetProtein,
      targetCarbs: targetCarbs,
      targetFat: targetFat,
    );

    // 2. 计算情绪指数
    int emotionIndex = _calculateEmotionIndex(meals);

    // 3. 计算预算优化
    int budgetOptimization = _calculateBudgetOptimization(
      meals: meals,
      totalBudget: totalBudget,
    );

    // 4. 计算便捷性
    int convenience = _calculateConvenience(meals);

    // 5. 计算总分（加权平均）
    int totalScore = (
      healthIndex * 0.35 +
      emotionIndex * 0.30 +
      budgetOptimization * 0.20 +
      convenience * 0.15
    ).round();

    // 6. 确定评级
    String rating = ROIStandards.getLQIRating(totalScore);

    // 7. 生成目标提示
    String goalMessage = ROIStandards.getLQIGoalMessage(totalScore);

    // 8. 生成改善建议
    String? improvementSuggestion = _generateImprovementSuggestion(
      totalScore: totalScore,
      healthIndex: healthIndex,
      emotionIndex: emotionIndex,
      budgetOptimization: budgetOptimization,
      convenience: convenience,
    );

    return LQI(
      totalScore: totalScore,
      healthIndex: healthIndex,
      emotionIndex: emotionIndex,
      budgetOptimization: budgetOptimization,
      convenience: convenience,
      rating: rating,
      goalMessage: goalMessage,
      improvementSuggestion: improvementSuggestion,
      calculatedAt: DateTime.now(),
    );
  }

  // ==================== 各维度计算 ====================

  /// 计算健康指数（0-100）
  ///
  /// 基于营养摄入是否达标、营养平衡等
  static int _calculateHealthIndex({
    required List<Meal> meals,
    required int targetCalories,
    required int targetProtein,
    required int targetCarbs,
    required int targetFat,
  }) {
    if (meals.isEmpty) return 0;

    // 计算总营养摄入
    final totalNutrition = NutritionCalculator.calculateDailyNutrition(meals);

    // 计算营养达标情况
    final adequacy = NutritionCalculator.checkNutritionAdequacy(
      actual: totalNutrition,
      targetCalories: targetCalories,
      targetProtein: targetProtein,
      targetCarbs: targetCarbs,
      targetFat: targetFat,
    );

    int score = 100;

    // 热量偏差扣分
    final caloriesPercent = adequacy['calories']!['percentage'] as int;
    if (caloriesPercent < 80 || caloriesPercent > 120) {
      score -= 20;
    } else if (caloriesPercent < 90 || caloriesPercent > 110) {
      score -= 10;
    }

    // 蛋白质偏差扣分
    final proteinPercent = adequacy['protein']!['percentage'] as int;
    if (proteinPercent < 80) {
      score -= 15;
    } else if (proteinPercent < 90) {
      score -= 8;
    }

    // 营养平衡分析
    final balance = NutritionCalculator.analyzeNutrientBalance(totalNutrition);
    if (!balance['isBalanced']) {
      score -= 10;
    } else {
      score += 5; // 平衡良好加分
    }

    // 微量营养素分析
    final microAnalysis = NutritionCalculator.analyzeMicronutrients(totalNutrition);
    int sufficientCount = microAnalysis.values.where((v) => v.contains('充足')).length;
    score += sufficientCount * 3; // 每个充足的微量营养素加3分

    return score.clamp(0, 100);
  }

  /// 计算情绪指数（0-100）
  ///
  /// 基于情绪ROI的平均分数
  static int _calculateEmotionIndex(List<Meal> meals) {
    if (meals.isEmpty) return 0;

    // 计算平均情绪ROI
    EmotionROI averageROI = EmotionROICalculator.calculateDailyAverage(meals);

    return averageROI.totalScore;
  }

  /// 计算预算优化（0-100）
  ///
  /// 基于成本控制、性价比等
  static int _calculateBudgetOptimization({
    required List<Meal> meals,
    double? totalBudget,
  }) {
    if (meals.isEmpty) return 50; // 默认中等

    // 计算实际花费
    double actualCost = 0;
    for (Meal meal in meals) {
      if (meal.totalCost != null) {
        actualCost += meal.totalCost!;
      }
    }

    if (totalBudget == null || totalBudget == 0) {
      // 如果没有设置预算，按照平均成本评分
      // 假设合理的每日预算是50-100元
      if (actualCost <= 60) {
        return 90; // 成本控制良好
      } else if (actualCost <= 80) {
        return 80; // 成本适中
      } else if (actualCost <= 100) {
        return 70; // 成本偏高
      } else {
        return 60; // 成本很高
      }
    }

    // 根据预算使用率评分
    double budgetUsage = actualCost / totalBudget;

    int score = 100;

    if (budgetUsage <= 0.8) {
      score = 95; // 预算控制优秀
    } else if (budgetUsage <= 0.9) {
      score = 90; // 预算控制良好
    } else if (budgetUsage <= 1.0) {
      score = 85; // 预算使用合理
    } else if (budgetUsage <= 1.1) {
      score = 75; // 稍微超预算
    } else if (budgetUsage <= 1.2) {
      score = 65; // 超预算较多
    } else {
      score = 50; // 严重超预算
    }

    return score;
  }

  /// 计算便捷性（0-100）
  ///
  /// 基于烹饪时间、餐食来源等
  static int _calculateConvenience(List<Meal> meals) {
    if (meals.isEmpty) return 0;

    int score = 100;
    int totalMinutes = 0;
    int mealCount = 0;

    for (Meal meal in meals) {
      if (meal.cookingTime != null) {
        totalMinutes += meal.cookingTime!;
        mealCount++;
      } else if (meal.source.contains('餐馆') || meal.source.contains('外卖')) {
        // 餐馆外卖视为0分钟烹饪
        mealCount++;
      }
    }

    if (mealCount == 0) return 80; // 默认值

    // 计算平均烹饪时间
    double avgCookingTime = mealCount > 0 ? totalMinutes / mealCount : 0;

    // 根据平均烹饪时间评分
    if (avgCookingTime <= 15) {
      score = 95; // 非常便捷
    } else if (avgCookingTime <= 25) {
      score = 85; // 比较便捷
    } else if (avgCookingTime <= 35) {
      score = 75; // 中等便捷
    } else if (avgCookingTime <= 45) {
      score = 65; // 稍显繁琐
    } else {
      score = 55; // 比较繁琐
    }

    // 根据餐食来源调整
    int restaurantCount = meals.where((m) =>
      m.source.contains('餐馆') || m.source.contains('外卖')
    ).length;

    double restaurantRatio = restaurantCount / meals.length;

    // 适度外食可以提高便捷性
    if (restaurantRatio >= 0.3 && restaurantRatio <= 0.5) {
      score += 5; // 适度外食加分
    } else if (restaurantRatio > 0.7) {
      score -= 5; // 过度外食扣分（可能影响健康）
    }

    return score.clamp(0, 100);
  }

  // ==================== 改善建议生成 ====================

  /// 生成改善建议
  static String? _generateImprovementSuggestion({
    required int totalScore,
    required int healthIndex,
    required int emotionIndex,
    required int budgetOptimization,
    required int convenience,
  }) {
    if (totalScore >= ROIStandards.LQI_TARGET) {
      return null; // 已达目标，不需要建议
    }

    // 找出得分最低的维度
    Map<String, int> dimensions = {
      '健康指数': healthIndex,
      '情绪指数': emotionIndex,
      '预算优化': budgetOptimization,
      '便捷性': convenience,
    };

    String lowestDimension = dimensions.keys.first;
    int lowestScore = dimensions.values.first;

    dimensions.forEach((key, value) {
      if (value < lowestScore) {
        lowestScore = value;
        lowestDimension = key;
      }
    });

    // 根据最低维度生成建议
    switch (lowestDimension) {
      case '健康指数':
        return '建议：注意营养均衡，确保蛋白质、碳水、脂肪比例合理，多摄入蔬菜水果。';
      case '情绪指数':
        return '建议：增加富含镁、B族维生素、色氨酸的食物，如坚果、全谷物、香蕉等。';
      case '预算优化':
        return '建议：合理规划饮食预算，选择性价比高的食材，减少不必要的外食。';
      case '便捷性':
        return '建议：提前规划菜单，选择快手菜，或适当增加外卖餐馆的比例。';
      default:
        return '继续保持均衡的生活方式。';
    }
  }

  // ==================== 趋势分析 ====================

  /// 计算LQI趋势
  static Map<String, dynamic> calculateTrend(List<LQI> historicalData) {
    if (historicalData.isEmpty) {
      return {
        'trend': 'insufficient_data',
        'averageScore': 0,
        'improvement': 0,
      };
    }

    if (historicalData.length == 1) {
      return {
        'trend': 'stable',
        'averageScore': historicalData.first.totalScore,
        'improvement': 0,
      };
    }

    // 计算平均分
    int sum = historicalData.fold(0, (prev, lqi) => prev + lqi.totalScore);
    int average = (sum / historicalData.length).round();

    // 计算趋势
    int firstHalfSum = 0;
    int secondHalfSum = 0;
    int halfPoint = historicalData.length ~/ 2;

    for (int i = 0; i < halfPoint; i++) {
      firstHalfSum += historicalData[i].totalScore;
    }

    for (int i = halfPoint; i < historicalData.length; i++) {
      secondHalfSum += historicalData[i].totalScore;
    }

    int firstHalfAvg = (firstHalfSum / halfPoint).round();
    int secondHalfAvg = (secondHalfSum / (historicalData.length - halfPoint)).round();

    int improvement = secondHalfAvg - firstHalfAvg;

    String trend = 'stable';
    if (improvement >= 5) {
      trend = 'improving';
    } else if (improvement <= -5) {
      trend = 'declining';
    }

    return {
      'trend': trend,
      'averageScore': average,
      'improvement': improvement,
      'firstHalfAvg': firstHalfAvg,
      'secondHalfAvg': secondHalfAvg,
    };
  }
}