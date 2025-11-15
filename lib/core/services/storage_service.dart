// lib/core/services/storage_service.dart
// Dart类文件

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../data/models/user_model.dart';

/// 本地存储服务
///
/// 基于 SharedPreferences 实现数据持久化
class StorageService {
  static StorageService? _instance;
  late SharedPreferences _prefs;

  // ==================== 存储键常量 ====================

  static const String _KEY_USER_PROFILE = 'user_profile';
  static const String _KEY_MEAL_HISTORY = 'meal_history';
  static const String _KEY_REMINDERS = 'reminders';
  static const String _KEY_API_KEY = 'openai_api_key'; // 新增：API Key

  // ==================== 单例模式 ====================

  StorageService._();

  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      _instance = StorageService._();
      _instance!._prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  // ==================== API Key管理 ====================

  /// 保存API Key
  Future<bool> saveApiKey(String apiKey) async {
    return await _prefs.setString(_KEY_API_KEY, apiKey);
  }

  /// 获取API Key
  String? getApiKey() {
    return _prefs.getString(_KEY_API_KEY);
  }

  /// 删除API Key
  Future<bool> deleteApiKey() async {
    return await _prefs.remove(_KEY_API_KEY);
  }

  /// 检查是否有API Key
  bool hasApiKey() {
    final key = _prefs.getString(_KEY_API_KEY);
    return key != null && key.isNotEmpty;
  }

  // ==================== 用户信息 ====================

  /// 保存用户信息
  Future<bool> saveUserProfile(UserProfile user) async {
    final jsonString = jsonEncode(user.toJson());
    return await _prefs.setString(_KEY_USER_PROFILE, jsonString);
  }

  /// 获取用户信息
  Future<UserProfile?> getUserProfile() async {
    final jsonString = _prefs.getString(_KEY_USER_PROFILE);
    if (jsonString == null) return null;

    try {
      final json = jsonDecode(jsonString);
      return UserProfile.fromJson(json);
    } catch (e) {
      print('Error parsing user profile: $e');
      return null;
    }
  }

  /// 删除用户信息
  Future<bool> deleteUserProfile() async {
    return await _prefs.remove(_KEY_USER_PROFILE);
  }

  // ==================== 餐食历史 ====================

  /// 保存餐食历史
  Future<bool> saveMealHistory(List<Map<String, dynamic>> meals) async {
    final jsonString = jsonEncode(meals);
    return await _prefs.setString(_KEY_MEAL_HISTORY, jsonString);
  }

  /// 获取餐食历史
  List<Map<String, dynamic>> getMealHistory() {
    final jsonString = _prefs.getString(_KEY_MEAL_HISTORY);
    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error parsing meal history: $e');
      return [];
    }
  }

  // ==================== 提醒设置 ====================

  /// 保存提醒设置
  Future<bool> saveReminders(List<Map<String, dynamic>> reminders) async {
    final jsonString = jsonEncode(reminders);
    return await _prefs.setString(_KEY_REMINDERS, jsonString);
  }

  /// 获取提醒设置
  List<Map<String, dynamic>> getReminders() {
    final jsonString = _prefs.getString(_KEY_REMINDERS);
    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error parsing reminders: $e');
      return [];
    }
  }

  // ==================== 通用方法 ====================

  /// 保存字符串
  Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  /// 获取字符串
  String? getString(String key) {
    return _prefs.getString(key);
  }

  /// 保存整数
  Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  /// 获取整数
  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  /// 保存布尔值
  Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  /// 获取布尔值
  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  /// 删除指定键
  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  /// 清空所有数据
  Future<bool> clear() async {
    return await _prefs.clear();
  }

  /// 检查键是否存在
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }
}
