// lib/core/services/storage_service.dart
// Dart类文件

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_model.dart';
import '../constants/app_constants.dart';

/// 本地存储服务
///
/// 使用SharedPreferences进行简单的键值对存储
class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _prefs;

  StorageService._();

  /// 获取单例实例
  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      _instance = StorageService._();
      await _instance!._init();
    }
    return _instance!;
  }

  /// 初始化
  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ==================== 用户信息存储 ====================

  /// 保存用户信息
  Future<bool> saveUserProfile(UserProfile user) async {
    try {
      final jsonString = jsonEncode(user.toJson());
      return await _prefs!.setString(AppConstants.KEY_USER_PROFILE, jsonString);
    } catch (e) {
      print('Error saving user profile: $e');
      return false;
    }
  }

  /// 获取用户信息
  Future<UserProfile?> getUserProfile() async {
    try {
      final jsonString = _prefs!.getString(AppConstants.KEY_USER_PROFILE);
      if (jsonString == null) return null;

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return UserProfile.fromJson(json);
    } catch (e) {
      print('Error loading user profile: $e');
      return null;
    }
  }

  /// 删除用户信息
  Future<bool> deleteUserProfile() async {
    return await _prefs!.remove(AppConstants.KEY_USER_PROFILE);
  }

  // ==================== VIP状态 ====================

  /// 保存VIP状态
  Future<bool> saveVIPStatus(bool isVIP) async {
    return await _prefs!.setBool(AppConstants.KEY_IS_VIP, isVIP);
  }

  /// 获取VIP状态
  bool getVIPStatus() {
    return _prefs!.getBool(AppConstants.KEY_IS_VIP) ?? false;
  }

  // ==================== 语言设置 ====================

  /// 保存语言设置
  Future<bool> saveLanguage(String languageCode) async {
    return await _prefs!.setString(AppConstants.KEY_LANGUAGE, languageCode);
  }

  /// 获取语言设置
  String getLanguage() {
    return _prefs!.getString(AppConstants.KEY_LANGUAGE) ?? 'zh';
  }

  // ==================== 主题设置 ====================

  /// 保存主题设置
  Future<bool> saveTheme(String theme) async {
    return await _prefs!.setString(AppConstants.KEY_THEME, theme);
  }

  /// 获取主题设置
  String getTheme() {
    return _prefs!.getString(AppConstants.KEY_THEME) ?? 'light';
  }

  // ==================== 提醒设置 ====================

  /// 保存提醒设置
  Future<bool> saveReminders(List<Map<String, dynamic>> reminders) async {
    try {
      final jsonString = jsonEncode(reminders);
      return await _prefs!.setString(AppConstants.KEY_REMINDERS, jsonString);
    } catch (e) {
      print('Error saving reminders: $e');
      return false;
    }
  }

  /// 获取提醒设置
  List<Map<String, dynamic>> getReminders() {
    try {
      final jsonString = _prefs!.getString(AppConstants.KEY_REMINDERS);
      if (jsonString == null) return [];

      final List<dynamic> list = jsonDecode(jsonString);
      return list.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error loading reminders: $e');
      return [];
    }
  }

  // ==================== 餐食历史 ====================

  /// 保存餐食历史
  Future<bool> saveMealHistory(List<Map<String, dynamic>> meals) async {
    try {
      final jsonString = jsonEncode(meals);
      return await _prefs!.setString(AppConstants.KEY_MEAL_HISTORY, jsonString);
    } catch (e) {
      print('Error saving meal history: $e');
      return false;
    }
  }

  /// 获取餐食历史
  List<Map<String, dynamic>> getMealHistory() {
    try {
      final jsonString = _prefs!.getString(AppConstants.KEY_MEAL_HISTORY);
      if (jsonString == null) return [];

      final List<dynamic> list = jsonDecode(jsonString);
      return list.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error loading meal history: $e');
      return [];
    }
  }

  // ==================== 首次启动标记 ====================

  /// 保存是否首次启动
  Future<bool> setFirstLaunch(bool isFirst) async {
    return await _prefs!.setBool('first_launch', isFirst);
  }

  /// 获取是否首次启动
  bool isFirstLaunch() {
    return _prefs!.getBool('first_launch') ?? true;
  }

  // ==================== 通用方法 ====================

  /// 保存字符串
  Future<bool> setString(String key, String value) async {
    return await _prefs!.setString(key, value);
  }

  /// 获取字符串
  String? getString(String key) {
    return _prefs!.getString(key);
  }

  /// 保存整数
  Future<bool> setInt(String key, int value) async {
    return await _prefs!.setInt(key, value);
  }

  /// 获取整数
  int? getInt(String key) {
    return _prefs!.getInt(key);
  }

  /// 保存布尔值
  Future<bool> setBool(String key, bool value) async {
    return await _prefs!.setBool(key, value);
  }

  /// 获取布尔值
  bool? getBool(String key) {
    return _prefs!.getBool(key);
  }

  /// 保存双精度浮点数
  Future<bool> setDouble(String key, double value) async {
    return await _prefs!.setDouble(key, value);
  }

  /// 获取双精度浮点数
  double? getDouble(String key) {
    return _prefs!.getDouble(key);
  }

  /// 删除指定key
  Future<bool> remove(String key) async {
    return await _prefs!.remove(key);
  }

  /// 清空所有数据
  Future<bool> clear() async {
    return await _prefs!.clear();
  }

  /// 检查key是否存在
  bool containsKey(String key) {
    return _prefs!.containsKey(key);
  }

  /// 获取所有keys
  Set<String> getKeys() {
    return _prefs!.getKeys();
  }
}