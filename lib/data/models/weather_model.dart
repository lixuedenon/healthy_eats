// lib/data/models/weather_model.dart
// Dart类文件

/// 天气数据模型
class Weather {
  // ==================== 基本信息 ====================

  final String city; // 城市
  final double temperature; // 温度（摄氏度）
  final double feelsLike; // 体感温度
  final String condition; // 天气状况（晴/多云/阴/雨/雪等）
  final String description; // 详细描述

  // ==================== 温度范围 ====================

  final double tempMin; // 最低温度
  final double tempMax; // 最高温度

  // ==================== 其他指标 ====================

  final int humidity; // 湿度（%）
  final double windSpeed; // 风速（m/s）
  final int pressure; // 气压（hPa）

  // ==================== 时间 ====================

  final DateTime timestamp; // 天气数据时间戳
  final DateTime sunrise; // 日出时间
  final DateTime sunset; // 日落时间

  // ==================== 图标 ====================

  final String iconCode; // 天气图标代码

  // ==================== 构造函数 ====================

  Weather({
    required this.city,
    required this.temperature,
    required this.feelsLike,
    required this.condition,
    required this.description,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.timestamp,
    required this.sunrise,
    required this.sunset,
    required this.iconCode,
  });

  // ==================== JSON序列化 ====================

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      city: json['city'] as String,
      temperature: (json['temperature'] as num).toDouble(),
      feelsLike: (json['feelsLike'] as num).toDouble(),
      condition: json['condition'] as String,
      description: json['description'] as String,
      tempMin: (json['tempMin'] as num).toDouble(),
      tempMax: (json['tempMax'] as num).toDouble(),
      humidity: json['humidity'] as int,
      windSpeed: (json['windSpeed'] as num).toDouble(),
      pressure: json['pressure'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      sunrise: DateTime.parse(json['sunrise'] as String),
      sunset: DateTime.parse(json['sunset'] as String),
      iconCode: json['iconCode'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'temperature': temperature,
      'feelsLike': feelsLike,
      'condition': condition,
      'description': description,
      'tempMin': tempMin,
      'tempMax': tempMax,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'pressure': pressure,
      'timestamp': timestamp.toIso8601String(),
      'sunrise': sunrise.toIso8601String(),
      'sunset': sunset.toIso8601String(),
      'iconCode': iconCode,
    };
  }

  // ==================== 工具方法 ====================

  /// 获取天气emoji
  String getWeatherEmoji() {
    if (condition.contains('晴')) return '☀️';
    if (condition.contains('多云')) return '⛅';
    if (condition.contains('阴')) return '☁️';
    if (condition.contains('雨')) return '🌧️';
    if (condition.contains('雪')) return '❄️';
    if (condition.contains('雾')) return '🌫️';
    if (condition.contains('风')) return '💨';
    return '🌤️';
  }

  /// 获取天气显示文本
  String getWeatherDisplay() {
    return '$city · ${condition} ${temperature.toStringAsFixed(0)}°C';
  }

  /// 获取温度范围显示
  String getTempRangeDisplay() {
    return '${tempMin.toStringAsFixed(0)}°C ~ ${tempMax.toStringAsFixed(0)}°C';
  }

  /// 判断是否炎热（温度 > 30°C）
  bool get isHot => temperature > 30;

  /// 判断是否寒冷（温度 < 10°C）
  bool get isCold => temperature < 10;

  /// 判断是否潮湿（湿度 > 80%）
  bool get isHumid => humidity > 80;

  /// 判断是否干燥（湿度 < 30%）
  bool get isDry => humidity < 30;

  /// 获取健康提醒
  String getHealthReminder() {
    List<String> reminders = [];

    if (isHot) {
      reminders.add('天气炎热，多喝水，避免中暑');
    }

    if (isCold) {
      reminders.add('天气寒冷，注意保暖，多喝温水');
    }

    if (isHumid) {
      reminders.add('湿度较高，注意防潮，适当除湿');
    }

    if (isDry) {
      reminders.add('空气干燥，多喝水，保持皮肤湿润');
    }

    if (condition.contains('雨')) {
      reminders.add('今日有雨，出门记得带伞');
    }

    if (condition.contains('雪')) {
      reminders.add('今日有雪，注意防滑，小心路面');
    }

    if (windSpeed > 10) {
      reminders.add('风力较大，注意添加衣物');
    }

    if (reminders.isEmpty) {
      reminders.add('天气适宜，适合户外活动');
    }

    return reminders.first;
  }

  /// 获取饮食建议
  String getDietarySuggestion() {
    if (isHot) {
      return '建议多吃清凉解暑的食物，如西瓜、绿豆汤等';
    }

    if (isCold) {
      return '建议多吃温热的食物，如姜汤、热粥等';
    }

    if (isDry) {
      return '建议多吃润燥的食物，如梨、蜂蜜、银耳等';
    }

    if (isHumid) {
      return '建议多吃祛湿的食物，如薏米、红豆等';
    }

    return '均衡饮食，保持健康';
  }

  /// 判断数据是否过期（超过3小时）
  bool get isExpired {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    return diff.inHours > 3;
  }
}