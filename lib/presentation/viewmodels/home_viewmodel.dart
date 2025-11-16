// lib/presentation/viewmodels/home_viewmodel.dart
// Dart类文件

import 'dart:convert';
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
import '../../core/services/storage_service.dart';

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

  // ==================== 推荐相关状态（5套方案）====================

  List<List<RecommendedMeal>> _allRecommendationSets = []; // 最多5套推荐
  int _currentSetIndex = 0; // 当前显示第几套（0-4）

  List<RecommendedMeal> get currentRecommendations {
    if (_allRecommendationSets.isEmpty) return [];
    return _allRecommendationSets[_currentSetIndex];
  }

  int get currentSetNumber => _currentSetIndex + 1; // 1-5
  int get totalSets => _allRecommendationSets.length; // 当前已加载的套数
  int get currentSetIndex => _currentSetIndex; // 当前索引
  bool get hasRecommendations => _allRecommendationSets.isNotEmpty;

  bool _isLoadingRecommendations = false;
  bool get isLoadingRecommendations => _isLoadingRecommendations;

  // ⭐ 分批加载状态
  bool _isLoadingMoreSets = false; // 是否正在后台加载更多套餐
  bool get isLoadingMoreSets => _isLoadingMoreSets;

  // ==================== 初始化 ====================

  /// 初始化数据
  Future<void> initialize() async {
    await _loadUserProfile();
    await _loadTodayMeals();
    await _calculateTodayLQI();

    // ⭐ 从缓存加载推荐
    await _loadRecommendationsFromCache();

    // ⭐ 如果没有推荐，使用分批加载策略
    if (!hasRecommendations) {
      _loadRecommendationsWithBatching();
    }
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

  // ==================== AI推荐功能（分批加载）====================

  /// 从缓存加载推荐
  Future<void> _loadRecommendationsFromCache() async {
    try {
      final storageService = await StorageService.getInstance();
      final cachedData = storageService.getString('cached_recommendations');

      if (cachedData != null) {
        // 解析缓存的推荐
        final List<dynamic> setsJson = jsonDecode(cachedData);
        _allRecommendationSets = setsJson.map<List<RecommendedMeal>>((setJson) {
          return (setJson as List<dynamic>)
              .map<RecommendedMeal>((mealJson) => RecommendedMeal.fromJson(mealJson))
              .toList();
        }).toList();

        _currentSetIndex = 0;
        notifyListeners();

        print('✅ 从缓存加载了 ${_allRecommendationSets.length} 套推荐');
      }
    } catch (e) {
      print('❌ 从缓存加载推荐失败: $e');
    }
  }

  /// ⭐ 分批加载推荐（先2套，后3套）
  void _loadRecommendationsWithBatching() {
    if (_aiService == null) {
      print('❌ AI服务未初始化');
      return;
    }

    // 异步执行，不等待
    Future.microtask(() async {
      try {
        // ============ 第一批：快速生成2套 ============
        print('🚀 开始快速生成前2套推荐...');
        _isLoadingRecommendations = true;
        notifyListeners();

        final firstBatch = await _aiService!.getTwoRecommendationSets(
          user: _currentUser,
        );

        // 立即显示前2套
        _allRecommendationSets = firstBatch;
        _currentSetIndex = 0;
        _isLoadingRecommendations = false;
        notifyListeners();

        print('✅ 前2套推荐已就绪，用户可以立即查看');

        // 保存首批到缓存
        await _saveRecommendationsToCache();

        // ============ 第二批：后台生成剩余3套 ============
        print('🔄 后台开始生成剩余3套推荐...');
        _isLoadingMoreSets = true;
        notifyListeners();

        final secondBatch = await _aiService!.getThreeRecommendationSets(
          user: _currentUser,
        );

        // 添加剩余3套
        _allRecommendationSets.addAll(secondBatch);
        _isLoadingMoreSets = false;
        notifyListeners();

        print('✅ 全部5套推荐已完成');

        // 保存完整的5套到缓存
        await _saveRecommendationsToCache();

      } catch (e) {
        _setError('生成推荐失败: $e');
        _isLoadingRecommendations = false;
        _isLoadingMoreSets = false;
        notifyListeners();
      }
    });
  }

  /// 保存推荐到缓存
  Future<void> _saveRecommendationsToCache() async {
    try {
      final storageService = await StorageService.getInstance();

      // 将推荐序列化为JSON
      final setsJson = _allRecommendationSets.map((set) {
        return set.map((meal) => meal.toJson()).toList();
      }).toList();

      final cachedData = jsonEncode(setsJson);

      await storageService.setString('cached_recommendations', cachedData);

      print('💾 推荐已缓存到本地（共 ${_allRecommendationSets.length} 套）');
    } catch (e) {
      print('❌ 缓存推荐失败: $e');
    }
  }

  /// 手动刷新推荐（重新生成5套，使用分批策略）
  Future<void> refreshRecommendations() async {
    if (_aiService == null) {
      _setError('AI服务未初始化');
      return;
    }

    try {
      print('🔄 手动刷新推荐（分批加载）...');

      // 清空旧推荐
      _allRecommendationSets.clear();
      _currentSetIndex = 0;

      // 使用分批加载策略
      _loadRecommendationsWithBatching();

    } catch (e) {
      _setError('刷新推荐失败: $e');
      _isLoadingRecommendations = false;
      notifyListeners();
    }
  }

  /// 切换到下一套推荐
  void switchToNextSet() {
    if (_allRecommendationSets.isEmpty) return;

    _currentSetIndex = (_currentSetIndex + 1) % _allRecommendationSets.length;
    notifyListeners();

    print('📍 切换到第 ${_currentSetIndex + 1} 套推荐');
  }

  /// 切换到指定的套餐
  void switchToSet(int index) {
    if (index < 0 || index >= _allRecommendationSets.length) return;

    _currentSetIndex = index;
    notifyListeners();
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
        final setIndex = _allRecommendationSets.indexWhere(
          (set) => set.any((m) => m.id == recommendation.id)
        );

        if (setIndex != -1) {
          final mealIndex = _allRecommendationSets[setIndex]
              .indexWhere((m) => m.id == recommendation.id);

          if (mealIndex != -1) {
            _allRecommendationSets[setIndex][mealIndex] =
                recommendation.copyWith(isAdopted: true);
            notifyListeners();
          }
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