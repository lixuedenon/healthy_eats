// lib/presentation/viewmodels/user_viewmodel.dart
// Dart类文件

import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';

/// 用户ViewModel
///
/// 管理用户信息的业务逻辑和状态
class UserViewModel extends ChangeNotifier {
  final UserRepository _userRepository;

  UserViewModel(this._userRepository);

  // ==================== 状态 ====================

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  UserProfile? _currentUser;
  UserProfile? get currentUser => _currentUser;

  // ==================== 初始化 ====================

  /// 初始化用户数据
  Future<void> initialize() async {
    await loadUser();
  }

  /// 加载用户信息
  Future<void> loadUser() async {
    try {
      _setLoading(true);
      _currentUser = await _userRepository.getUser();

      if (_currentUser == null) {
        _currentUser = await _userRepository.createDefaultUser();
      }

      _setLoading(false);
    } catch (e) {
      _setError('加载用户信息失败: $e');
      _setLoading(false);
    }
  }

  // ==================== 基础信息更新 ====================

  /// 更新基础信息
  Future<bool> updateBasicInfo({
    String? name,
    String? city,
    int? age,
    double? height,
    double? weight,
    String? gender,
  }) async {
    try {
      _setLoading(true);

      final success = await _userRepository.updateBasicInfo(
        name: name,
        city: city,
        age: age,
        height: height,
        weight: weight,
        gender: gender,
      );

      if (success) {
        await loadUser();
      }

      _setLoading(false);
      return success;
    } catch (e) {
      _setError('更新基础信息失败: $e');
      _setLoading(false);
      return false;
    }
  }

  /// 更新健康目标
  Future<bool> updateHealthGoal(String healthGoal) async {
    try {
      final success = await _userRepository.updateHealthGoal(healthGoal);

      if (success) {
        await loadUser();
      }

      return success;
    } catch (e) {
      _setError('更新健康目标失败: $e');
      return false;
    }
  }

  // ==================== 餐食偏好更新 ====================

  /// 更新默认餐食来源
  Future<bool> updateDefaultMealSource(int mealSource) async {
    try {
      final success = await _userRepository.updateDefaultMealSource(mealSource);

      if (success) {
        await loadUser();
      }

      return success;
    } catch (e) {
      _setError('更新餐食来源失败: $e');
      return false;
    }
  }

  /// 更新默认就餐方式
  Future<bool> updateDefaultDiningStyle(String diningStyle) async {
    try {
      final success = await _userRepository.updateDefaultDiningStyle(diningStyle);

      if (success) {
        await loadUser();
      }

      return success;
    } catch (e) {
      _setError('更新就餐方式失败: $e');
      return false;
    }
  }

  /// 更新菜系偏好
  Future<bool> updatePreferredCuisines(List<String> cuisines) async {
    try {
      final success = await _userRepository.updatePreferredCuisines(cuisines);

      if (success) {
        await loadUser();
      }

      return success;
    } catch (e) {
      _setError('更新菜系偏好失败: $e');
      return false;
    }
  }

  /// 更新零食偏好
  Future<bool> updateSnackFrequency(String frequency) async {
    try {
      final success = await _userRepository.updateSnackFrequency(frequency);

      if (success) {
        await loadUser();
      }

      return success;
    } catch (e) {
      _setError('更新零食偏好失败: $e');
      return false;
    }
  }

  // ==================== 忌口管理 ====================

  /// 更新忌口蔬菜
  Future<bool> updateAvoidVegetables(List<String> vegetables) async {
    try {
      final success = await _userRepository.updateAvoidVegetables(vegetables);

      if (success) {
        await loadUser();
      }

      return success;
    } catch (e) {
      _setError('更新忌口蔬菜失败: $e');
      return false;
    }
  }

  /// 更新忌口水果
  Future<bool> updateAvoidFruits(List<String> fruits) async {
    try {
      final success = await _userRepository.updateAvoidFruits(fruits);

      if (success) {
        await loadUser();
      }

      return success;
    } catch (e) {
      _setError('更新忌口水果失败: $e');
      return false;
    }
  }

  /// 更新忌口肉类
  Future<bool> updateAvoidMeats(List<String> meats) async {
    try {
      final success = await _userRepository.updateAvoidMeats(meats);

      if (success) {
        await loadUser();
      }

      return success;
    } catch (e) {
      _setError('更新忌口肉类失败: $e');
      return false;
    }
  }

  /// 更新忌口海鲜
  Future<bool> updateAvoidSeafood(List<String> seafood) async {
    try {
      final success = await _userRepository.updateAvoidSeafood(seafood);

      if (success) {
        await loadUser();
      }

      return success;
    } catch (e) {
      _setError('更新忌口海鲜失败: $e');
      return false;
    }
  }

  // ==================== 特殊饮食 ====================

  /// 更新素食者状态
  Future<bool> updateVegetarianStatus(bool isVegetarian) async {
    try {
      final success = await _userRepository.updateVegetarianStatus(isVegetarian);

      if (success) {
        await loadUser();
      }

      return success;
    } catch (e) {
      _setError('更新素食者状态失败: $e');
      return false;
    }
  }

  /// 更新血糖偏高状态
  Future<bool> updateHighBloodSugarStatus(bool hasHighBloodSugar) async {
    try {
      final success = await _userRepository.updateHighBloodSugarStatus(hasHighBloodSugar);

      if (success) {
        await loadUser();
      }

      return success;
    } catch (e) {
      _setError('更新血糖状态失败: $e');
      return false;
    }
  }

  // ==================== VIP状态 ====================

  /// 更新VIP状态
  Future<bool> updateVIPStatus(bool isVIP, {DateTime? expiryDate}) async {
    try {
      final success = await _userRepository.updateVIPStatus(
        isVIP,
        expiryDate: expiryDate,
      );

      if (success) {
        await loadUser();
      }

      return success;
    } catch (e) {
      _setError('更新VIP状态失败: $e');
      return false;
    }
  }

  /// 检查VIP是否有效
  Future<bool> checkVIPStatus() async {
    return await _userRepository.isVIPValid();
  }

  // ==================== 提醒设置 ====================

  /// 更新提醒设置
  Future<bool> updateReminderSettings({
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
  }) async {
    try {
      final success = await _userRepository.updateReminderSettings(
        enableBreakfastReminder: enableBreakfastReminder,
        breakfastTime: breakfastTime,
        enableLunchReminder: enableLunchReminder,
        lunchTime: lunchTime,
        enableDinnerReminder: enableDinnerReminder,
        dinnerTime: dinnerTime,
        enableWaterReminder: enableWaterReminder,
        waterReminderInterval: waterReminderInterval,
        enableRestReminder: enableRestReminder,
        restTime: restTime,
        enableWeatherReminder: enableWeatherReminder,
      );

      if (success) {
        await loadUser();
      }

      return success;
    } catch (e) {
      _setError('更新提醒设置失败: $e');
      return false;
    }
  }

  // ==================== 语言设置 ====================

  /// 更新语言设置
  Future<bool> updateLanguage(String language) async {
    try {
      final success = await _userRepository.updateLanguage(language);

      if (success) {
        await loadUser();
      }

      return success;
    } catch (e) {
      _setError('更新语言设置失败: $e');
      return false;
    }
  }

  // ==================== 辅助方法 ====================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();

    // 3秒后清除错误消息
    Future.delayed(const Duration(seconds: 3), () {
      _errorMessage = null;
      notifyListeners();
    });
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ==================== 用户信息验证 ====================

  /// 检查是否需要完善个人信息
  bool needsProfileCompletion() {
    if (_currentUser == null) return true;

    return _currentUser!.name == '用户' ||
           _currentUser!.age == null ||
           _currentUser!.height == null ||
           _currentUser!.weight == null;
  }

  /// 获取个人信息完成度（百分比）
  int getProfileCompletionPercentage() {
    if (_currentUser == null) return 0;

    int completed = 0;
    int total = 10;

    if (_currentUser!.name != '用户') completed++;
    if (_currentUser!.city != null) completed++;
    if (_currentUser!.age != null) completed++;
    if (_currentUser!.height != null) completed++;
    if (_currentUser!.weight != null) completed++;
    if (_currentUser!.gender != null) completed++;
    if (_currentUser!.preferredCuisines.isNotEmpty) completed++;
    if (_currentUser!.avoidVegetables.isNotEmpty ||
        _currentUser!.avoidFruits.isNotEmpty ||
        _currentUser!.avoidMeats.isNotEmpty ||
        _currentUser!.avoidSeafood.isNotEmpty) completed++;
    if (_currentUser!.defaultMealSource > 0) completed++;
    if (_currentUser!.defaultDiningStyle.isNotEmpty) completed++;

    return ((completed / total) * 100).round();
  }
}