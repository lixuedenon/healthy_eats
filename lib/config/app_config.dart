// lib/config/app_config.dart
// Dart类文件

/// 应用配置类
///
/// 包含API密钥、环境配置等敏感信息
/// 注意：实际项目中应该使用环境变量或安全存储方式
class AppConfig {
  // ==================== 环境配置 ====================

  /// 当前环境：dev(开发)、staging(测试)、prod(生产)
  static const String ENVIRONMENT = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'dev',
  );

  /// 是否为开发环境
  static bool get isDevelopment => ENVIRONMENT == 'dev';

  /// 是否为生产环境
  static bool get isProduction => ENVIRONMENT == 'prod';

  // ==================== API配置 ====================

  /// AI API基础URL（根据实际使用的AI服务配置）
  /// 例如：OpenAI、Claude、或其他AI服务
  static const String AI_API_BASE_URL = String.fromEnvironment(
    'AI_API_BASE_URL',
    defaultValue: 'https://api.openai.com/v1',
  );

  /// AI API密钥
  /// 注意：实际项目中不应该硬编码，应该从环境变量或安全存储中获取
  static const String AI_API_KEY = String.fromEnvironment(
    'AI_API_KEY',
    defaultValue: 'your-api-key-here',
  );

  /// AI模型名称
  static const String AI_MODEL = String.fromEnvironment(
    'AI_MODEL',
    defaultValue: 'gpt-4',
  );

  /// API请求超时时间（秒）
  static const int API_TIMEOUT_SECONDS = 30;

  // ==================== 天气API配置 ====================

  /// 天气API基础URL
  static const String WEATHER_API_BASE_URL = String.fromEnvironment(
    'WEATHER_API_BASE_URL',
    defaultValue: 'https://api.openweathermap.org/data/2.5',
  );

  /// 天气API密钥
  static const String WEATHER_API_KEY = String.fromEnvironment(
    'WEATHER_API_KEY',
    defaultValue: 'your-weather-api-key-here',
  );

  // ==================== 图像识别API配置 ====================

  /// 图像识别API基础URL（用于食物识别）
  static const String IMAGE_RECOGNITION_API_URL = String.fromEnvironment(
    'IMAGE_RECOGNITION_API_URL',
    defaultValue: 'https://api.clarifai.com/v2',
  );

  /// 图像识别API密钥
  static const String IMAGE_RECOGNITION_API_KEY = String.fromEnvironment(
    'IMAGE_RECOGNITION_API_KEY',
    defaultValue: 'your-image-api-key-here',
  );

  // ==================== 支付配置（VIP订阅） ====================

  /// 应用内购买相关配置（iOS）
  static const String IOS_APP_ID = 'your-ios-app-id';

  /// Google Play应用ID（Android）
  static const String ANDROID_APP_ID = 'com.example.healthy_eats';

  /// VIP月度订阅ID
  static const String VIP_MONTHLY_SUBSCRIPTION_ID = 'vip_monthly';

  /// VIP年度订阅ID
  static const String VIP_YEARLY_SUBSCRIPTION_ID = 'vip_yearly';

  // ==================== 功能开关 ====================

  /// 是否启用语音输入功能
  static const bool ENABLE_VOICE_INPUT = true;

  /// 是否启用图像识别功能
  static const bool ENABLE_IMAGE_RECOGNITION = true;

  /// 是否启用天气提醒功能
  static const bool ENABLE_WEATHER_REMINDER = true;

  /// 是否启用社区功能
  static const bool ENABLE_COMMUNITY = true;

  /// 是否启用VIP订阅功能
  static const bool ENABLE_VIP_SUBSCRIPTION = true;

  /// 是否启用调试模式
  static bool get enableDebugMode => isDevelopment;

  // ==================== 默认配置 ====================

  /// 默认语言
  static const String DEFAULT_LANGUAGE = 'zh';

  /// 默认城市
  static const String DEFAULT_CITY = '北京';

  /// 默认主题模式（light/dark）
  static const String DEFAULT_THEME_MODE = 'light';

  // ==================== AI提示词配置 ====================

  /// AI回复的最大Token数
  static const int MAX_TOKENS = 2000;

  /// AI温度参数（控制创造性）
  static const double TEMPERATURE = 0.7;

  /// AI Top-P参数
  static const double TOP_P = 0.9;

  // ==================== 缓存配置 ====================

  /// 缓存过期时间（小时）
  static const int CACHE_EXPIRY_HOURS = 24;

  /// 图片缓存最大大小（MB）
  static const int MAX_IMAGE_CACHE_SIZE = 100;

  // ==================== 日志配置 ====================

  /// 是否启用日志
  static bool get enableLogging => isDevelopment;

  /// 日志级别：verbose, debug, info, warning, error
  static const String LOG_LEVEL = 'debug';

  // ==================== 工具方法 ====================

  /// 获取完整的API URL
  static String getAIApiUrl(String endpoint) {
    return '$AI_API_BASE_URL/$endpoint';
  }

  /// 获取天气API URL
  static String getWeatherApiUrl(String city) {
    return '$WEATHER_API_BASE_URL/weather?q=$city&appid=$WEATHER_API_KEY';
  }

  /// 验证API密钥是否已配置
  static bool isApiKeyConfigured() {
    return AI_API_KEY != 'your-api-key-here' &&
           AI_API_KEY.isNotEmpty;
  }

  /// 验证天气API密钥是否已配置
  static bool isWeatherApiKeyConfigured() {
    return WEATHER_API_KEY != 'your-weather-api-key-here' &&
           WEATHER_API_KEY.isNotEmpty;
  }
}