// lib/presentation/viewmodels/user_viewmodel.dart
// Dart类文件

import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';

class UserViewModel extends ChangeNotifier {
  final UserRepository _userRepository;

  UserViewModel(this._userRepository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  UserProfile? _currentUser;
  UserProfile? get currentUser => _currentUser;

  Future<void> initialize() async {
    await loadUser();
  }

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

  Future<bool> updateHealthConditions(List<String> conditions) async {
    try {
      final success = await _userRepository.updateHealthConditions(conditions);

      if (success) {
        await loadUser();
      }

      return success;
    } catch (e) {
      _setError('更新健康状况失败: $e');
      return false;
    }
  }

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

  Future<bool> checkVIPStatus() async {
    return await _userRepository.isVIPValid();
  }

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

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();

    Future.delayed(const Duration(seconds: 3), () {
      _errorMessage = null;
      notifyListeners();
    });
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  bool needsProfileCompletion() {
    if (_currentUser == null) return true;

    return _currentUser!.name == '用户' ||
           _currentUser!.age == null ||
           _currentUser!.height == null ||
           _currentUser!.weight == null;
  }

  bool hasFilledAnyInfo() {
    if (_currentUser == null) return false;

    return _currentUser!.name != '用户' ||
           _currentUser!.age != null ||
           _currentUser!.height != null ||
           _currentUser!.weight != null ||
           _currentUser!.gender != null ||
           (_currentUser!.city != null && _currentUser!.city!.isNotEmpty) ||
           _currentUser!.preferredCuisines.isNotEmpty ||
           _currentUser!.avoidVegetables.isNotEmpty ||
           _currentUser!.avoidFruits.isNotEmpty ||
           _currentUser!.avoidMeats.isNotEmpty ||
           _currentUser!.avoidSeafood.isNotEmpty ||
           _currentUser!.healthConditions.any((c) => c != '无') ||
           _currentUser!.defaultMealSource != 3;
  }

  bool isFieldIncomplete(String fieldName) {
    if (_currentUser == null) return true;

    switch (fieldName) {
      case 'basicInfo':
        return _currentUser!.age == null ||
               _currentUser!.height == null ||
               _currentUser!.weight == null ||
               _currentUser!.gender == null ||
               _currentUser!.city == null ||
               _currentUser!.city!.isEmpty;
      case 'healthGoal':
        return _currentUser!.healthGoal == '维持';
      case 'mealSource':
        return _currentUser!.defaultMealSource == 3;
      case 'diningStyle':
        return _currentUser!.defaultDiningStyle == '主要自己吃';
      case 'cuisines':
        return _currentUser!.preferredCuisines.isEmpty ||
               (_currentUser!.preferredCuisines.length == 1 &&
                _currentUser!.preferredCuisines.first == '中餐');
      case 'snack':
        return _currentUser!.snackFrequency == '很少吃';
      case 'avoidance':
        return _currentUser!.avoidVegetables.isEmpty &&
               _currentUser!.avoidFruits.isEmpty &&
               _currentUser!.avoidMeats.isEmpty &&
               _currentUser!.avoidSeafood.isEmpty;
      case 'healthConditions':
        return _currentUser!.healthConditions.isEmpty ||
               (_currentUser!.healthConditions.length == 1 &&
                _currentUser!.healthConditions.first == '无');
      default:
        return false;
    }
  }

  int getProfileCompletionPercentage() {
    if (_currentUser == null) return 0;

    int completed = 0;
    int total = 11;

    if (_currentUser!.name != '用户') completed++;
    if (_currentUser!.city != null && _currentUser!.city!.isNotEmpty) completed++;
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
    if (_currentUser!.healthConditions.any((c) => c != '无')) completed++;

    return ((completed / total) * 100).round();
  }
}