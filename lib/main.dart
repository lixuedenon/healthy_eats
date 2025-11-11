// lib/domain/ai_engine/calculators/nutrition_calculator.dart
// Dart类文件

import '../../../data/models/nutrition_model.dart';
import '../../../data/models/food_item_model.dart';
import '../../../data/models/meal_model.dart';

/// 营养计算器
///
/// 用于计算食物、餐食的营养成分
class NutritionCalculator {
  // ==================== 基础计算 ====================

  /// 计算单个餐食的总营养成分
  static Nutrition calculateMealNutrition(Meal meal) {
    if (meal.foodItems.isEmpty) {
      return Nutrition.empty;
    }

    // 累加所有食物项的营养成分
    Nutrition total = meal.foodItems.first.nutrition;

    for (int i = 1; i < meal.foodItems.length; i++) {
      total = total + meal.foodItems[i].nutrition;
    }

    return total;
  }

  /// 计算多个餐食的总营养成分
  static Nutrition calculateDailyNutrition(List<Meal> meals) {
    if (meals.isEmpty) {
      return Nutrition.empty;
    }

    Nutrition total = Nutrition.empty;

    for (Meal meal in meals) {
      total = total + meal.nutrition;
    }

    return total;
  }

  /// 计算食物列表的总营养成分
  static Nutrition calculateFoodListNutrition(List<FoodItem> foodItems) {
    if (foodItems.isEmpty) {
      return Nutrition.empty;
    }

    Nutrition total = foodItems.first.nutrition;

    for (int i = 1; i < foodItems.length; i++) {
      total = total + foodItems[i].nutrition;
    }

    return total;
  }

  // ==================== 营养达标判断 ====================

  /// 判断营养摄入是否达标
  ///
  /// 返回：{
  ///   'calories': {'actual': 1800, 'target': 2000, 'percentage': 90, 'isAdequate': true},
  ///   'protein': {...},
  ///   ...
  /// }
  static Map<String, Map<String, dynamic>> checkNutritionAdequacy({
    required Nutrition actual,
    required int targetCalories,
    required int targetProtein,
    required int targetCarbs,
    required int targetFat,
  }) {
    return {
      'calories': _checkNutrient(
        actual: actual.calories,
        target: targetCalories.toDouble(),
        unit: 'kcal',
      ),
      'protein': _checkNutrient(
        actual: actual.protein,
        target: targetProtein.toDouble(),
        unit: 'g',
      ),
      'carbs': _checkNutrient(
        actual: actual.carbs,
        target: targetCarbs.toDouble(),
        unit: 'g',
      ),
      'fat': _checkNutrient(
        actual: actual.fat,
        target: targetFat.toDouble(),
        unit: 'g',
      ),
    };
  }

  /// 检查单个营养素
  static Map<String, dynamic> _checkNutrient({
    required double actual,
    required double target,
    required String unit,
  }) {
    double percentage = (actual / target) * 100;
    bool isAdequate = percentage >= 80 && percentage <= 120; // 80%-120%为合理范围
    bool isExcessive = percentage > 120;
    bool isInsufficient = percentage < 80;

    String status = 'adequate';
    if (isExcessive) {
      status = 'excessive';
    } else if (isInsufficient) {
      status = 'insufficient';
    }

    return {
      'actual': actual,
      'target': target,
      'percentage': percentage.round(),
      'unit': unit,
      'isAdequate': isAdequate,
      'isExcessive': isExcessive,
      'isInsufficient': isInsufficient,
      'status': status,
      'gap': target - actual,
    };
  }

  // ==================== 微量营养素分析 ====================

  /// 分析微量营养素含量
  static Map<String, String> analyzeMicronutrients(Nutrition nutrition) {
    Map<String, String> analysis = {};

    // 镁
    if (nutrition.magnesium != null) {
      if (nutrition.magnesium! >= 320) {
        analysis['镁'] = '充足 ↑';
      } else if (nutrition.magnesium! >= 200) {
        analysis['镁'] = '适量 ✓';
      } else {
        analysis['镁'] = '不足 ↓';
      }
    }

    // B族维生素（这里简化处理，实际应该分别计算B6、B12等）
    if (nutrition.vitaminB6 != null || nutrition.vitaminB12 != null) {
      analysis['B族维生素'] = '充足 ↑';
    }

    // 色氨酸
    if (nutrition.tryptophan != null) {
      if (nutrition.tryptophan! >= 200) {
        analysis['色氨酸'] = '充足 ↑';
      } else if (nutrition.tryptophan! >= 100) {
        analysis['色氨酸'] = '适量 ✓';
      } else {
        analysis['色氨酸'] = '不足 ↓';
      }
    }

    // Omega-3
    if (nutrition.omega3 != null) {
      if (nutrition.omega3! >= 1.5) {
        analysis['Omega-3'] = '充足 ↑';
      } else if (nutrition.omega3! >= 1.0) {
        analysis['Omega-3'] = '适量 ✓';
      } else {
        analysis['Omega-3'] = '不足 ↓';
      }
    }

    // 维生素C
    if (nutrition.vitaminC != null) {
      if (nutrition.vitaminC! >= 80) {
        analysis['维生素C'] = '充足 ↑';
      } else if (nutrition.vitaminC! >= 50) {
        analysis['维生素C'] = '适量 ✓';
      } else {
        analysis['维生素C'] = '不足 ↓';
      }
    }

    // 铁
    if (nutrition.iron != null) {
      if (nutrition.iron! >= 15) {
        analysis['铁'] = '充足 ↑';
      } else if (nutrition.iron! >= 10) {
        analysis['铁'] = '适量 ✓';
      } else {
        analysis['铁'] = '不足 ↓';
      }
    }

    // 膳食纤维
    if (nutrition.fiber != null) {
      if (nutrition.fiber! >= 25) {
        analysis['膳食纤维'] = '充足 ↑';
      } else if (nutrition.fiber! >= 15) {
        analysis['膳食纤维'] = '适量 ✓';
      } else {
        analysis['膳食纤维'] = '不足 ↓';
      }
    }

    return analysis;
  }

  // ==================== 营养平衡分析 ====================

  /// 分析三大营养素比例是否合理
  ///
  /// 理想比例：蛋白质 15-20%, 碳水 50-60%, 脂肪 25-30%
  static Map<String, dynamic> analyzeNutrientBalance(Nutrition nutrition) {
    double proteinPercent = nutrition.proteinPercentage;
    double carbsPercent = nutrition.carbsPercentage;
    double fatPercent = nutrition.fatPercentage;

    bool isProteinBalanced = proteinPercent >= 15 && proteinPercent <= 25;
    bool isCarbsBalanced = carbsPercent >= 45 && carbsPercent <= 65;
    bool isFatBalanced = fatPercent >= 20 && fatPercent <= 35;

    bool isBalanced = isProteinBalanced && isCarbsBalanced && isFatBalanced;

    List<String> suggestions = [];

    if (!isProteinBalanced) {
      if (proteinPercent < 15) {
        suggestions.add('蛋白质比例偏低，建议增加优质蛋白摄入');
      } else {
        suggestions.add('蛋白质比例偏高，可适当减少');
      }
    }

    if (!isCarbsBalanced) {
      if (carbsPercent < 45) {
        suggestions.add('碳水化合物比例偏低，建议适当增加主食');
      } else {
        suggestions.add('碳水化合物比例偏高，建议减少主食摄入');
      }
    }

    if (!isFatBalanced) {
      if (fatPercent < 20) {
        suggestions.add('脂肪比例偏低，建议适当增加健康脂肪');
      } else {
        suggestions.add('脂肪比例偏高，建议减少油脂摄入');
      }
    }

    return {
      'isBalanced': isBalanced,
      'proteinPercent': proteinPercent.round(),
      'carbsPercent': carbsPercent.round(),
      'fatPercent': fatPercent.round(),
      'isProteinBalanced': isProteinBalanced,
      'isCarbsBalanced': isCarbsBalanced,
      'isFatBalanced': isFatBalanced,
      'suggestions': suggestions,
    };
  }

  // ==================== 营养评分 ====================

  /// 计算营养评分（0-100）
  static int calculateNutritionScore({
    required Nutrition actual,
    required int targetCalories,
    required int targetProtein,
    required int targetCarbs,
    required int targetFat,
  }) {
    int score = 100;

    // 热量偏差扣分
    double caloriesDiff = (actual.calories - targetCalories).abs();
    double caloriesDeviation = caloriesDiff / targetCalories;
    if (caloriesDeviation > 0.2) score -= 20; // 偏差>20%扣20分
    else if (caloriesDeviation > 0.1) score -= 10; // 偏差>10%扣10分

    // 蛋白质偏差扣分
    double proteinDiff = (actual.protein - targetProtein).abs();
    double proteinDeviation = proteinDiff / targetProtein;
    if (proteinDeviation > 0.2) score -= 15;
    else if (proteinDeviation > 0.1) score -= 8;

    // 碳水偏差扣分
    double carbsDiff = (actual.carbs - targetCarbs).abs();
    double carbsDeviation = carbsDiff / targetCarbs;
    if (carbsDeviation > 0.2) score -= 15;
    else if (carbsDeviation > 0.1) score -= 8;

    // 脂肪偏差扣分
    double fatDiff = (actual.fat - targetFat).abs();
    double fatDeviation = fatDiff / targetFat;
    if (fatDeviation > 0.2) score -= 15;
    else if (fatDeviation > 0.1) score -= 8;

    // 营养平衡加分
    final balance = analyzeNutrientBalance(actual);
    if (balance['isBalanced']) {
      score += 10; // 平衡良好加10分
    }

    // 微量营养素加分
    final microAnalysis = analyzeMicronutrients(actual);
    int sufficientCount = microAnalysis.values.where((v) => v.contains('充足')).length;
    score += sufficientCount * 2; // 每个充足的微量营养素加2分

    // 确保分数在0-100之间
    return score.clamp(0, 100);
  }

  // ==================== 工具方法 ====================

  /// 格式化营养成分显示
  static String formatNutritionDisplay(Nutrition nutrition) {
    return '热量: ${nutrition.calories.toStringAsFixed(0)} kcal\n'
           '蛋白质: ${nutrition.protein.toStringAsFixed(1)} g\n'
           '碳水: ${nutrition.carbs.toStringAsFixed(1)} g\n'
           '脂肪: ${nutrition.fat.toStringAsFixed(1)} g';
  }

  /// 生成营养摘要
  static String generateNutritionSummary({
    required Nutrition actual,
    required int targetCalories,
    required int targetProtein,
  }) {
    final adequacy = checkNutritionAdequacy(
      actual: actual,
      targetCalories: targetCalories,
      targetProtein: targetProtein,
      targetCarbs: 250,
      targetFat: 70,
    );

    final caloriesStatus = adequacy['calories']!['status'];
    final proteinStatus = adequacy['protein']!['status'];

    String summary = '';

    if (caloriesStatus == 'adequate' && proteinStatus == 'adequate') {
      summary = '营养摄入均衡，符合您的目标！';
    } else if (caloriesStatus == 'insufficient') {
      summary = '热量摄入不足，建议适当增加食物摄入。';
    } else if (caloriesStatus == 'excessive') {
      summary = '热量摄入超标，建议控制食物份量。';
    } else if (proteinStatus == 'insufficient') {
      summary = '蛋白质摄入不足，建议增加优质蛋白食物。';
    }

    return summary;
  }
}