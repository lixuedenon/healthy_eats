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
  static const String _API_URL = 'https://api.openai.com/v1/chat/completions';

  AIRecommendationService(this._apiKey, this._tokenStatsRepository);

  // ==================== 双模型推荐 ====================

  /// 获取双模型推荐
  Future<DualRecommendation> getDualRecommendations({
    required UserProfile? user,
  }) async {
    // 并发调用两个模型
    final results = await Future.wait([
      _getRecommendation(user, 'gpt-4'),
      _getRecommendation(user, 'gpt-3.5-turbo'),
    ]);

    return DualRecommendation(
      gpt4Results: results[0].recommendations,
      gpt35Results: results[1].recommendations,
      gpt4Usage: results[0].usage,
      gpt35Usage: results[1].usage,
      timestamp: DateTime.now(),
    );
  }

  // ==================== 单模型推荐 ====================

  /// 获取单个模型的推荐
  Future<_RecommendationResult> _getRecommendation(
    UserProfile? user,
    String model,
  ) async {
    // 构建Prompt
    final prompt = _buildPrompt(user);

    // 调用OpenAI API
    final response = await _callOpenAI(prompt, model);

    // 解析响应
    final recommendations = _parseRecommendations(response, model);

    // 计算Token使用
    final usage = TokenUsage.calculate(
      model: model,
      inputTokens: response['usage']['prompt_tokens'],
      outputTokens: response['usage']['completion_tokens'],
      purpose: 'daily_recommendation',
    );

    // 保存Token使用记录
    await _tokenStatsRepository.saveUsage(usage);

    return _RecommendationResult(
      recommendations: recommendations,
      usage: usage,
    );
  }

  // ==================== Prompt构建 ====================

  /// 构建Prompt
  String _buildPrompt(UserProfile? user) {
    if (user == null || !_isProfileComplete(user)) {
      return _getGenericPrompt();
    }
    return _getPersonalizedPrompt(user);
  }

  /// 检查用户信息是否完整
  bool _isProfileComplete(UserProfile user) {
    return user.age != null &&
        user.healthGoal.isNotEmpty &&
        user.preferredCuisines.isNotEmpty;
  }

  /// 大众化Prompt
  String _getGenericPrompt() {
    return '''
请为一般人群推荐健康的今日三餐（早餐、午餐、晚餐）。

要求：
1. 营养均衡，适合大多数人
2. 食材常见，容易获取
3. 制作简单，不超过30分钟

请以JSON格式返回，格式如下：
{
  "recommendations": [
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
    }
  ]
}

请直接返回JSON，不要有其他文字。
''';
  }

  /// 个性化Prompt
  String _getPersonalizedPrompt(UserProfile user) {
    return '''
请为以下用户推荐今日三餐（早餐、午餐、晚餐）：

用户信息：
- 年龄：${user.age ?? "未知"}岁
- 性别：${user.gender ?? "未知"}
- 健康目标：${user.healthGoal}
- 菜系偏好：${user.preferredCuisines.join('、')}
- 就餐方式：${user.defaultDiningStyle}
- 零食偏好：${user.snackFrequency}
${user.isVegetarian ? '- 素食者：是' : ''}
${user.hasHighBloodSugar ? '- 血糖管理：需要' : ''}
${user.getAllAvoidFoods().isNotEmpty ? '- 忌口：${user.getAllAvoidFoods().join('、')}' : ''}

热量目标：
${_getCalorieTarget(user.healthGoal)}

要求：
1. 符合用户的健康目标和饮食偏好
2. 避开忌口食材
3. 营养均衡，富含有益情绪的营养素（镁、B族维生素、色氨酸、Omega-3）

请以JSON格式返回，格式如下：
{
  "recommendations": [
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
    }
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
              'content': '你是一位专业的营养师和健康顾问，擅长根据用户需求提供个性化的餐食推荐。',
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'temperature': 0.7,
          'max_tokens': 2000,
        }),
      );

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
  List<RecommendedMeal> _parseRecommendations(
    Map<String, dynamic> response,
    String model,
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
      final List<dynamic> recommendations = data['recommendations'];

      return recommendations.map((json) {
        return RecommendedMeal(
          id: DateTime.now().millisecondsSinceEpoch.toString() +
              '_' +
              json['mealType'],
          mealType: json['mealType'],
          name: json['name'],
          description: json['description'] ?? '',
          ingredients: (json['ingredients'] as List<dynamic>)
              .map((e) => e.toString())
              .toList(),
          nutrition: Nutrition.fromJson(json['nutrition']),
          estimatedROI: json['estimatedROI'],
          cookingTips: json['cookingTips'],
          cookingTime: json['cookingTime'],
          sourceModel: model,
        );
      }).toList();
    } catch (e) {
      throw Exception('解析AI响应失败: $e');
    }
  }
}

/// 推荐结果（内部使用）
class _RecommendationResult {
  final List<RecommendedMeal> recommendations;
  final TokenUsage usage;

  _RecommendationResult({
    required this.recommendations,
    required this.usage,
  });
}