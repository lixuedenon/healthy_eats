// lib/presentation/viewmodels/home_viewmodel.dart
// Dart类文件

import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/models/meal_model.dart';
import '../../data/models/lqi_model.dart';
import '../../data/models/recommended_meal_model.dart';
import '../../data/models/food_item_model.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/meal_repository.dart';
import '../../domain/ai_engine/calculators/lqi_calculator.dart';
import '../../domain/ai_engine/calculators/nutrition_calculator.dart';
import '../../core/services/ai_recommendation_service.dart';

/// 首页ViewModel
///
/// 管理首页的业务逻辑和状态
class HomeViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final MealRepository _mealRepository;
  AIRecommendationService? _aiService;

  HomeViewModel(this._userRepository, this._mealRepository);

  // ==================== 状态 ====================

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  UserProfile? _currentUser;
  UserProfile? get currentUser => _currentUser;

  List<Meal> _todayMeals = [];
  List<Meal> get todayMeals => _todayMeals;

  LQI? _todayLQI;
  LQI? get todayLQI => _todayLQI;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  // ==================== 推荐相关状态 ====================

  DualRecommendation? _dualRecommendation;
  String _selectedModel = 'gpt-4'; // 当前选择的模型
  String get selectedModel => _selectedModel;

  List<RecommendedMeal> _currentRecommendations = [];
  List<RecommendedMeal> get currentRecommendations => _currentRecommendations;

  bool _isLoadingRecommendations = false;
  bool get isLoadingRecommendations => _isLoadingRecommendations;

  // ==================== 初始化 ====================

  /// 初始化数据
  Future<void> initialize() async {
    await _loadUserProfile();
    await _loadTodayMeals();
    await _calculateTodayLQI();
  }

  /// 设置AI服务
  void setAIService(AIRecommendationService service) {
    _aiService = service;
  }

  /// 加载用户信息
  Future<void> _loadUserProfile() async {
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

  /// 加载今天的餐食
  Future<void> _loadTodayMeals() async {
    try {
      _todayMeals = await _mealRepository.getTodayMeals();
      notifyListeners();
    } catch (e) {
      _setError('加载餐食记录失败: $e');
    }
  }

  /// 计算今天的LQI
  Future<void> _calculateTodayLQI() async {
    if (_currentUser == null || _todayMeals.isEmpty) {
      _todayLQI = null;
      notifyListeners();
      return;
    }

    try {
      _todayLQI = LQICalculator.calculateDaily(
        meals: _todayMeals,
        targetCalories: _getTargetCalories(),
        targetProtein: _getTargetProtein(),
        targetCarbs: _getTargetCarbs(),
        targetFat: _getTargetFat(),
      );
      notifyListeners();
    } catch (e) {
      _setError('计算LQI失败: $e');
    }
  }

  // ==================== AI推荐功能 ====================

  /// 加载推荐餐食
  Future<void> loadRecommendations() async {
    if (_aiService == null) {
      _setError('AI服务未初始化');
      return;
    }

    try {
      _isLoadingRecommendations = true;
      notifyListeners();

      _dualRecommendation = await _aiService!.getDualRecommendations(
        user: _currentUser,
      );

      // 默认显示GPT-4的推荐
      _currentRecommendations = _dualRecommendation!.gpt4Results;

      _isLoadingRecommendations = false;
      notifyListeners();
    } catch (e) {
      _setError('加载推荐失败: $e');
      _isLoadingRecommendations = false;
      notifyListeners();
    }
  }

  /// 切换模型
  void switchModel(String model) {
    if (_dualRecommendation == null) return;

    _selectedModel = model;
    _currentRecommendations = _dualRecommendation!.getResults(model);
    notifyListeners();
  }

  /// 刷新推荐（换一套）
  Future<void> refreshRecommendations() async {
    await loadRecommendations();
  }

  /// 采用推荐
  Future<bool> adoptRecommendation(RecommendedMeal recommendation) async {
    try {
      // 转换为Meal对象
      final meal = _convertRecommendationToMeal(recommendation);

      // 保存餐食
      final success = await addMeal(meal);

      if (success) {
        // 标记推荐为已采用
        final index = _currentRecommendations.indexWhere((r) => r.id == recommendation.id);
        if (index != -1) {
          _currentRecommendations[index] = recommendation.copyWith(isAdopted: true);
          notifyListeners();
        }
      }

      return success;
    } catch (e) {
      _setError('采用推荐失败: $e');
      return false;
    }
  }

  /// 将推荐转换为餐食
  Meal _convertRecommendationToMeal(RecommendedMeal recommendation) {
    // 创建食物项列表
    final foodItems = recommendation.ingredients.map((ingredient) {
      return FoodItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: ingredient,
        amount: 1,
        unit: '份',
        nutrition: recommendation.nutrition,
      );
    }).toList();

    return Meal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      mealType: recommendation.mealType,
      name: recommendation.name,
      description: recommendation.description,
      dateTime: DateTime.now(),
      foodItems: foodItems,
      nutrition: recommendation.nutrition,
      emotionROI: recommendation.estimatedROI,
      source: '推荐',
      cookingTime: recommendation.cookingTime,
    );
  }

  /// 检查用户信息是否完整
  bool isUserProfileComplete() {
    if (_currentUser == null) return false;
    return _currentUser!.age != null &&
        _currentUser!.healthGoal.isNotEmpty &&
        _currentUser!.preferredCuisines.isNotEmpty;
  }

  // ==================== 餐食操作 ====================

  /// 添加餐食
  Future<bool> addMeal(Meal meal) async {
    try {
      _setLoading(true);
      final success = await _mealRepository.saveMeal(meal);

      if (success) {
        await _loadTodayMeals();
        await _calculateTodayLQI();
      }

      _setLoading(false);
      return success;
    } catch (e) {
      _setError('添加餐食失败: $e');
      _setLoading(false);
      return false;
    }
  }

  /// 删除餐食
  Future<bool> deleteMeal(String mealId) async {
    try {
      _setLoading(true);
      final success = await _mealRepository.deleteMeal(mealId);

      if (success) {
        await _loadTodayMeals();
        await _calculateTodayLQI();
      }

      _setLoading(false);
      return success;
    } catch (e) {
      _setError('删除餐食失败: $e');
      _setLoading(false);
      return false;
    }
  }

  /// 标记餐食为已完成
  Future<bool> completeMeal(String mealId) async {
    try {
      final success = await _mealRepository.markMealAsCompleted(mealId);

      if (success) {
        await _loadTodayMeals();
      }

      return success;
    } catch (e) {
      _setError('标记完成失败: $e');
      return false;
    }
  }

  // ==================== 日期选择 ====================

  /// 选择日期
  Future<void> selectDate(DateTime date) async {
    _selectedDate = date;

    // 如果选择的是今天，加载今天的餐食
    if (_isToday(date)) {
      await _loadTodayMeals();
      await _calculateTodayLQI();
    } else {
      // 否则加载指定日期的餐食
      _todayMeals = await _mealRepository.getMealsByDate(date);

      if (_currentUser != null && _todayMeals.isNotEmpty) {
        _todayLQI = LQICalculator.calculateDaily(
          meals: _todayMeals,
          targetCalories: _getTargetCalories(),
          targetProtein: _getTargetProtein(),
          targetCarbs: _getTargetCarbs(),
          targetFat: _getTargetFat(),
        );
      } else {
        _todayLQI = null;
      }
    }

    notifyListeners();
  }

  /// 判断是否是今天
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }

  // ==================== 刷新 ====================

  /// 刷新所有数据
  Future<void> refresh() async {
    await initialize();
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

  // ==================== 营养目标计算 ====================

  int _getTargetCalories() {
    if (_currentUser == null) return 2000;

    const targets = {
      '减脂': 1800,
      '增肌': 2500,
      '维持': 2000,
      '随意': 2000,
    };
    return targets[_currentUser!.healthGoal] ?? 2000;
  }

  int _getTargetProtein() {
    if (_currentUser == null) return 100;

    const targets = {
      '减脂': 120,
      '增肌': 150,
      '维持': 100,
      '随意': 100,
    };
    return targets[_currentUser!.healthGoal] ?? 100;
  }

  int _getTargetCarbs() {
    if (_currentUser == null) return 250;

    const targets = {
      '减脂': 180,
      '增肌': 300,
      '维持': 250,
      '随意': 250,
    };
    return targets[_currentUser!.healthGoal] ?? 250;
  }

  int _getTargetFat() {
    if (_currentUser == null) return 70;

    const targets = {
      '减脂': 50,
      '增肌': 80,
      '维持': 70,
      '随意': 70,
    };
    return targets[_currentUser!.healthGoal] ?? 70;
  }

  // ==================== 统计数据 ====================

  /// 获取今日完成的餐次数量
  int getTodayCompletedMealCount() {
    return _todayMeals.where((meal) => meal.isCompleted).length;
  }

  /// 获取今日总餐次数量
  int getTodayTotalMealCount() {
    return _todayMeals.length;
  }

  /// 获取今日完成率
  double getTodayCompletionRate() {
    if (_todayMeals.isEmpty) return 0.0;
    return getTodayCompletedMealCount() / getTodayTotalMealCount();
  }

  /// 检查是否有某个餐次
  bool hasMealType(String mealType) {
    return _todayMeals.any((meal) => meal.mealType == mealType);
  }

  /// 获取指定餐次
  Meal? getMealByType(String mealType) {
    try {
      return _todayMeals.firstWhere((meal) => meal.mealType == mealType);
    } catch (e) {
      return null;
    }
  }
}