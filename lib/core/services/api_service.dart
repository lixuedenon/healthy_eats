// lib/core/services/api_service.dart
// Dart类文件

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';

/// API服务基类
///
/// 提供HTTP请求的基础封装
class ApiService {
  final String baseUrl;
  final Map<String, String> defaultHeaders;

  ApiService({
    required this.baseUrl,
    Map<String, String>? headers,
  }) : defaultHeaders = {
    'Content-Type': 'application/json',
    ...?headers,
  };

  // ==================== GET请求 ====================

  /// GET请求
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      final mergedHeaders = {...defaultHeaders, ...?headers};

      final response = await http
          .get(uri, headers: mergedHeaders)
          .timeout(Duration(seconds: AppConfig.API_TIMEOUT_SECONDS));

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ==================== POST请求 ====================

  /// POST请求
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final mergedHeaders = {...defaultHeaders, ...?headers};
      final jsonBody = body != null ? jsonEncode(body) : null;

      final response = await http
          .post(uri, headers: mergedHeaders, body: jsonBody)
          .timeout(Duration(seconds: AppConfig.API_TIMEOUT_SECONDS));

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ==================== PUT请求 ====================

  /// PUT请求
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final mergedHeaders = {...defaultHeaders, ...?headers};
      final jsonBody = body != null ? jsonEncode(body) : null;

      final response = await http
          .put(uri, headers: mergedHeaders, body: jsonBody)
          .timeout(Duration(seconds: AppConfig.API_TIMEOUT_SECONDS));

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ==================== DELETE请求 ====================

  /// DELETE请求
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final mergedHeaders = {...defaultHeaders, ...?headers};

      final response = await http
          .delete(uri, headers: mergedHeaders)
          .timeout(Duration(seconds: AppConfig.API_TIMEOUT_SECONDS));

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ==================== 辅助方法 ====================

  /// 构建URI
  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParameters]) {
    final path = endpoint.startsWith('/') ? endpoint : '/$endpoint';

    if (queryParameters != null && queryParameters.isNotEmpty) {
      return Uri.parse('$baseUrl$path').replace(
        queryParameters: queryParameters.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      );
    }

    return Uri.parse('$baseUrl$path');
  }

  /// 处理响应
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // 成功响应
      if (response.body.isEmpty) {
        return {'success': true, 'data': null};
      }

      try {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } catch (e) {
        return {
          'success': false,
          'error': 'Failed to parse response',
          'message': e.toString(),
        };
      }
    } else {
      // 错误响应
      String errorMessage = 'Request failed';

      try {
        final errorData = jsonDecode(response.body);
        errorMessage = errorData['message'] ?? errorMessage;
      } catch (e) {
        errorMessage = response.body.isNotEmpty
            ? response.body
            : 'HTTP ${response.statusCode}';
      }

      return {
        'success': false,
        'error': 'HTTP Error',
        'statusCode': response.statusCode,
        'message': errorMessage,
      };
    }
  }

  /// 处理错误
  Map<String, dynamic> _handleError(dynamic error) {
    print('API Error: $error');

    return {
      'success': false,
      'error': 'Network Error',
      'message': error.toString(),
    };
  }
}

/// AI API服务
class AIApiService extends ApiService {
  AIApiService()
      : super(
          baseUrl: AppConfig.AI_API_BASE_URL,
          headers: {
            'Authorization': 'Bearer ${AppConfig.AI_API_KEY}',
          },
        );

  /// 发送聊天完成请求
  Future<Map<String, dynamic>> chatCompletion({
    required String prompt,
    String model = 'gpt-4',
    int maxTokens = 2000,
    double temperature = 0.7,
  }) async {
    return await post(
      'chat/completions',
      body: {
        'model': model,
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
        'max_tokens': maxTokens,
        'temperature': temperature,
      },
    );
  }
}

/// 天气API服务
class WeatherApiService extends ApiService {
  WeatherApiService()
      : super(
          baseUrl: AppConfig.WEATHER_API_BASE_URL,
        );

  /// 获取城市天气
  Future<Map<String, dynamic>> getWeather(String city) async {
    return await get(
      'weather',
      queryParameters: {
        'q': city,
        'appid': AppConfig.WEATHER_API_KEY,
        'units': 'metric', // 使用摄氏度
        'lang': 'zh_cn', // 中文
      },
    );
  }
}