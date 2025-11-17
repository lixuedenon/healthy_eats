// lib/domain/ai_engine/prompt_builder/daily_prompt_builder.dart
// Dart类文件

import '../../../data/models/user_model.dart';
import '../logic/meal_source_logic.dart';
import '../logic/dining_style_logic.dart';
import '../logic/preference_logic.dart';
import '../logic/avoidance_logic.dart';
import '../logic/special_diet_logic.dart';

class DailyPromptBuilder {
  static String build({
    required UserProfile user,
    required int dailyMealSource,
    required String dailyDiningStyle,
    String? specificCuisine,
  }) {
    StringBuffer prompt = StringBuffer();

    prompt.writeln(_buildSystemRole());
    prompt.writeln();

    prompt.writeln(_buildUserInfo(user));
    prompt.writeln();

    prompt.writeln(_buildMealSourceInfo(dailyMealSource, user.isVIPValid));
    prompt.writeln();

    prompt.writeln(_buildDiningStyleInfo(dailyDiningStyle));
    prompt.writeln();

    prompt.writeln(_buildCuisineInfo(user, specificCuisine));
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

    prompt.writeln(_buildOutputFormat(user.isVIPValid));

    return prompt.toString();
  }

  static String _buildSystemRole() {
    return '''
你是一位专业的营养师和健康饮食顾问，擅长根据用户的需求推荐个性化的餐食方案。
你的任务是为用户推荐今天的三餐（早餐、午餐、晚餐），确保营养均衡、符合用户偏好，并关注食物的情绪调节功能。
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

  static String _buildMealSourceInfo(int mealSource, bool isVIP) {
    return '''
=== 今日餐食来源 ===
级别：$mealSource (${MealSourceLogic.getRecommendationType(mealSource)})

${MealSourceLogic.getAIPromptDescription(mealSource)}

${isVIP ? '''
用户是VIP，请提供完整的菜谱：
- 详细食材清单（包括具体份量）
- 完整制作步骤（编号列出，清晰易懂）
- 预计烹饪时间
- 难度等级
''' : '''
用户是免费版，请仅提供：
- 菜品名称
- 食材清单（不需要详细份量）
- 营养成分估算
请不要提供具体的制作步骤和烹饪时间。
'''}
''';
  }

  static String _buildDiningStyleInfo(String diningStyle) {
    return '''
=== 今日就餐形式 ===
${DiningStyleLogic.getFullPromptForDiningStyle(diningStyle)}
''';
  }

  static String _buildCuisineInfo(UserProfile user, String? specificCuisine) {
    String todayCuisine = specificCuisine ??
                         (user.preferredCuisines.isNotEmpty
                           ? user.preferredCuisines.first
                           : '中餐');

    return '''
=== 菜系偏好 ===
${PreferenceLogic.getFullCuisinePrompt(user.preferredCuisines, todayCuisine)}
''';
  }

  static String _buildAvoidanceInfo(UserProfile user) {
    return '''
=== 忌口清单 ===
${AvoidanceLogic.getFullAvoidancePrompt(
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

三餐营养分配建议：
- 早餐：25-30%的日总热量
- 午餐：35-40%的日总热量
- 晚餐：30-35%的日总热量

特别关注情绪调节营养素：
- 镁（抗焦虑、助眠）：每餐约100-150mg
- B族维生素（提升情绪）：充足摄入
- 色氨酸（改善情绪和睡眠）：每餐约80-100mg
- Omega-3（抗炎、保护大脑）：每餐约0.5g
''';
  }

  static String _buildOutputFormat(bool isVIP) {
    return '''
=== 输出格式要求 ===

请以JSON格式输出，包含以下结构：

{
  "breakfast": {
    "name": "餐食名称",
    "description": "简短描述",
    "foodItems": [
      {
        "name": "食材名称",
        "amount": 数量,
        "unit": "单位"
      }
    ],
    "nutrition": {
      "calories": 热量(kcal),
      "protein": 蛋白质(g),
      "carbs": 碳水(g),
      "fat": 脂肪(g),
      "magnesium": 镁(mg),
      "vitaminB6": B6(mg),
      "vitaminB12": B12(μg),
      "tryptophan": 色氨酸(mg),
      "omega3": Omega-3(g),
      "iron": 铁(mg),
      "fiber": 膳食纤维(g)
    },
    "source": "餐馆/外卖/自己做",
    "restaurantName": "餐馆名称（如果是餐馆）",
    ${isVIP ? '''
    "recipe": ["步骤1", "步骤2", "步骤3"],
    "cookingTime": 烹饪时间(分钟),
    "difficulty": "简单/中等/困难",
    ''' : ''}
    "totalCost": 预估成本(元)
  },
  "lunch": { ... },
  "dinner": { ... },
  "snack": { ... }
}

请确保：
1. 所有推荐的食材都不在忌口列表中
2. 符合用户的菜系偏好和今日指定菜系
3. 营养成分根据用户实际情况智能调整
4. 情绪调节营养素含量充足
5. ${isVIP ? '提供详细的菜谱步骤' : '不提供菜谱步骤'}
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
}