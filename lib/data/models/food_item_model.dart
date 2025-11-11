// lib/data/models/food_item_model.dart
// Dart类文件

import 'nutrition_model.dart';

/// 食物项数据模型（单个食材或菜品）
class FoodItem {
  // ==================== 基本信息 ====================

  final String id;
  final String name; // 食物名称
  final String? description; // 描述
  final double amount; // 份量
  final String unit; // 单位（g/ml/个/份等）

  // ==================== 营养信息 ====================

  final Nutrition nutrition;

  // ==================== 价格信息 ====================

  final double? price; // 价格（元）

  // ==================== 分类 ====================

  final String? category; // 蔬菜/水果/肉类/海鲜/主食/其他
  final String? cuisine; // 所属菜系

  // ==================== 图片 ====================

  final String? imageUrl;

  // ==================== 构造函数 ====================

  FoodItem({
    required this.id,
    required this.name,
    this.description,
    required this.amount,
    required this.unit,
    required this.nutrition,
    this.price,
    this.category,
    this.cuisine,
    this.imageUrl,
  });

  // ==================== JSON序列化 ====================

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      amount: (json['amount'] as num).toDouble(),
      unit: json['unit'] as String,
      nutrition: Nutrition.fromJson(json['nutrition'] as Map<String, dynamic>),
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      category: json['category'] as String?,
      cuisine: json['cuisine'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'amount': amount,
      'unit': unit,
      'nutrition': nutrition.toJson(),
      'price': price,
      'category': category,
      'cuisine': cuisine,
      'imageUrl': imageUrl,
    };
  }

  // ==================== 工具方法 ====================

  /// 获取食物显示名称（带份量）
  String get displayName {
    return '$name ${amount.toStringAsFixed(0)}$unit';
  }

  /// 计算性价比（蛋白质/元）
  double? get proteinROI {
    if (price == null || price == 0) return null;
    return nutrition.protein / price!;
  }

  /// 计算性价比（热量/元）
  double? get caloriesROI {
    if (price == null || price == 0) return null;
    return nutrition.calories / price!;
  }

  /// 复制并修改部分字段
  FoodItem copyWith({
    String? id,
    String? name,
    String? description,
    double? amount,
    String? unit,
    Nutrition? nutrition,
    double? price,
    String? category,
    String? cuisine,
    String? imageUrl,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      nutrition: nutrition ?? this.nutrition,
      price: price ?? this.price,
      category: category ?? this.category,
      cuisine: cuisine ?? this.cuisine,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}