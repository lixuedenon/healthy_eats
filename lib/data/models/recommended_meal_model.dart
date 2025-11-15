// lib/data/models/recommended_meal_model.dart
// Dart类文件

import 'nutrition_model.dart';

/// 推荐餐食模型
class RecommendedMeal {
  // ==================== 基本信息 ====================

  final String id;
  final String mealType; // 早餐/午餐/晚餐
  final String name; // 餐食名称
  final String description; // 描述

  // ==================== 食材列表 ====================

  final List<String> ingredients; // 食材和份量

  // ==================== 营养信息 ====================

  final Nutrition nutrition; // 营养成分

  // ==================== AI评估 ====================

  final int estimatedROI; // 预估情绪ROI（0-100）
  final String? cookingTips; // 烹饪建议
  final int? cookingTime; // 预估烹饪时间（分钟）

  // ==================== 状态 ====================

  final bool isAdopted; // 是否已采用
  final String sourceModel; // 来源模型：gpt-4 / gpt-3.5-turbo

  // ==================== 构造函数 ====================

  RecommendedMeal({
    required this.id,
    required this.mealType,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.nutrition,
    required this.estimatedROI,
    this.cookingTips,
    this.cookingTime,
    this.isAdopted = false,
    required this.sourceModel,
  });

  // ==================== JSON序列化 ====================

  factory RecommendedMeal.fromJson(Map<String, dynamic> json) {
    return RecommendedMeal(
      id: json['id'] as String,
      mealType: json['mealType'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      nutrition: Nutrition.fromJson(json['nutrition'] as Map<String, dynamic>),
      estimatedROI: json['estimatedROI'] as int,
      cookingTips: json['cookingTips'] as String?,
      cookingTime: json['cookingTime'] as int?,
      isAdopted: json['isAdopted'] as bool? ?? false,
      sourceModel: json['sourceModel'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mealType': mealType,
      'name': name,
      'description': description,
      'ingredients': ingredients,
      'nutrition': nutrition.toJson(),
      'estimatedROI': estimatedROI,
      'cookingTips': cookingTips,
      'cookingTime': cookingTime,
      'isAdopted': isAdopted,
      'sourceModel': sourceModel,
    };
  }

  // ==================== 工具方法 ====================

  /// 复制并修改
  RecommendedMeal copyWith({
    String? id,
    String? mealType,
    String? name,
    String? description,
    List<String>? ingredients,
    Nutrition? nutrition,
    int? estimatedROI,
    String? cookingTips,
    int? cookingTime,
    bool? isAdopted,
    String? sourceModel,
  }) {
    return RecommendedMeal(
      id: id ?? this.id,
      mealType: mealType ?? this.mealType,
      name: name ?? this.name,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      nutrition: nutrition ?? this.nutrition,
      estimatedROI: estimatedROI ?? this.estimatedROI,
      cookingTips: cookingTips ?? this.cookingTips,
      cookingTime: cookingTime ?? this.cookingTime,
      isAdopted: isAdopted ?? this.isAdopted,
      sourceModel: sourceModel ?? this.sourceModel,
    );
  }

  /// 获取餐次emoji
  String get mealEmoji {
    switch (mealType) {
      case '早餐':
        return '🌅';
      case '午餐':
        return '☀️';
      case '晚餐':
        return '🌙';
      default:
        return '🍽️';
    }
  }

  /// 获取ROI评级
  String get roiRating {
    if (estimatedROI >= 85) return '优秀';
    if (estimatedROI >= 70) return '良好';
    if (estimatedROI >= 60) return '一般';
    return '较差';
  }

  /// 获取食材显示文本
  String get ingredientsDisplay {
    return ingredients.join('、');
  }
}

/// 双模型推荐结果
class DualRecommendation {
  final List<RecommendedMeal> gpt4Results; // GPT-4推荐
  final List<RecommendedMeal> gpt35Results; // GPT-3.5推荐
  final TokenUsage gpt4Usage; // GPT-4用量
  final TokenUsage gpt35Usage; // GPT-3.5用量
  final DateTime timestamp;

  DualRecommendation({
    required this.gpt4Results,
    required this.gpt35Results,
    required this.gpt4Usage,
    required this.gpt35Usage,
    required this.timestamp,
  });

  /// 获取指定模型的推荐
  List<RecommendedMeal> getResults(String model) {
    return model.contains('gpt-4') ? gpt4Results : gpt35Results;
  }

  /// 获取指定模型的用量
  TokenUsage getUsage(String model) {
    return model.contains('gpt-4') ? gpt4Usage : gpt35Usage;
  }
}