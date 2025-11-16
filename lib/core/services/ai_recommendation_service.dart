// lib/core/services/ai_recommendation_service.dart
// Dart类文件

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/models/user_model.dart';
import '../../data/models/recommended_meal_model.dart';
import '../../data/models/token_usage_model.dart';
import '../../data/models/nutrition_model.dart';
import '../../data/repositories/token_stats_repository.dart';

/// AI推荐服务
class AIRecommendationService {
  final String _apiKey;
  final TokenStatsRepository _tokenStatsRepository;
  static const String _API_URL = 'https://api.anthropic.com/v1/chat/completions';

  AIRecommendationService(this._apiKey, this._tokenStatsRepository);

  // ==================== 生成推荐（支持不同数量）====================

  /// 🚀 获取2套推荐（快速首批）
  Future<List<List<RecommendedMeal>>> getTwoRecommendationSets({
    required UserProfile? user,
  }) async {
    return _getRecommendationSets(
      user: user,
      setsCount: 2,
      purpose: 'daily_recommendation_first_batch',
    );
  }

  /// 🔄 获取3套推荐（后台补充）
  Future<List<List<RecommendedMeal>>> getThreeRecommendationSets({
    required UserProfile? user,
  }) async {
    return _getRecommendationSets(
      user: user,
      setsCount: 3,
      purpose: 'daily_recommendation_second_batch',
    );
  }

  /// 📦 获取5套推荐（一次性生成）
  Future<List<List<RecommendedMeal>>> getFiveRecommendationSets({
    required UserProfile? user,
  }) async {
    return _getRecommendationSets(
      user: user,
      setsCount: 5,
      purpose: 'daily_recommendation_five_sets',
    );
  }

  // ==================== 核心生成方法 ====================

  /// 通用推荐生成方法
  Future<List<List<RecommendedMeal>>> _getRecommendationSets({
    required UserProfile? user,
    required int setsCount,
    required String purpose,
  }) async {
    try {
      print('🤖 开始生成 $setsCount 套推荐...');

      // 构建Prompt
      final prompt = _buildPrompt(user, setsCount);

      // 调用OpenAI API
      final response = await _callOpenAI(prompt, 'gpt-3.5-turbo');

      // 解析响应
      final sets = _parseRecommendationSets(response, setsCount);

      // 计算Token使用
      final usage = TokenUsage.calculate(
        model: 'gpt-3.5-turbo',
        inputTokens: response['usage']['prompt_tokens'],
        outputTokens: response['usage']['completion_tokens'],
        purpose: purpose,
      );

      // 保存Token使用记录
      await _tokenStatsRepository.saveUsage(usage);

      print('✅ 成功生成 ${sets.length} 套推荐');
      print('💰 本次成本: ${usage.costDisplay}');

      return sets;
    } catch (e) {
      print('❌ 生成推荐失败: $e');
      rethrow;
    }
  }

  // ==================== Prompt构建 ====================

  /// 构建Prompt
  String _buildPrompt(UserProfile? user, int setsCount) {
    if (user == null || !_isProfileComplete(user)) {
      return _getGenericPrompt(setsCount);
    }
    return _getPersonalizedPrompt(user, setsCount);
  }

  /// 检查用户信息是否完整
  bool _isProfileComplete(UserProfile user) {
    return user.age != null &&
        user.healthGoal.isNotEmpty &&
        user.preferredCuisines.isNotEmpty;
  }

  /// 大众化Prompt
  String _getGenericPrompt(int setsCount) {
    return '''
请为一般人群推荐${setsCount}套不同的健康今日三餐方案（每套包含早餐、午餐、晚餐）。

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
      "set_name": "方案名称（如：清爽健康套餐）",
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
    },
    {
      "set_number": 2,
      ...
    }
    ${setsCount > 2 ? '... （共$setsCount套）' : ''}
  ]
}

请直接返回JSON，不要有其他文字。
''';
  }

  /// 个性化Prompt
  String _getPersonalizedPrompt(UserProfile user, int setsCount) {
    return '''
请为以下用户推荐${setsCount}套不同的今日三餐方案（每套包含早餐、午餐、晚餐）：

用户信息：
- 年龄：${user.age ?? "未知"}岁
- 性别：${user.gender ?? "未知"}
- 健康目标：${user.healthGoal}
- 菜系偏好：${user.preferredCuisines.join('、')}
- 就餐方式：${user.defaultDiningStyle}
${user.isVegetarian ? '- 素食者：是' : ''}
${user.hasHighBloodSugar ? '- 血糖管理：需要' : ''}
${user.getAllAvoidFoods().isNotEmpty ? '- 忌口：${user.getAllAvoidFoods().join('、')}' : ''}

热量目标：
${_getCalorieTarget(user.healthGoal)}

要求：
1. 每套方案要有明显不同的风格（如：方案1中式、方案2西式、方案3日式等）
2. 符合用户的健康目标和饮食偏好
3. 避开忌口食材
4. 营养均衡，富含有益情绪的营养素（镁、B族维生素、色氨酸、Omega-3）

请以JSON格式返回，格式如下：
{
  "recommendation_sets": [
    {
      "set_number": 1,
      "set_name": "方案名称（如：活力中式套餐）",
      "meals": [
        {
          "mealType": "早餐",
          "name": "餐食名称",
          "description": "简短描述，说明为什么适合用户",
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
          "cookingTips": "烹饪建议",
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
      ]
    },
    {
      "set_number": 2,
      ...
    }
    ${setsCount > 2 ? '... （共$setsCount套）' : ''}
  ]
}

请直接返回JSON，不要有其他文字。
''';
  }

  /// 获取热量目标文本
  String _getCalorieTarget(String healthGoal) {
    const targets = {
      '减脂': '总热量约1800 kcal（早餐450，午餐600，晚餐550，其余为零食）',
      '增肌': '总热量约2500 kcal（早餐650，午餐850，晚餐800，其余为零食）',
      '维持': '总热量约2000 kcal（早餐500，午餐650，晚餐600，其余为零食）',
      '随意': '总热量约2000 kcal（早餐500，午餐650，晚餐600，其余为零食）',
    };
    return targets[healthGoal] ?? targets['维持']!;
  }

  // ==================== API调用 ====================

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
              'content': '你是一位专业的营养师和健康顾问，擅长根据用户需求提供多样化的餐食推荐方案。',
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'temperature': 0.8, // 提高温度以获得更多样化的结果
          'max_tokens': 4000, // 足够容纳5套推荐
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('API调用失败: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('API调用错误: $e');
    }
  }

  // ==================== 响应解析 ====================

  /// 解析推荐结果
  List<List<RecommendedMeal>> _parseRecommendationSets(
    Map<String, dynamic> response,
    int expectedSetsCount,
  ) {
    try {
      final content = response['choices'][0]['message']['content'] as String;

      // 去除可能的markdown格式
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

      // 验证数量
      if (recommendationSets.length != expectedSetsCount) {
        print('⚠️ 警告：预期 $expectedSetsCount 套，实际返回 ${recommendationSets.length} 套');
      }

      // 解析每一套
      return recommendationSets.map<List<RecommendedMeal>>((setJson) {
        final int setNumber = setJson['set_number'];
        final String setName = setJson['set_name'] ?? '方案 $setNumber';
        final List<dynamic> meals = setJson['meals'];

        return meals.map<RecommendedMeal>((mealJson) {
          return RecommendedMeal(
            id: DateTime.now().millisecondsSinceEpoch.toString() +
                '_set${setNumber}_' +
                mealJson['mealType'],
            mealType: mealJson['mealType'],
            name: mealJson['name'],
            description: '$setName - ${mealJson['description'] ?? ''}',
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