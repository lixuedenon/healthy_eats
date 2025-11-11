// lib/data/models/meal_model.dart
// Dart类文件

import 'food_item_model.dart';
import 'nutrition_model.dart';

/// 餐食数据模型
class Meal {
  // ==================== 基本信息 ====================

  final String id;
  final String mealType; // 早餐/午餐/晚餐/加餐
  final String name; // 餐食名称
  final String? description; // 描述

  // ==================== 时间 ====================

  final DateTime dateTime;
  final String? recommendedTime; // 推荐时间（HH:mm）

  // ==================== 食物列表 ====================

  final List<FoodItem> foodItems;

  // ==================== 营养信息 ====================

  final Nutrition nutrition; // 总营养成分

  // ==================== 情绪ROI ====================

  final int? emotionROI; // 情绪ROI分数（0-100）
  final String? emotionBenefit; // 情绪益处描述
  final Map<String, int>? emotionSubScores; // 子项得分

  // ==================== 餐食来源 ====================

  final String source; // 餐馆/外卖/自己做
  final String? restaurantName; // 餐馆名称
  final String? restaurantAddress; // 餐馆地址

  // ==================== 菜谱信息（仅VIP） ====================

  final List<String>? recipe; // 制作步骤
  final int? cookingTime; // 烹饪时间（分钟）
  final String? difficulty; // 难度：简单/中等/困难

  // ==================== 价格 ====================

  final double? totalCost; // 总成本

  // ==================== 菜系 ====================

  final String? cuisine; // 中餐/法餐/日料等

  // ==================== 图片 ====================

  final String? imageUrl;

  // ==================== 其他 ====================

  final bool isCompleted; // 是否已完成
  final DateTime? completedAt; // 完成时间

  // ==================== 构造函数 ====================

  Meal({
    required this.id,
    required this.mealType,
    required this.name,
    this.description,
    required this.dateTime,
    this.recommendedTime,
    required this.foodItems,
    required this.nutrition,
    this.emotionROI,
    this.emotionBenefit,
    this.emotionSubScores,
    required this.source,
    this.restaurantName,
    this.restaurantAddress,
    this.recipe,
    this.cookingTime,
    this.difficulty,
    this.totalCost,
    this.cuisine,
    this.imageUrl,
    this.isCompleted = false,
    this.completedAt,
  });

  // ==================== JSON序列化 ====================

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'] as String,
      mealType: json['mealType'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      dateTime: DateTime.parse(json['dateTime'] as String),
      recommendedTime: json['recommendedTime'] as String?,
      foodItems: (json['foodItems'] as List<dynamic>)
          .map((e) => FoodItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      nutrition: Nutrition.fromJson(json['nutrition'] as Map<String, dynamic>),
      emotionROI: json['emotionROI'] as int?,
      emotionBenefit: json['emotionBenefit'] as String?,
      emotionSubScores: json['emotionSubScores'] != null
          ? Map<String, int>.from(json['emotionSubScores'] as Map)
          : null,
      source: json['source'] as String,
      restaurantName: json['restaurantName'] as String?,
      restaurantAddress: json['restaurantAddress'] as String?,
      recipe: json['recipe'] != null
          ? (json['recipe'] as List<dynamic>).map((e) => e as String).toList()
          : null,
      cookingTime: json['cookingTime'] as int?,
      difficulty: json['difficulty'] as String?,
      totalCost: json['totalCost'] != null ? (json['totalCost'] as num).toDouble() : null,
      cuisine: json['cuisine'] as String?,
      imageUrl: json['imageUrl'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mealType': mealType,
      'name': name,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'recommendedTime': recommendedTime,
      'foodItems': foodItems.map((e) => e.toJson()).toList(),
      'nutrition': nutrition.toJson(),
      'emotionROI': emotionROI,
      'emotionBenefit': emotionBenefit,
      'emotionSubScores': emotionSubScores,
      'source': source,
      'restaurantName': restaurantName,
      'restaurantAddress': restaurantAddress,
      'recipe': recipe,
      'cookingTime': cookingTime,
      'difficulty': difficulty,
      'totalCost': totalCost,
      'cuisine': cuisine,
      'imageUrl': imageUrl,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  // ==================== 工具方法 ====================

  /// 获取餐食时间显示（emoji + 名称 + 时间）
  String get timeDisplay {
    String emoji = getMealEmoji();
    String time = recommendedTime ?? '';
    return '$emoji $mealType${time.isNotEmpty ? " · $time" : ""}';
  }

  /// 获取餐食对应的emoji
  String getMealEmoji() {
    switch (mealType) {
      case '早餐':
        return '🌅';
      case '午餐':
        return '☀️';
      case '晚餐':
        return '🌙';
      case '加餐':
        return '🍰';
      default:
        return '🍽️';
    }
  }

  /// 获取来源图标
  String getSourceIcon() {
    if (source.contains('自己做')) {
      return '🏠';
    } else if (source.contains('餐馆')) {
      return '🏪';
    } else if (source.contains('外卖')) {
      return '🚗';
    }
    return '🍴';
  }

  /// 获取来源显示文本
  String getSourceDisplay() {
    String icon = getSourceIcon();
    if (source.contains('自己做') && cookingTime != null) {
      return '$icon 自己做 · ${cookingTime}分钟';
    } else if (restaurantName != null) {
      return '$icon 推荐餐馆: $restaurantName';
    }
    return '$icon $source';
  }

  /// 获取情绪ROI显示文本
  String? getEmotionROIDisplay() {
    if (emotionROI == null) return null;
    return '情绪ROI: $emotionROI/100 · ${emotionBenefit ?? ""}';
  }

  /// 获取微量营养素显示文本
  String getMicronutrientsDisplay() {
    final micros = nutrition.getMicronutrients();
    if (micros.isEmpty) return '';

    List<String> items = [];
    micros.forEach((key, value) {
      items.add('$key ↑');
    });

    return items.join(' | ');
  }

  /// 复制并修改部分字段
  Meal copyWith({
    String? id,
    String? mealType,
    String? name,
    String? description,
    DateTime? dateTime,
    String? recommendedTime,
    List<FoodItem>? foodItems,
    Nutrition? nutrition,
    int? emotionROI,
    String? emotionBenefit,
    Map<String, int>? emotionSubScores,
    String? source,
    String? restaurantName,
    String? restaurantAddress,
    List<String>? recipe,
    int? cookingTime,
    String? difficulty,
    double? totalCost,
    String? cuisine,
    String? imageUrl,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return Meal(
      id: id ?? this.id,
      mealType: mealType ?? this.mealType,
      name: name ?? this.name,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      recommendedTime: recommendedTime ?? this.recommendedTime,
      foodItems: foodItems ?? this.foodItems,
      nutrition: nutrition ?? this.nutrition,
      emotionROI: emotionROI ?? this.emotionROI,
      emotionBenefit: emotionBenefit ?? this.emotionBenefit,
      emotionSubScores: emotionSubScores ?? this.emotionSubScores,
      source: source ?? this.source,
      restaurantName: restaurantName ?? this.restaurantName,
      restaurantAddress: restaurantAddress ?? this.restaurantAddress,
      recipe: recipe ?? this.recipe,
      cookingTime: cookingTime ?? this.cookingTime,
      difficulty: difficulty ?? this.difficulty,
      totalCost: totalCost ?? this.totalCost,
      cuisine: cuisine ?? this.cuisine,
      imageUrl: imageUrl ?? this.imageUrl,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}