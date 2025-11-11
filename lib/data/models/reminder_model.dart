// lib/data/models/reminder_model.dart
// Dart类文件

/// 提醒数据模型
class Reminder {
  // ==================== 基本信息 ====================

  final String id;
  final String type; // 早餐提醒/午餐提醒/晚餐提醒/喝水提醒/休息提醒/天气关怀
  final String title;
  final String? message;

  // ==================== 时间设置 ====================

  final String time; // HH:mm格式
  final List<int> weekdays; // 1-7，表示周一到周日，空列表表示每天

  // ==================== 状态 ====================

  final bool isEnabled;

  // ==================== 图标和样式 ====================

  final String emoji;

  // ==================== 构造函数 ====================

  Reminder({
    required this.id,
    required this.type,
    required this.title,
    this.message,
    required this.time,
    this.weekdays = const [],
    this.isEnabled = true,
    required this.emoji,
  });

  // ==================== JSON序列化 ====================

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      message: json['message'] as String?,
      time: json['time'] as String,
      weekdays: (json['weekdays'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList() ?? [],
      isEnabled: json['isEnabled'] as bool? ?? true,
      emoji: json['emoji'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'message': message,
      'time': time,
      'weekdays': weekdays,
      'isEnabled': isEnabled,
      'emoji': emoji,
    };
  }

  // ==================== 工具方法 ====================

  /// 获取完整显示文本
  String getDisplayText() {
    return '$emoji $title';
  }

  /// 获取时间显示
  String getTimeDisplay() {
    if (type == '喝水提醒') {
      return '每2小时';
    }
    return time;
  }

  /// 判断今天是否需要提醒
  bool shouldRemindToday() {
    if (!isEnabled) return false;
    if (weekdays.isEmpty) return true; // 每天都提醒

    final today = DateTime.now().weekday; // 1-7
    return weekdays.contains(today);
  }

  /// 获取下次提醒时间
  DateTime? getNextReminderTime() {
    if (!isEnabled) return null;

    final now = DateTime.now();
    final timeParts = time.split(':');
    if (timeParts.length != 2) return null;

    final hour = int.tryParse(timeParts[0]);
    final minute = int.tryParse(timeParts[1]);
    if (hour == null || minute == null) return null;

    var nextTime = DateTime(now.year, now.month, now.day, hour, minute);

    // 如果今天的时间已过，则设置为明天
    if (nextTime.isBefore(now)) {
      nextTime = nextTime.add(const Duration(days: 1));
    }

    // 如果有weekdays限制，找到下一个符合条件的日期
    if (weekdays.isNotEmpty) {
      while (!weekdays.contains(nextTime.weekday)) {
        nextTime = nextTime.add(const Duration(days: 1));
      }
    }

    return nextTime;
  }

  /// 复制并修改部分字段
  Reminder copyWith({
    String? id,
    String? type,
    String? title,
    String? message,
    String? time,
    List<int>? weekdays,
    bool? isEnabled,
    String? emoji,
  }) {
    return Reminder(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      time: time ?? this.time,
      weekdays: weekdays ?? this.weekdays,
      isEnabled: isEnabled ?? this.isEnabled,
      emoji: emoji ?? this.emoji,
    );
  }

  // ==================== 预设提醒 ====================

  /// 创建早餐提醒
  static Reminder createBreakfastReminder({String time = '08:00'}) {
    return Reminder(
      id: 'breakfast',
      type: '早餐提醒',
      title: '早餐时间',
      message: '该吃早餐啦！开始美好的一天~',
      time: time,
      emoji: '🌅',
    );
  }

  /// 创建午餐提醒
  static Reminder createLunchReminder({String time = '12:30'}) {
    return Reminder(
      id: 'lunch',
      type: '午餐提醒',
      title: '午餐时间',
      message: '中午了，记得按时吃午饭哦~',
      time: time,
      emoji: '☀️',
    );
  }

  /// 创建晚餐提醒
  static Reminder createDinnerReminder({String time = '18:30'}) {
    return Reminder(
      id: 'dinner',
      type: '晚餐提醒',
      title: '晚餐时间',
      message: '晚餐时间到了，享受美食吧~',
      time: time,
      emoji: '🌙',
    );
  }

  /// 创建喝水提醒
  static Reminder createWaterReminder({String time = '10:00'}) {
    return Reminder(
      id: 'water',
      type: '喝水提醒',
      title: '喝水提醒',
      message: '记得喝水哦，保持身体水分~',
      time: time,
      emoji: '💧',
    );
  }

  /// 创建休息提醒
  static Reminder createRestReminder({String time = '15:00'}) {
    return Reminder(
      id: 'rest',
      type: '休息提醒',
      title: '休息时间',
      message: '休息一下，放松身心~',
      time: time,
      emoji: '🧘',
    );
  }
}