// lib/data/models/user_model.dart
// Dart类文件

/// 用户信息数据模型
class UserProfile {
  // ==================== 基础信息 ====================

  final String id;
  final String name;
  final String? city;
  final int? age;
  final double? height; // cm
  final double? weight; // kg
  final String? gender; // 男/女/其他

  // ==================== 健康目标 ====================

  final String healthGoal; // 减脂/增肌/维持/随意

  // ==================== 餐食来源 ====================

  /// 默认餐食来源级别（1-5）
  final int defaultMealSource;

  // ==================== 就餐方式 ====================

  /// 默认就餐方式
  final String defaultDiningStyle; // 主要自己吃/经常和朋友家人/经常和同事

  // ==================== 饮食偏好 ====================

  /// 菜系偏好（多选）
  final List<String> preferredCuisines;

  /// 零食偏好
  final String snackFrequency; // 不吃零食/很少吃/经常吃

  // ==================== 忌口食材 ====================

  final List<String> avoidVegetables;
  final List<String> avoidFruits;
  final List<String> avoidMeats;
  final List<String> avoidSeafood;

  // ==================== 特殊饮食 ====================

  final bool isVegetarian; // 素食者
  final bool hasHighBloodSugar; // 血糖偏高

  // ==================== 推荐频率 ====================

  final String recommendationFrequency; // 每日推荐/每周推荐

  // ==================== VIP状态 ====================

  final bool isVIP;
  final DateTime? vipExpiryDate;

  // ==================== 提醒设置 ====================

  final bool enableBreakfastReminder;
  final String breakfastTime; // HH:mm格式

  final bool enableLunchReminder;
  final String lunchTime;

  final bool enableDinnerReminder;
  final String dinnerTime;

  final bool enableWaterReminder;
  final int waterReminderInterval; // 小时

  final bool enableRestReminder;
  final String restTime;

  final bool enableWeatherReminder;

  // ==================== 其他 ====================

  final String language; // zh/en/es/fr/de/ja/ru/ko
  final DateTime createdAt;
  final DateTime updatedAt;

  // ==================== 构造函数 ====================

  UserProfile({
    required this.id,
    required this.name,
    this.city,
    this.age,
    this.height,
    this.weight,
    this.gender,
    this.healthGoal = '维持',
    this.defaultMealSource = 3,
    this.defaultDiningStyle = '主要自己吃',
    this.preferredCuisines = const ['中餐'],
    this.snackFrequency = '很少吃',
    this.avoidVegetables = const [],
    this.avoidFruits = const [],
    this.avoidMeats = const [],
    this.avoidSeafood = const [],
    this.isVegetarian = false,
    this.hasHighBloodSugar = false,
    this.recommendationFrequency = '每周推荐',
    this.isVIP = false,
    this.vipExpiryDate,
    this.enableBreakfastReminder = true,
    this.breakfastTime = '08:00',
    this.enableLunchReminder = true,
    this.lunchTime = '12:30',
    this.enableDinnerReminder = true,
    this.dinnerTime = '18:30',
    this.enableWaterReminder = true,
    this.waterReminderInterval = 2,
    this.enableRestReminder = true,
    this.restTime = '15:00',
    this.enableWeatherReminder = true,
    this.language = 'zh',
    required this.createdAt,
    required this.updatedAt,
  });

  // ==================== JSON序列化 ====================

  /// 从JSON创建UserProfile对象
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      city: json['city'] as String?,
      age: json['age'] as int?,
      height: json['height'] as double?,
      weight: json['weight'] as double?,
      gender: json['gender'] as String?,
      healthGoal: json['healthGoal'] as String? ?? '维持',
      defaultMealSource: json['defaultMealSource'] as int? ?? 3,
      defaultDiningStyle: json['defaultDiningStyle'] as String? ?? '主要自己吃',
      preferredCuisines: (json['preferredCuisines'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? ['中餐'],
      snackFrequency: json['snackFrequency'] as String? ?? '很少吃',
      avoidVegetables: (json['avoidVegetables'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      avoidFruits: (json['avoidFruits'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      avoidMeats: (json['avoidMeats'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      avoidSeafood: (json['avoidSeafood'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      isVegetarian: json['isVegetarian'] as bool? ?? false,
      hasHighBloodSugar: json['hasHighBloodSugar'] as bool? ?? false,
      recommendationFrequency: json['recommendationFrequency'] as String? ?? '每周推荐',
      isVIP: json['isVIP'] as bool? ?? false,
      vipExpiryDate: json['vipExpiryDate'] != null
          ? DateTime.parse(json['vipExpiryDate'] as String)
          : null,
      enableBreakfastReminder: json['enableBreakfastReminder'] as bool? ?? true,
      breakfastTime: json['breakfastTime'] as String? ?? '08:00',
      enableLunchReminder: json['enableLunchReminder'] as bool? ?? true,
      lunchTime: json['lunchTime'] as String? ?? '12:30',
      enableDinnerReminder: json['enableDinnerReminder'] as bool? ?? true,
      dinnerTime: json['dinnerTime'] as String? ?? '18:30',
      enableWaterReminder: json['enableWaterReminder'] as bool? ?? true,
      waterReminderInterval: json['waterReminderInterval'] as int? ?? 2,
      enableRestReminder: json['enableRestReminder'] as bool? ?? true,
      restTime: json['restTime'] as String? ?? '15:00',
      enableWeatherReminder: json['enableWeatherReminder'] as bool? ?? true,
      language: json['language'] as String? ?? 'zh',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'age': age,
      'height': height,
      'weight': weight,
      'gender': gender,
      'healthGoal': healthGoal,
      'defaultMealSource': defaultMealSource,
      'defaultDiningStyle': defaultDiningStyle,
      'preferredCuisines': preferredCuisines,
      'snackFrequency': snackFrequency,
      'avoidVegetables': avoidVegetables,
      'avoidFruits': avoidFruits,
      'avoidMeats': avoidMeats,
      'avoidSeafood': avoidSeafood,
      'isVegetarian': isVegetarian,
      'hasHighBloodSugar': hasHighBloodSugar,
      'recommendationFrequency': recommendationFrequency,
      'isVIP': isVIP,
      'vipExpiryDate': vipExpiryDate?.toIso8601String(),
      'enableBreakfastReminder': enableBreakfastReminder,
      'breakfastTime': breakfastTime,
      'enableLunchReminder': enableLunchReminder,
      'lunchTime': lunchTime,
      'enableDinnerReminder': enableDinnerReminder,
      'dinnerTime': dinnerTime,
      'enableWaterReminder': enableWaterReminder,
      'waterReminderInterval': waterReminderInterval,
      'enableRestReminder': enableRestReminder,
      'restTime': restTime,
      'enableWeatherReminder': enableWeatherReminder,
      'language': language,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // ==================== CopyWith方法 ====================

  /// 复制并修改部分字段
  UserProfile copyWith({
    String? id,
    String? name,
    String? city,
    int? age,
    double? height,
    double? weight,
    String? gender,
    String? healthGoal,
    int? defaultMealSource,
    String? defaultDiningStyle,
    List<String>? preferredCuisines,
    String? snackFrequency,
    List<String>? avoidVegetables,
    List<String>? avoidFruits,
    List<String>? avoidMeats,
    List<String>? avoidSeafood,
    bool? isVegetarian,
    bool? hasHighBloodSugar,
    String? recommendationFrequency,
    bool? isVIP,
    DateTime? vipExpiryDate,
    bool? enableBreakfastReminder,
    String? breakfastTime,
    bool? enableLunchReminder,
    String? lunchTime,
    bool? enableDinnerReminder,
    String? dinnerTime,
    bool? enableWaterReminder,
    int? waterReminderInterval,
    bool? enableRestReminder,
    String? restTime,
    bool? enableWeatherReminder,
    String? language,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      city: city ?? this.city,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      gender: gender ?? this.gender,
      healthGoal: healthGoal ?? this.healthGoal,
      defaultMealSource: defaultMealSource ?? this.defaultMealSource,
      defaultDiningStyle: defaultDiningStyle ?? this.defaultDiningStyle,
      preferredCuisines: preferredCuisines ?? this.preferredCuisines,
      snackFrequency: snackFrequency ?? this.snackFrequency,
      avoidVegetables: avoidVegetables ?? this.avoidVegetables,
      avoidFruits: avoidFruits ?? this.avoidFruits,
      avoidMeats: avoidMeats ?? this.avoidMeats,
      avoidSeafood: avoidSeafood ?? this.avoidSeafood,
      isVegetarian: isVegetarian ?? this.isVegetarian,
      hasHighBloodSugar: hasHighBloodSugar ?? this.hasHighBloodSugar,
      recommendationFrequency: recommendationFrequency ?? this.recommendationFrequency,
      isVIP: isVIP ?? this.isVIP,
      vipExpiryDate: vipExpiryDate ?? this.vipExpiryDate,
      enableBreakfastReminder: enableBreakfastReminder ?? this.enableBreakfastReminder,
      breakfastTime: breakfastTime ?? this.breakfastTime,
      enableLunchReminder: enableLunchReminder ?? this.enableLunchReminder,
      lunchTime: lunchTime ?? this.lunchTime,
      enableDinnerReminder: enableDinnerReminder ?? this.enableDinnerReminder,
      dinnerTime: dinnerTime ?? this.dinnerTime,
      enableWaterReminder: enableWaterReminder ?? this.enableWaterReminder,
      waterReminderInterval: waterReminderInterval ?? this.waterReminderInterval,
      enableRestReminder: enableRestReminder ?? this.enableRestReminder,
      restTime: restTime ?? this.restTime,
      enableWeatherReminder: enableWeatherReminder ?? this.enableWeatherReminder,
      language: language ?? this.language,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ==================== 工具方法 ====================

  /// 获取所有忌口食材
  List<String> getAllAvoidFoods() {
    return [
      ...avoidVegetables,
      ...avoidFruits,
      ...avoidMeats,
      ...avoidSeafood,
    ];
  }

  /// 检查VIP是否有效
  bool get isVIPValid {
    if (!isVIP) return false;
    if (vipExpiryDate == null) return true;
    return vipExpiryDate!.isAfter(DateTime.now());
  }

  /// 计算BMI
  double? get bmi {
    if (height == null || weight == null || height == 0) return null;
    return weight! / ((height! / 100) * (height! / 100));
  }

  /// BMI评级
  String? get bmiRating {
    final bmiValue = bmi;
    if (bmiValue == null) return null;

    if (bmiValue < 18.5) return '偏瘦';
    if (bmiValue < 24) return '正常';
    if (bmiValue < 28) return '偏胖';
    return '肥胖';
  }
}