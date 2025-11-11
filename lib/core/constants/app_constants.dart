// lib/core/constants/app_constants.dart
// Dart类文件

/// 应用通用常量配置类
class AppConstants {
  // ==================== 应用信息 ====================

  static const String APP_NAME = 'Healthy Eats';
  static const String APP_VERSION = '1.0.0';
  static const String APP_DESCRIPTION = 'AI-powered healthy eating recommendation app';

  // ==================== 健康目标选项 ====================

  static const List<String> HEALTH_GOALS = [
    '减脂',
    '增肌',
    '维持',
    '随意',
  ];

  // ==================== 餐食来源级别 ====================

  /// 餐食来源级别：1-5
  /// 1: 基本只吃餐馆和外卖
  /// 2: 大部分餐馆外卖，少量自己做
  /// 3: 餐馆外卖和自己做基本对半
  /// 4: 少量餐馆外卖，大部分自己做
  /// 5: 基本自己做
  static const int MEAL_SOURCE_MIN = 1;
  static const int MEAL_SOURCE_MAX = 5;

  static const Map<int, String> MEAL_SOURCE_LABELS = {
    1: '基本外食',
    2: '较多外食',
    3: '对半',
    4: '较多自己做',
    5: '基本自己做',
  };

  static const Map<int, String> MEAL_SOURCE_DESCRIPTIONS = {
    1: '基本只吃餐馆和外卖',
    2: '大部分餐馆外卖，少量自己做',
    3: '餐馆外卖和自己做基本对半',
    4: '少量餐馆外卖，大部分自己做',
    5: '基本自己做',
  };

  // ==================== 就餐方式 ====================

  static const List<String> DINING_STYLES = [
    '主要自己吃',
    '经常和朋友家人',
    '经常和同事',
  ];

  // ==================== 零食偏好 ====================

  static const List<String> SNACK_FREQUENCIES = [
    '不吃零食',
    '很少吃',
    '经常吃',
  ];

  // ==================== 菜系偏好 ====================

  static const List<String> CUISINES = [
    '中餐',
    '法餐',
    '意餐',
    '日料',
    '韩餐',
    '东南亚',
    '拉美',
    '中东',
    '印度',
    '美式',
  ];

  // ==================== 忌口食材分类 ====================

  /// 蔬菜类
  static const List<String> VEGETABLES = [
    '香菜',
    '芹菜',
    '苦瓜',
    '茄子',
    '青椒',
    '洋葱',
    '韭菜',
    '蒜',
    '姜',
  ];

  /// 水果类
  static const List<String> FRUITS = [
    '芒果',
    '榴莲',
    '菠萝',
    '奇异果',
    '木瓜',
    '火龙果',
    '荔枝',
  ];

  /// 肉类
  static const List<String> MEATS = [
    '猪肉',
    '牛肉',
    '羊肉',
    '鸡肉',
    '鸭肉',
    '鹅肉',
  ];

  /// 海鲜类
  static const List<String> SEAFOODS = [
    '鱼',
    '虾',
    '蟹',
    '贝类',
    '海藻',
    '章鱼',
    '鱿鱼',
  ];

  // ==================== 特殊饮食标签 ====================

  static const String VEGETARIAN = '素食者';
  static const String HIGH_BLOOD_SUGAR = '血糖偏高';

  // ==================== 推荐频率 ====================

  static const String RECOMMENDATION_DAILY = '每日推荐';
  static const String RECOMMENDATION_WEEKLY = '每周推荐';

  // ==================== 用户类型 ====================

  static const String USER_TYPE_FREE = '免费用户';
  static const String USER_TYPE_VIP = 'VIP用户';

  // ==================== 餐次 ====================

  static const List<String> MEAL_TIMES = [
    '早餐',
    '午餐',
    '晚餐',
    '加餐',
  ];

  // ==================== 提醒类型 ====================

  static const String REMINDER_BREAKFAST = '早餐提醒';
  static const String REMINDER_LUNCH = '午餐提醒';
  static const String REMINDER_DINNER = '晚餐提醒';
  static const String REMINDER_WATER = '喝水提醒';
  static const String REMINDER_REST = '休息提醒';
  static const String REMINDER_WEATHER = '天气关怀';

  // ==================== 默认提醒时间 ====================

  static const String DEFAULT_BREAKFAST_TIME = '08:00';
  static const String DEFAULT_LUNCH_TIME = '12:30';
  static const String DEFAULT_DINNER_TIME = '18:30';
  static const String DEFAULT_REST_TIME = '15:00';

  /// 喝水提醒间隔（小时）
  static const int WATER_REMINDER_INTERVAL_HOURS = 2;

  // ==================== 本地存储Key ====================

  static const String KEY_USER_PROFILE = 'user_profile';
  static const String KEY_IS_VIP = 'is_vip';
  static const String KEY_LANGUAGE = 'language';
  static const String KEY_THEME = 'theme';
  static const String KEY_REMINDERS = 'reminders';
  static const String KEY_MEAL_HISTORY = 'meal_history';

  // ==================== API相关 ====================

  /// AI API超时时间（秒）
  static const int API_TIMEOUT_SECONDS = 30;

  /// 最大重试次数
  static const int MAX_RETRY_COUNT = 3;

  // ==================== 天气相关 ====================

  /// 天气更新间隔（小时）
  static const int WEATHER_UPDATE_INTERVAL_HOURS = 3;

  // ==================== 统计相关 ====================

  /// 统计图表显示天数
  static const int STATS_DAYS_TO_SHOW = 7;

  /// 历史记录保存天数
  static const int HISTORY_RETENTION_DAYS = 90;

  // ==================== 页面路由名称 ====================

  static const String ROUTE_HOME = '/';
  static const String ROUTE_SETTINGS = '/settings';
  static const String ROUTE_MEAL_DETAIL = '/meal-detail';
  static const String ROUTE_STATS = '/stats';
  static const String ROUTE_RECORD = '/record';
  static const String ROUTE_COMMUNITY = '/community';
  static const String ROUTE_SUBSCRIPTION = '/subscription';

  // ==================== 工具方法 ====================

  /// 获取餐食来源标签
  static String getMealSourceLabel(int level) {
    return MEAL_SOURCE_LABELS[level] ?? '对半';
  }

  /// 获取餐食来源描述
  static String getMealSourceDescription(int level) {
    return MEAL_SOURCE_DESCRIPTIONS[level] ?? '餐馆外卖和自己做基本对半';
  }
}