// lib/core/services/ai_recommendation_service.dart
// Dart类文件

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/models/user_model.dart';
import '../../data/models/recommended_meal_model.dart';
import '../../data/models/token_usage_model.dart';
import '../../data/models/nutrition_model.dart';
import '../../data/repositories/token_stats_repository.dart';

class AIRecommendationService {
  final String _apiKey;
  final TokenStatsRepository _tokenStatsRepository;
  static const String _API_URL = 'https://api.openai.com/v1/chat/completions';

  AIRecommendationService(this._apiKey, this._tokenStatsRepository);

  /// 生成2套推荐（首批）
  Future<List<List<RecommendedMeal>>> getTwoRecommendationSets({
    required UserProfile? user,
  }) async {
    return _getRecommendationSets(
      user: user,
      setsCount: 2,
      purpose: 'daily_recommendation_first_batch',
    );
  }

  /// 生成3套推荐（第二批）
  Future<List<List<RecommendedMeal>>> getThreeRecommendationSets({
    required UserProfile? user,
  }) async {
    return _getRecommendationSets(
      user: user,
      setsCount: 3,
      purpose: 'daily_recommendation_second_batch',
    );
  }

  /// 生成5套推荐（一次性）
  Future<List<List<RecommendedMeal>>> getFiveRecommendationSets({
    required UserProfile? user,
  }) async {
    return _getRecommendationSets(
      user: user,
      setsCount: 5,
      purpose: 'daily_recommendation_five_sets',
    );
  }

  /// 内部方法：生成推荐
  Future<List<List<RecommendedMeal>>> _getRecommendationSets({
    required UserProfile? user,
    required int setsCount,
    required String purpose,
  }) async {
    try {
      print('🤖 开始生成 $setsCount 套推荐...');

      final prompt = _buildPrompt(user, setsCount);

      final response = await _callOpenAI(prompt, 'gpt-3.5-turbo');

      final sets = _parseRecommendationSets(response, setsCount);

      final usage = TokenUsage.calculate(
        model: 'gpt-3.5-turbo',
        inputTokens: response['usage']['prompt_tokens'],
        outputTokens: response['usage']['completion_tokens'],
        purpose: purpose,
      );

      await _tokenStatsRepository.saveUsage(usage);

      print('✅ 成功生成 ${sets.length} 套推荐');
      print('💰 本次成本: ${usage.costDisplay}');

      return sets;
    } catch (e) {
      print('❌ 生成推荐失败: $e');
      rethrow;
    }
  }

  /// 构建Prompt
  String _buildPrompt(UserProfile? user, int setsCount) {
    if (user == null || !_isProfileComplete(user)) {
      return _getGenericPrompt(setsCount);
    }

    if (user.isHealthyEatingMode) {
      return _getHealthyPrompt(user, setsCount);
    } else {
      return _getTastyPrompt(user, setsCount);
    }
  }

  /// 判断用户信息是否完整
  bool _isProfileComplete(UserProfile user) {
    return user.age != null &&
        user.preferredCuisines.isNotEmpty;
  }

  /// 通用Prompt（用户信息不完整时）
  String _getGenericPrompt(int setsCount) {
    return '''
请为一般人群推荐${setsCount}套不同的今日三餐方案（每套包含早餐、午餐、晚餐）。

要求：
1. 每套方案要有明显不同的风格和食材
2. 营养均衡，适合大多数人
3. 食材常见，容易获取
4. 制作简单，不超过30分钟

请以JSON格式返回，格式如下：
{
  "recommendation_sets": [
    {
      "set_number": 1,
      "meals": [
        {
          "mealType": "早餐",
          "name": "餐食名称",
          "description": "简短描述",
          "ingredients": ["食材1 50g", "食材2 100ml"],
          "nutrition": {
            "calories": 500,
            "protein": 20,
            "carbs": 60,
            "fat": 15,
            "magnesium": 100,
            "vitaminB6": 0.5,
            "omega3": 0.2
          },
          "estimatedROI": 80,
          "cookingTips": "烹饪建议",
          "cookingTime": 15
        },
        {
          "mealType": "午餐",
          ...
        },
        {
          "mealType": "晚餐",
          ...
        }
      ]
    }
    ${setsCount > 1 ? ',\n    { "set_number": 2, ... }' : ''}
  ]
}

请直接返回JSON，不要有其他文字。
''';
  }

  /// 美味优先Prompt（不勾选健康饮食）
  String _getTastyPrompt(UserProfile user, int setsCount) {
    final mealSourceText = _getMealSourceText(user.defaultMealSource);
    final avoidFoods = user.getAllAvoidFoods();
    final snackText = _getSnackRecommendationText(user.snackFrequency);

    return '''
请为以下用户推荐${setsCount}套不同的今日餐食方案：

【用户信息】
- 年龄：${user.age ?? '未知'}岁，性别：${user.gender ?? '未知'}
${user.city != null && user.city!.isNotEmpty ? '- 城市：${user.city}' : ''}
- 餐食来源：$mealSourceText
- 菜系偏好：${user.preferredCuisines.join('、')}
- 就餐方式：${user.defaultDiningStyle}
${avoidFoods.isNotEmpty ? '- 忌口：${avoidFoods.join('、')}' : ''}
${user.isVegetarian ? '- 素食者' : ''}

【推荐要求】
✅ 优先考虑美味和满足感
✅ 推荐真实餐馆菜品（如果是外食），价格符合当地消费水平
✅ 菜品要接地气、好吃（如：Tacos, Burgers, 麻辣烫, 鱼香肉丝, Sushi, Ramen）
✅ 不必考虑健康和营养比例
${avoidFoods.isNotEmpty ? '✅ 严格避开忌口食材' : ''}

【零食推荐】
$snackText

请以JSON格式返回${setsCount}套方案，每套包含早餐、午餐、晚餐${snackText.contains('推荐零食') ? '、零食' : ''}：
{
  "recommendation_sets": [
    {
      "set_number": 1,
      "meals": [
        {
          "mealType": "早餐",
          "name": "餐食名称",
          "description": "简短描述",
          "ingredients": ["食材1 50g", "食材2 100ml"],
          "nutrition": {
            "calories": 500,
            "protein": 20,
            "carbs": 60,
            "fat": 15,
            "magnesium": 100,
            "vitaminB6": 0.5,
            "vitaminB12": 1.0,
            "tryptophan": 50,
            "omega3": 0.2
          },
          "estimatedROI": 85,
          "cookingTips": "烹饪建议或餐厅建议",
          "cookingTime": 20
        },
        {
          "mealType": "午餐",
          ...
        },
        {
          "mealType": "晚餐",
          ...
        }
        ${snackText.contains('推荐零食') ? ''',
        {
          "mealType": "零食",
          ...
        }''' : ''}
      ]
    }
    ${setsCount > 1 ? ',\n    { "set_number": 2, ... }' : ''}
  ]
}

请直接返回JSON，不要有其他文字。
''';
  }

  /// 健康饮食Prompt（勾选健康饮食）
  String _getHealthyPrompt(UserProfile user, int setsCount) {
    final bmiInfo = _getBMIInfo(user);
    final healthConditionsText = _getHealthConditionsText(user);
    final mealSourceText = _getMealSourceText(user.defaultMealSource);
    final avoidFoods = user.getAllAvoidFoods();
    final snackText = _getHealthySnackRecommendationText(user.healthGoal, user.snackFrequency);

    return '''
请为以下用户推荐${setsCount}套不同的今日餐食方案：

【用户信息】
- 年龄：${user.age ?? '未知'}岁，性别：${user.gender ?? '未知'}
${bmiInfo.isNotEmpty ? '- 身高：${user.height}cm，体重：${user.weight}kg，BMI：${user.bmi?.toStringAsFixed(1)} ($bmiInfo)' : ''}
${user.city != null && user.city!.isNotEmpty ? '- 城市：${user.city}' : ''}
- 健康目标：${user.healthGoal}
${healthConditionsText.isNotEmpty ? '- 健康状况：$healthConditionsText' : ''}
- 餐食来源：$mealSourceText
- 菜系偏好：${user.preferredCuisines.join('、')}
- 就餐方式：${user.defaultDiningStyle}
${avoidFoods.isNotEmpty ? '- 忌口：${avoidFoods.join('、')}' : ''}
${user.isVegetarian ? '- 素食者' : ''}

【推荐要求】
✅ 兼顾健康与美味
✅ 根据BMI和健康目标调整热量和营养比例
${healthConditionsText.isNotEmpty ? '✅ 考虑健康状况，避开相应的禁忌食物' : ''}
✅ 推荐真实餐馆菜品或简单家常菜，价格符合当地消费水平
${avoidFoods.isNotEmpty ? '✅ 严格避开忌口食材' : ''}

【零食推荐】
$snackText

请以JSON格式返回${setsCount}套方案，每套包含早餐、午餐、晚餐${snackText.contains('推荐零食') ? '、零食' : ''}：
{
  "recommendation_sets": [
    {
      "set_number": 1,
      "meals": [
        {
          "mealType": "早餐",
          "name": "餐食名称",
          "description": "简短描述",
          "ingredients": ["食材1 50g", "食材2 100ml"],
          "nutrition": {
            "calories": 500,
            "protein": 20,
            "carbs": 60,
            "fat": 15,
            "magnesium": 100,
            "vitaminB6": 0.5,
            "vitaminB12": 1.0,
            "tryptophan": 50,
            "omega3": 0.2
          },
          "estimatedROI": 85,
          "cookingTips": "烹饪建议或餐厅建议",
          "cookingTime": 20
        },
        {
          "mealType": "午餐",
          ...
        },
        {
          "mealType": "晚餐",
          ...
        }
        ${snackText.contains('推荐零食') ? ''',
        {
          "mealType": "零食",
          ...
        }''' : ''}
      ]
    }
    ${setsCount > 1 ? ',\n    { "set_number": 2, ... }' : ''}
  ]
}

请直接返回JSON，不要有其他文字。
''';
  }

  /// 获取BMI信息文本
  String _getBMIInfo(UserProfile user) {
    final bmi = user.bmi;
    if (bmi == null) return '';

    if (bmi < 18.5) return '偏瘦';
    if (bmi < 24) return '正常';
    if (bmi < 28) return '偏胖';
    return '肥胖';
  }

  /// 获取健康状况文本
  String _getHealthConditionsText(UserProfile user) {
    if (!user.hasAnyHealthCondition) return '';

    final conditions = user.healthConditions.where((c) => c != '无').toList();
    return conditions.join('、');
  }

  /// 获取餐食来源文本
  String _getMealSourceText(int level) {
    const texts = {
      1: '基本外食（几乎所有餐食都在餐馆吃）',
      2: '较多外食',
      3: '外食与自制各半',
      4: '较多自己做',
      5: '基本自己做',
    };
    return texts[level] ?? '未设置';
  }

  /// 获取零食推荐文本（美味优先模式）
  String _getSnackRecommendationText(String snackFrequency) {
    switch (snackFrequency) {
      case '不吃零食':
      case '很少吃':
        return '用户零食偏好：${snackFrequency}，不推荐零食';
      case '偶尔吃':
      case '经常吃':
      case '每天都吃':
        return '用户零食偏好：${snackFrequency}，推荐零食（各类美味零食均可）';
      default:
        return '不推荐零食';
    }
  }

  /// 获取零食推荐文本（健康饮食模式）
  String _getHealthySnackRecommendationText(String healthGoal, String snackFrequency) {
    final noSnackGoals = ['减脂', '清汤寡欲'];
    final shouldRecommendByGoal = !noSnackGoals.contains(healthGoal);
    final shouldRecommendByFrequency = !['不吃零食', '很少吃'].contains(snackFrequency);

    if (shouldRecommendByGoal && shouldRecommendByFrequency) {
      if (healthGoal == '胡吃海塞') {
        return '用户零食偏好：${snackFrequency}，推荐零食（各类美味零食均可）';
      } else if (healthGoal == '增肌') {
        return '用户零食偏好：${snackFrequency}，推荐零食（高蛋白零食，如蛋白棒、坚果、酸奶）';
      } else {
        return '用户零食偏好：${snackFrequency}，推荐零食（健康零食，如坚果、水果、酸奶）';
      }
    }

    return '不推荐零食';
  }

  /// 调用OpenAI API
  Future<Map<String, dynamic>> _callOpenAI(String prompt, String model) async {
    try {
      final response = await http.post(
        Uri.parse(_API_URL),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': model,
          'messages': [
            {
              'role': 'system',
              'content': '你是一位专业的营养师和美食顾问，擅长根据用户的偏好提供个性化的餐食推荐方案。',
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'temperature': 0.8,
          'max_tokens': 4000,
        }),
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('API调用失败: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('API调用错误: $e');
    }
  }

  /// 解析AI响应
  List<List<RecommendedMeal>> _parseRecommendationSets(
    Map<String, dynamic> response,
    int expectedSetsCount,
  ) {
    try {
      final content = response['choices'][0]['message']['content'] as String;

      String jsonContent = content.trim();
      if (jsonContent.startsWith('```json')) {
        jsonContent = jsonContent.substring(7);
      }
      if (jsonContent.startsWith('```')) {
        jsonContent = jsonContent.substring(3);
      }
      if (jsonContent.endsWith('```')) {
        jsonContent = jsonContent.substring(0, jsonContent.length - 3);
      }
      jsonContent = jsonContent.trim();

      final data = jsonDecode(jsonContent);
      final List<dynamic> recommendationSets = data['recommendation_sets'];

      if (recommendationSets.length != expectedSetsCount) {
        print('⚠️ 警告：预期 $expectedSetsCount 套，实际返回 ${recommendationSets.length} 套');
      }

      return recommendationSets.map<List<RecommendedMeal>>((setJson) {
        final int setNumber = setJson['set_number'];
        final List<dynamic> meals = setJson['meals'];

        return meals.map<RecommendedMeal>((mealJson) {
          return RecommendedMeal(
            id: DateTime.now().millisecondsSinceEpoch.toString() +
                '_set${setNumber}_' +
                mealJson['mealType'],
            mealType: mealJson['mealType'],
            name: mealJson['name'],
            description: mealJson['description'] ?? '',
            ingredients: (mealJson['ingredients'] as List<dynamic>)
                .map((e) => e.toString())
                .toList(),
            nutrition: Nutrition.fromJson(mealJson['nutrition']),
            estimatedROI: mealJson['estimatedROI'],
            cookingTips: mealJson['cookingTips'],
            cookingTime: mealJson['cookingTime'],
            sourceModel: 'gpt-3.5-turbo',
          );
        }).toList();
      }).toList();
    } catch (e) {
      throw Exception('解析AI响应失败: $e');
    }
  }
}