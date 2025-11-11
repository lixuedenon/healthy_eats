// lib/data/repositories/meal_repository.dart
// Dart类文件

import '../models/meal_model.dart';
import '../../core/services/storage_service.dart';

/// 餐食数据仓库
///
/// 管理餐食记录的存储和获取
class MealRepository {
  final StorageService _storageService;

  // 内存缓存
  List<Meal>? _cachedMeals;

  MealRepository(this._storageService);

  // ==================== 餐食CRUD ====================

  /// 保存餐食记录
  Future<bool> saveMeal(Meal meal) async {
    try {
      final meals = await getAllMeals();
      meals.add(meal);

      final mealsJson = meals.map((m) => m.toJson()).toList();
      final success = await _storageService.saveMealHistory(mealsJson);

      if (success) {
        _cachedMeals = meals; // 更新缓存
      }

      return success;
    } catch (e) {
      print('Error saving meal: $e');
      return false;
    }
  }

  /// 获取所有餐食记录
  Future<List<Meal>> getAllMeals() async {
    if (_cachedMeals != null) {
      return _cachedMeals!;
    }

    try {
      final mealsJson = _storageService.getMealHistory();
      final meals = mealsJson.map((json) => Meal.fromJson(json)).toList();

      // 按时间倒序排列
      meals.sort((a, b) => b.dateTime.compareTo(a.dateTime));

      _cachedMeals = meals;
      return meals;
    } catch (e) {
      print('Error loading meals: $e');
      return [];
    }
  }

  /// 根据ID获取餐食
  Future<Meal?> getMealById(String id) async {
    final meals = await getAllMeals();
    try {
      return meals.firstWhere((meal) => meal.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 更新餐食记录
  Future<bool> updateMeal(Meal meal) async {
    try {
      final meals = await getAllMeals();
      final index = meals.indexWhere((m) => m.id == meal.id);

      if (index == -1) return false;

      meals[index] = meal;

      final mealsJson = meals.map((m) => m.toJson()).toList();
      final success = await _storageService.saveMealHistory(mealsJson);

      if (success) {
        _cachedMeals = meals;
      }

      return success;
    } catch (e) {
      print('Error updating meal: $e');
      return false;
    }
  }

  /// 删除餐食记录
  Future<bool> deleteMeal(String id) async {
    try {
      final meals = await getAllMeals();
      meals.removeWhere((meal) => meal.id == id);

      final mealsJson = meals.map((m) => m.toJson()).toList();
      final success = await _storageService.saveMealHistory(mealsJson);

      if (success) {
        _cachedMeals = meals;
      }

      return success;
    } catch (e) {
      print('Error deleting meal: $e');
      return false;
    }
  }

  /// 清空所有餐食记录
  Future<bool> clearAllMeals() async {
    try {
      final success = await _storageService.saveMealHistory([]);
      if (success) {
        _cachedMeals = [];
      }
      return success;
    } catch (e) {
      print('Error clearing meals: $e');
      return false;
    }
  }

  // ==================== 按日期查询 ====================

  /// 获取某一天的所有餐食
  Future<List<Meal>> getMealsByDate(DateTime date) async {
    final meals = await getAllMeals();

    return meals.where((meal) {
      return meal.dateTime.year == date.year &&
             meal.dateTime.month == date.month &&
             meal.dateTime.day == date.day;
    }).toList();
  }

  /// 获取今天的所有餐食
  Future<List<Meal>> getTodayMeals() async {
    return await getMealsByDate(DateTime.now());
  }

  /// 获取本周的所有餐食
  Future<List<Meal>> getWeekMeals() async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    return await getMealsInRange(weekStart, weekEnd);
  }

  /// 获取指定日期范围的餐食
  Future<List<Meal>> getMealsInRange(DateTime start, DateTime end) async {
    final meals = await getAllMeals();

    return meals.where((meal) {
      return meal.dateTime.isAfter(start.subtract(const Duration(days: 1))) &&
             meal.dateTime.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  // ==================== 按餐次查询 ====================

  /// 获取指定餐次的所有记录
  Future<List<Meal>> getMealsByType(String mealType) async {
    final meals = await getAllMeals();
    return meals.where((meal) => meal.mealType == mealType).toList();
  }

  /// 获取今天的早餐
  Future<Meal?> getTodayBreakfast() async {
    final todayMeals = await getTodayMeals();
    try {
      return todayMeals.firstWhere((meal) => meal.mealType == '早餐');
    } catch (e) {
      return null;
    }
  }

  /// 获取今天的午餐
  Future<Meal?> getTodayLunch() async {
    final todayMeals = await getTodayMeals();
    try {
      return todayMeals.firstWhere((meal) => meal.mealType == '午餐');
    } catch (e) {
      return null;
    }
  }

  /// 获取今天的晚餐
  Future<Meal?> getTodayDinner() async {
    final todayMeals = await getTodayMeals();
    try {
      return todayMeals.firstWhere((meal) => meal.mealType == '晚餐');
    } catch (e) {
      return null;
    }
  }

  // ==================== 完成状态 ====================

  /// 标记餐食为已完成
  Future<bool> markMealAsCompleted(String id) async {
    final meal = await getMealById(id);
    if (meal == null) return false;

    final updatedMeal = meal.copyWith(
      isCompleted: true,
      completedAt: DateTime.now(),
    );

    return await updateMeal(updatedMeal);
  }

  /// 取消完成标记
  Future<bool> unmarkMealAsCompleted(String id) async {
    final meal = await getMealById(id);
    if (meal == null) return false;

    final updatedMeal = meal.copyWith(
      isCompleted: false,
      completedAt: null,
    );

    return await updateMeal(updatedMeal);
  }

  /// 获取已完成的餐食
  Future<List<Meal>> getCompletedMeals() async {
    final meals = await getAllMeals();
    return meals.where((meal) => meal.isCompleted).toList();
  }

  /// 获取未完成的餐食
  Future<List<Meal>> getIncompleteMeals() async {
    final meals = await getAllMeals();
    return meals.where((meal) => !meal.isCompleted).toList();
  }

  // ==================== 统计分析 ====================

  /// 获取总餐食数量
  Future<int> getTotalMealCount() async {
    final meals = await getAllMeals();
    return meals.length;
  }

  /// 获取某段时间的餐食数量
  Future<int> getMealCountInRange(DateTime start, DateTime end) async {
    final meals = await getMealsInRange(start, end);
    return meals.length;
  }

  /// 获取本周打卡天数
  Future<int> getWeekCheckInDays() async {
    final weekMeals = await getWeekMeals();

    // 按日期分组
    final daysWithMeals = <String>{};
    for (var meal in weekMeals) {
      final dateKey = '${meal.dateTime.year}-${meal.dateTime.month}-${meal.dateTime.day}';
      daysWithMeals.add(dateKey);
    }

    return daysWithMeals.length;
  }

  // ==================== 缓存管理 ====================

  /// 刷新缓存
  Future<void> refreshCache() async {
    _cachedMeals = null;
    await getAllMeals();
  }

  /// 清除缓存
  void clearCache() {
    _cachedMeals = null;
  }
}