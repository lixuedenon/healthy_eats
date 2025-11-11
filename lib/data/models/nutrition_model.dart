// lib/data/models/nutrition_model.dart
// Dart类文件

/// 营养成分数据模型
class Nutrition {
  // ==================== 宏量营养素 ====================

  /// 热量（kcal）
  final double calories;

  /// 蛋白质（g）
  final double protein;

  /// 碳水化合物（g）
  final double carbs;

  /// 脂肪（g）
  final double fat;

  // ==================== 微量营养素 ====================

  /// 镁（mg）
  final double? magnesium;

  /// 维生素B6（mg）
  final double? vitaminB6;

  /// 维生素B12（μg）
  final double? vitaminB12;

  /// 色氨酸（mg）
  final double? tryptophan;

  /// Omega-3（g）
  final double? omega3;

  /// 维生素C（mg）
  final double? vitaminC;

  /// 铁（mg）
  final double? iron;

  /// 膳食纤维（g）
  final double? fiber;

  /// 钙（mg）
  final double? calcium;

  // ==================== 构造函数 ====================

  Nutrition({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.magnesium,
    this.vitaminB6,
    this.vitaminB12,
    this.tryptophan,
    this.omega3,
    this.vitaminC,
    this.iron,
    this.fiber,
    this.calcium,
  });

  // ==================== JSON序列化 ====================

  factory Nutrition.fromJson(Map<String, dynamic> json) {
    return Nutrition(
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      magnesium: json['magnesium'] != null ? (json['magnesium'] as num).toDouble() : null,
      vitaminB6: json['vitaminB6'] != null ? (json['vitaminB6'] as num).toDouble() : null,
      vitaminB12: json['vitaminB12'] != null ? (json['vitaminB12'] as num).toDouble() : null,
      tryptophan: json['tryptophan'] != null ? (json['tryptophan'] as num).toDouble() : null,
      omega3: json['omega3'] != null ? (json['omega3'] as num).toDouble() : null,
      vitaminC: json['vitaminC'] != null ? (json['vitaminC'] as num).toDouble() : null,
      iron: json['iron'] != null ? (json['iron'] as num).toDouble() : null,
      fiber: json['fiber'] != null ? (json['fiber'] as num).toDouble() : null,
      calcium: json['calcium'] != null ? (json['calcium'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'magnesium': magnesium,
      'vitaminB6': vitaminB6,
      'vitaminB12': vitaminB12,
      'tryptophan': tryptophan,
      'omega3': omega3,
      'vitaminC': vitaminC,
      'iron': iron,
      'fiber': fiber,
      'calcium': calcium,
    };
  }

  // ==================== 工具方法 ====================

  /// 获取宏量营养素摘要
  String getMacroSummary() {
    return '蛋白质 ${protein.toStringAsFixed(0)}g | '
           '碳水 ${carbs.toStringAsFixed(0)}g | '
           '脂肪 ${fat.toStringAsFixed(0)}g';
  }

  /// 获取微量营养素列表（非空的）
  Map<String, double> getMicronutrients() {
    Map<String, double> result = {};

    if (magnesium != null) result['镁'] = magnesium!;
    if (vitaminB6 != null) result['维生素B6'] = vitaminB6!;
    if (vitaminB12 != null) result['维生素B12'] = vitaminB12!;
    if (tryptophan != null) result['色氨酸'] = tryptophan!;
    if (omega3 != null) result['Omega-3'] = omega3!;
    if (vitaminC != null) result['维生素C'] = vitaminC!;
    if (iron != null) result['铁'] = iron!;
    if (fiber != null) result['膳食纤维'] = fiber!;
    if (calcium != null) result['钙'] = calcium!;

    return result;
  }

  /// 计算蛋白质占比（%）
  double get proteinPercentage {
    final totalCalories = protein * 4 + carbs * 4 + fat * 9;
    if (totalCalories == 0) return 0;
    return (protein * 4 / totalCalories) * 100;
  }

  /// 计算碳水占比（%）
  double get carbsPercentage {
    final totalCalories = protein * 4 + carbs * 4 + fat * 9;
    if (totalCalories == 0) return 0;
    return (carbs * 4 / totalCalories) * 100;
  }

  /// 计算脂肪占比（%）
  double get fatPercentage {
    final totalCalories = protein * 4 + carbs * 4 + fat * 9;
    if (totalCalories == 0) return 0;
    return (fat * 9 / totalCalories) * 100;
  }

  /// 合并营养成分（用于计算总和）
  Nutrition operator +(Nutrition other) {
    return Nutrition(
      calories: calories + other.calories,
      protein: protein + other.protein,
      carbs: carbs + other.carbs,
      fat: fat + other.fat,
      magnesium: (magnesium ?? 0) + (other.magnesium ?? 0),
      vitaminB6: (vitaminB6 ?? 0) + (other.vitaminB6 ?? 0),
      vitaminB12: (vitaminB12 ?? 0) + (other.vitaminB12 ?? 0),
      tryptophan: (tryptophan ?? 0) + (other.tryptophan ?? 0),
      omega3: (omega3 ?? 0) + (other.omega3 ?? 0),
      vitaminC: (vitaminC ?? 0) + (other.vitaminC ?? 0),
      iron: (iron ?? 0) + (other.iron ?? 0),
      fiber: (fiber ?? 0) + (other.fiber ?? 0),
      calcium: (calcium ?? 0) + (other.calcium ?? 0),
    );
  }

  /// 创建空营养成分
  static Nutrition get empty => Nutrition(
    calories: 0,
    protein: 0,
    carbs: 0,
    fat: 0,
  );
}