// lib/domain/ai_engine/prompt_builder/weekly_prompt_builder.dart
// Dart类文件

import '../../../data/models/user_model.dart';
import '../logic/meal_source_logic.dart';
import '../logic/preference_logic.dart';
import '../logic/avoidance_logic.dart';
import '../logic/special_diet_logic.dart';

class WeeklyPromptBuilder {
  static String build({
    required UserProfile user,
    required int dayOfWeek,
  }) {
    StringBuffer prompt = StringBuffer();

    prompt.writeln(_buildSystemRole());
    prompt.writeln();

    prompt.writeln(_buildUserInfo(user));
    prompt.writeln();

    prompt.writeln(_buildDefaultMealSourceInfo(user));
    prompt.writeln();

    prompt.writeln(_buildDefaultDiningStyleInfo(user));
    prompt.writeln();

    String todayCuisine = PreferenceLogic.rotateCuisine(
      user.preferredCuisines,
      dayOfWeek,
    );
    prompt.writeln(_buildDailyCuisineInfo(todayCuisine, dayOfWeek));
    prompt.writeln();

    prompt.writeln(_buildAvoidanceInfo(user));
    prompt.writeln();

    if (user.isVegetarian || user.hasHighBloodSugar) {
      prompt.writeln(_buildSpecialDietInfo(user));
      prompt.writeln();
    }

    prompt.writeln(_buildSnackInfo(user));
    prompt.writeln();

    prompt.writeln(_buildNutritionTargets(user));
    prompt.writeln();

    prompt.writeln(_buildFreeVersionNote());
    prompt.writeln();

    prompt.writeln(_buildOutputFormat());

    return prompt.toString();
  }

  static String _buildSystemRole() {
    return '''
你是一位专业的营养师和健康饮食顾问，擅长根据用户的需求推荐个性化的每周餐食方案。
你的任务是为用户推荐一天的三餐（早餐、午餐、晚餐），作为每周推荐的一部分。
注意：这是免费版推荐，请不要提供详细的菜谱步骤。
''';
  }

  static String _buildUserInfo(UserProfile user) {
    return '''
=== 用户基础信息 ===
健康目标：${user.healthGoal}
年龄：${user.age ?? '未提供'}岁
性别：${user.gender ?? '未提供'}
身高：${user.height ?? '未提供'}cm
体重：${user.weight ?? '未提供'}kg
${user.bmi != null ? 'BMI: ${user.bmi!.toStringAsFixed(1)} (${user.bmiRating})' : ''}
''';
  }

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

  static String _buildDefaultDiningStyleInfo(UserProfile user) {
    String diningStyle = user.defaultDiningStyle;

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

  static String _buildSpecialDietInfo(UserProfile user) {
    return SpecialDietLogic.getFullSpecialDietPrompt(
      isVegetarian: user.isVegetarian,
      hasHighBloodSugar: user.hasHighBloodSugar,
    );
  }

  static String _buildSnackInfo(UserProfile user) {
    return '''
=== 零食建议 ===
${PreferenceLogic.getSnackPromptDescription(user.snackFrequency)}
''';
  }

  static String _buildNutritionTargets(UserProfile user) {
    final targetCalories = _getTargetCalories(user.healthGoal);
    final targetProtein = _getTargetProtein(user.healthGoal);
    final targetCarbs = _getTargetCarbs(user.healthGoal);
    final targetFat = _getTargetFat(user.healthGoal);

    return '''
=== 营养目标 ===

⚠️ 重要提示：以下目标值仅供参考，请根据用户的实际身体状况（年龄、性别、身高、体重、BMI）进行智能调整。

参考目标（基于健康目标"${user.healthGoal}"）：
- 每日参考热量：约$targetCalories kcal
- 每日参考蛋白质：约$targetProtein g
- 每日参考碳水：约$targetCarbs g
- 每日参考脂肪：约$targetFat g

请根据用户的具体情况智能调整：
1. 如果用户BMI偏高且健康目标是"增肌"或"胡吃海塞"，请适当降低热量，并温和提醒
2. 如果用户BMI偏低且健康目标是"减脂"或"清汤寡欲"，请适当提高热量，并温和提醒
3. 如果用户身体状况与健康目标不匹配，请在推荐中给出合理建议

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
  "snack": { ... }
}

重要：
1. 不要包含 "recipe"、"cookingTime"、"difficulty" 字段
2. foodItems 中不需要 "amount" 和 "unit" 字段
3. 所有食材必须避开忌口清单
4. 符合今日指定的菜系风格
5. 营养成分根据用户实际情况智能调整
6. 预估成本合理
''';
  }

  static int _getTargetCalories(String healthGoal) {
    const targets = {
      '减脂': 1800,
      '增肌': 2500,
      '维持': 2000,
      '随意': 2000,
      '胡吃海塞': 3000,
      '清汤寡欲': 1500,
    };
    return targets[healthGoal] ?? 2000;
  }

  static int _getTargetProtein(String healthGoal) {
    const targets = {
      '减脂': 120,
      '增肌': 150,
      '维持': 100,
      '随意': 100,
      '胡吃海塞': 120,
      '清汤寡欲': 80,
    };
    return targets[healthGoal] ?? 100;
  }

  static int _getTargetCarbs(String healthGoal) {
    const targets = {
      '减脂': 180,
      '增肌': 300,
      '维持': 250,
      '随意': 250,
      '胡吃海塞': 400,
      '清汤寡欲': 150,
    };
    return targets[healthGoal] ?? 250;
  }

  static int _getTargetFat(String healthGoal) {
    const targets = {
      '减脂': 50,
      '增肌': 80,
      '维持': 70,
      '随意': 70,
      '胡吃海塞': 100,
      '清汤寡欲': 40,
    };
    return targets[healthGoal] ?? 70;
  }

  static List<String> buildWeeklyPlan(UserProfile user) {
    List<String> weeklyPrompts = [];

    for (int day = 1; day <= 7; day++) {
      String prompt = build(user: user, dayOfWeek: day);
      weeklyPrompts.add(prompt);
    }

    return weeklyPrompts;
  }

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