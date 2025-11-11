// lib/domain/ai_engine/prompt_builder/weekly_prompt_builder.dart
// Dart类文件

import '../../../data/models/user_model.dart';
import '../logic/meal_source_logic.dart';
import '../logic/preference_logic.dart';
import '../logic/avoidance_logic.dart';
import '../logic/special_diet_logic.dart';

/// 每周推荐AI提示词构建器
///
/// 基于用户设置中的默认餐食来源和就餐形式构建一周的推荐
class WeeklyPromptBuilder {
  // ==================== 核心构建方法 ====================

  /// 构建完整的每周推荐提示词
  static String build({
    required UserProfile user,
    required int dayOfWeek, // 1-7，表示周一到周日
  }) {
    StringBuffer prompt = StringBuffer();

    // 1. 系统角色
    prompt.writeln(_buildSystemRole());
    prompt.writeln();

    // 2. 用户基础信息
    prompt.writeln(_buildUserInfo(user));
    prompt.writeln();

    // 3. 默认餐食来源（使用用户设置中的默认值）
    prompt.writeln(_buildDefaultMealSourceInfo(user));
    prompt.writeln();

    // 4. 默认就餐形式（使用用户设置中的默认值）
    prompt.writeln(_buildDefaultDiningStyleInfo(user));
    prompt.writeln();

    // 5. 今日菜系（每天轮换）
    String todayCuisine = PreferenceLogic.rotateCuisine(
      user.preferredCuisines,
      dayOfWeek,
    );
    prompt.writeln(_buildDailyCuisineInfo(todayCuisine, dayOfWeek));
    prompt.writeln();

    // 6. 忌口清单
    prompt.writeln(_buildAvoidanceInfo(user));
    prompt.writeln();

    // 7. 特殊饮食需求
    if (user.isVegetarian || user.hasHighBloodSugar) {
      prompt.writeln(_buildSpecialDietInfo(user));
      prompt.writeln();
    }

    // 8. 零食建议
    prompt.writeln(_buildSnackInfo(user));
    prompt.writeln();

    // 9. 营养目标
    prompt.writeln(_buildNutritionTargets(user));
    prompt.writeln();

    // 10. 免费版特别说明
    prompt.writeln(_buildFreeVersionNote());
    prompt.writeln();

    // 11. 输出格式要求
    prompt.writeln(_buildOutputFormat());

    return prompt.toString();
  }

  // ==================== 各部分构建 ====================

  /// 构建系统角色
  static String _buildSystemRole() {
    return '''
你是一位专业的营养师和健康饮食顾问，擅长根据用户的需求推荐个性化的每周餐食方案。
你的任务是为用户推荐一天的三餐（早餐、午餐、晚餐），作为每周推荐的一部分。
注意：这是免费版推荐，请不要提供详细的菜谱步骤。
''';
  }

  /// 构建用户基础信息
  static String _buildUserInfo(UserProfile user) {
    return '''
=== 用户基础信息 ===
健康目标：${user.healthGoal}
年龄：${user.age ?? '未提供'}岁
性别：${user.gender ?? '未提供'}
${user.bmi != null ? 'BMI: ${user.bmi!.toStringAsFixed(1)} (${user.bmiRating})' : ''}
''';
  }

  /// 构建默认餐食来源信息
  static String _buildDefaultMealSourceInfo(UserProfile user) {
    int mealSource = user.defaultMealSource;

    return '''
=== 餐食来源（用户默认设置） ===
级别：$mealSource (${MealSourceLogic.getRecommendationType(mealSource)})

${MealSourceLogic.getAIPromptDescription(mealSource)}

重要提示：用户是免费版，请不要提供详细的制作步骤和烹饪时间。
- 只需提供菜品名称和食材清单
- 不需要详细的份量和具体步骤
''';
  }

  /// 构建默认就餐形式信息
  static String _buildDefaultDiningStyleInfo(UserProfile user) {
    String diningStyle = user.defaultDiningStyle;

    // 获取份量信息
    String portionInfo = '';
    if (diningStyle == '主要自己吃') {
      portionInfo = '单人份';
    } else if (diningStyle == '经常和朋友家人') {
      portionInfo = '2-4人份，适合家庭';
    } else if (diningStyle == '经常和同事') {
      portionInfo = '适合外出就餐';
    }

    return '''
=== 就餐形式（用户默认设置） ===
就餐方式：$diningStyle
份量建议：$portionInfo
''';
  }

  /// 构建今日菜系信息
  static String _buildDailyCuisineInfo(String todayCuisine, int dayOfWeek) {
    final weekdays = ['', '周一', '周二', '周三', '周四', '周五', '周六', '周日'];

    return '''
=== 今日菜系 (${weekdays[dayOfWeek]}) ===
今天推荐：$todayCuisine

菜系特点：
${PreferenceLogic.getCuisineCharacteristics(todayCuisine)}

典型菜品参考：
${PreferenceLogic.getCuisineExamples(todayCuisine).take(5).map((e) => '- $e').join('\n')}

请基于以上菜系特点推荐今天的三餐。
''';
  }

  /// 构建忌口信息
  static String _buildAvoidanceInfo(UserProfile user) {
    return '''
=== 忌口清单 ===
${AvoidanceLogic.getAvoidancePromptDescription(
  avoidVegetables: user.avoidVegetables,
  avoidFruits: user.avoidFruits,
  avoidMeats: user.avoidMeats,
  avoidSeafood: user.avoidSeafood,
)}
''';
  }

  /// 构建特殊饮食信息
  static String _buildSpecialDietInfo(UserProfile user) {
    return SpecialDietLogic.getFullSpecialDietPrompt(
      isVegetarian: user.isVegetarian,
      hasHighBloodSugar: user.hasHighBloodSugar,
    );
  }

  /// 构建零食信息
  static String _buildSnackInfo(UserProfile user) {
    return '''
=== 零食建议 ===
${PreferenceLogic.getSnackPromptDescription(user.snackFrequency)}
''';
  }

  /// 构建营养目标
  static String _buildNutritionTargets(UserProfile user) {
    return '''
=== 营养目标 ===
每日目标热量：约${_getTargetCalories(user.healthGoal)} kcal
每日目标蛋白质：约${_getTargetProtein(user.healthGoal)} g
每日目标碳水：约${_getTargetCarbs(user.healthGoal)} g
每日目标脂肪：约${_getTargetFat(user.healthGoal)} g

三餐营养分配：
- 早餐：25-30%的日总热量
- 午餐：35-40%的日总热量
- 晚餐：30-35%的日总热量

关注情绪调节营养素：
- 镁：每餐约100-150mg
- B族维生素：充足摄入
- 色氨酸：每餐约80-100mg
- Omega-3：每餐约0.5g
''';
  }

  /// 构建免费版特别说明
  static String _buildFreeVersionNote() {
    return '''
=== 免费版特别说明 ===

用户当前使用免费版每周推荐功能。请注意：

1. 不要提供详细的菜谱步骤
2. 不要提供具体的烹饪时间
3. 食材清单无需精确份量
4. 重点在于提供健康、营养均衡的餐食建议

如果用户需要详细菜谱和制作步骤，请提示用户升级到VIP版本。
''';
  }

  /// 构建输出格式
  static String _buildOutputFormat() {
    return '''
=== 输出格式要求 ===

请以JSON格式输出，包含以下结构：

{
  "breakfast": {
    "name": "餐食名称",
    "description": "简短描述",
    "foodItems": [
      {
        "name": "食材名称"
      }
    ],
    "nutrition": {
      "calories": 热量(kcal),
      "protein": 蛋白质(g),
      "carbs": 碳水(g),
      "fat": 脂肪(g),
      "magnesium": 镁(mg),
      "vitaminB6": B6(mg),
      "tryptophan": 色氨酸(mg),
      "omega3": Omega-3(g),
      "iron": 铁(mg),
      "fiber": 膳食纤维(g)
    },
    "source": "餐馆/外卖/自己做",
    "totalCost": 预估成本(元)
  },
  "lunch": { ... },
  "dinner": { ... },
  "snack": { ... } // 如果需要零食建议
}

重要：
1. 不要包含 "recipe"、"cookingTime"、"difficulty" 字段
2. foodItems 中不需要 "amount" 和 "unit" 字段
3. 所有食材必须避开忌口清单
4. 符合今日指定的菜系风格
5. 营养成分准确估算
6. 预估成本合理
''';
  }

  // ==================== 辅助方法 ====================

  static int _getTargetCalories(String healthGoal) {
    const targets = {
      '减脂': 1800,
      '增肌': 2500,
      '维持': 2000,
      '随意': 2000,
    };
    return targets[healthGoal] ?? 2000;
  }

  static int _getTargetProtein(String healthGoal) {
    const targets = {
      '减脂': 120,
      '增肌': 150,
      '维持': 100,
      '随意': 100,
    };
    return targets[healthGoal] ?? 100;
  }

  static int _getTargetCarbs(String healthGoal) {
    const targets = {
      '减脂': 180,
      '增肌': 300,
      '维持': 250,
      '随意': 250,
    };
    return targets[healthGoal] ?? 250;
  }

  static int _getTargetFat(String healthGoal) {
    const targets = {
      '减脂': 50,
      '增肌': 80,
      '维持': 70,
      '随意': 70,
    };
    return targets[healthGoal] ?? 70;
  }

  // ==================== 一周计划生成 ====================

  /// 生成一周完整计划的提示词
  static List<String> buildWeeklyPlan(UserProfile user) {
    List<String> weeklyPrompts = [];

    for (int day = 1; day <= 7; day++) {
      String prompt = build(user: user, dayOfWeek: day);
      weeklyPrompts.add(prompt);
    }

    return weeklyPrompts;
  }

  /// 获取周计划摘要
  static String getWeeklySummary(UserProfile user) {
    final cuisines = PreferenceLogic.assignWeeklyCuisines(user.preferredCuisines);

    StringBuffer summary = StringBuffer();
    summary.writeln('=== 本周菜系安排 ===\n');

    cuisines.forEach((day, cuisine) {
      final weekdays = ['', '周一', '周二', '周三', '周四', '周五', '周六', '周日'];
      summary.writeln('${weekdays[day]}: $cuisine');
    });

    return summary.toString();
  }
}