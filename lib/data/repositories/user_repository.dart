// lib/data/repositories/user_repository.dart
// Dart类文件

import '../models/user_model.dart';
import '../../core/services/storage_service.dart';

/// 用户数据仓库
///
/// 管理用户信息的存储和获取
class UserRepository {
  final StorageService _storageService;

  UserRepository(this._storageService);

  // ==================== 用户信息 ====================

  /// 保存用户信息
  Future<bool> saveUser(UserProfile user) async {
    return await _storageService.saveUserProfile(user);
  }

  /// 获取用户信息
  Future<UserProfile?> getUser() async {
    return await _storageService.getUserProfile();
  }

  /// 更新用户信息
  Future<bool> updateUser(UserProfile user) async {
    final updatedUser = user.copyWith(
      updatedAt: DateTime.now(),
    );
    return await _storageService.saveUserProfile(updatedUser);
  }

  /// 删除用户信息
  Future<bool> deleteUser() async {
    return await _storageService.deleteUserProfile();
  }

  /// 检查用户是否存在
  Future<bool> userExists() async {
    final user = await getUser();
    return user != null;
  }

  // ==================== VIP状态 ====================

  /// 更新VIP状态
  Future<bool> updateVIPStatus(bool isVIP, {DateTime? expiryDate}) async {
    final user = await getUser();
    if (user == null) return false;

    final updatedUser = user.copyWith(
      isVIP: isVIP,
      vipExpiryDate: expiryDate,
      updatedAt: DateTime.now(),
    );

    return await saveUser(updatedUser);
  }

  /// 检查VIP是否有效
  Future<bool> isVIPValid() async {
    final user = await getUser();
    if (user == null) return false;

    return user.isVIPValid;
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
    final user = await getUser();
    if (user == null) return false;

    final updatedUser = user.copyWith(
      name: name,
      city: city,
      age: age,
      height: height,
      weight: weight,
      gender: gender,
      updatedAt: DateTime.now(),
    );

    return await saveUser(updatedUser);
  }

  /// 更新健康目标
  Future<bool> updateHealthGoal(String healthGoal) async {
    final user = await getUser();
    if (user == null) return false;

    final updatedUser = user.copyWith(
      healthGoal: healthGoal,
      updatedAt: DateTime.now(),
    );

    return await saveUser(updatedUser);
  }

  // ==================== 餐食偏好更新 ====================

  /// 更新默认餐食来源
  Future<bool> updateDefaultMealSource(int mealSource) async {
    final user = await getUser();
    if (user == null) return false;

    final updatedUser = user.copyWith(
      defaultMealSource: mealSource,
      updatedAt: DateTime.now(),
    );

    return await saveUser(updatedUser);
  }

  /// 更新默认就餐方式
  Future<bool> updateDefaultDiningStyle(String diningStyle) async {
    final user = await getUser();
    if (user == null) return false;

    final updatedUser = user.copyWith(
      defaultDiningStyle: diningStyle,
      updatedAt: DateTime.now(),
    );

    return await saveUser(updatedUser);
  }

  /// 更新菜系偏好
  Future<bool> updatePreferredCuisines(List<String> cuisines) async {
    final user = await getUser();
    if (user == null) return false;

    final updatedUser = user.copyWith(
      preferredCuisines: cuisines,
      updatedAt: DateTime.now(),
    );

    return await saveUser(updatedUser);
  }

  /// 更新零食偏好
  Future<bool> updateSnackFrequency(String frequency) async {
    final user = await getUser();
    if (user == null) return false;

    final updatedUser = user.copyWith(
      snackFrequency: frequency,
      updatedAt: DateTime.now(),
    );

    return await saveUser(updatedUser);
  }

  // ==================== 忌口管理 ====================

  /// 更新忌口蔬菜
  Future<bool> updateAvoidVegetables(List<String> vegetables) async {
    final user = await getUser();
    if (user == null) return false;

    final updatedUser = user.copyWith(
      avoidVegetables: vegetables,
      updatedAt: DateTime.now(),
    );

    return await saveUser(updatedUser);
  }

  /// 更新忌口水果
  Future<bool> updateAvoidFruits(List<String> fruits) async {
    final user = await getUser();
    if (user == null) return false;

    final updatedUser = user.copyWith(
      avoidFruits: fruits,
      updatedAt: DateTime.now(),
    );

    return await saveUser(updatedUser);
  }

  /// 更新忌口肉类
  Future<bool> updateAvoidMeats(List<String> meats) async {
    final user = await getUser();
    if (user == null) return false;

    final updatedUser = user.copyWith(
      avoidMeats: meats,
      updatedAt: DateTime.now(),
    );

    return await saveUser(updatedUser);
  }

  /// 更新忌口海鲜
  Future<bool> updateAvoidSeafood(List<String> seafood) async {
    final user = await getUser();
    if (user == null) return false;

    final updatedUser = user.copyWith(
      avoidSeafood: seafood,
      updatedAt: DateTime.now(),
    );

    return await saveUser(updatedUser);
  }

  // ==================== 特殊饮食 ====================

  /// 更新素食者状态
  Future<bool> updateVegetarianStatus(bool isVegetarian) async {
    final user = await getUser();
    if (user == null) return false;

    final updatedUser = user.copyWith(
      isVegetarian: isVegetarian,
      updatedAt: DateTime.now(),
    );

    return await saveUser(updatedUser);
  }

  /// 更新血糖偏高状态
  Future<bool> updateHighBloodSugarStatus(bool hasHighBloodSugar) async {
    final user = await getUser();
    if (user == null) return false;

    final updatedUser = user.copyWith(
      hasHighBloodSugar: hasHighBloodSugar,
      updatedAt: DateTime.now(),
    );

    return await saveUser(updatedUser);
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
    final user = await getUser();
    if (user == null) return false;

    final updatedUser = user.copyWith(
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
      updatedAt: DateTime.now(),
    );

    return await saveUser(updatedUser);
  }

  // ==================== 语言设置 ====================

  /// 更新语言设置
  Future<bool> updateLanguage(String language) async {
    final user = await getUser();
    if (user == null) return false;

    final updatedUser = user.copyWith(
      language: language,
      updatedAt: DateTime.now(),
    );

    return await saveUser(updatedUser);
  }

  // ==================== 创建默认用户 ====================

  /// 创建默认用户（首次使用）
  Future<UserProfile> createDefaultUser() async {
    final user = UserProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '用户',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await saveUser(user);
    return user;
  }
}