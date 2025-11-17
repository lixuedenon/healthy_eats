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

class HomeViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final MealRepository _mealRepository;
  AIRecommendationService? _aiService;

  HomeViewModel(this._userRepository, this._mealRepository);

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

  List<List<RecommendedMeal>> _allRecommendationSets = [];
  int _currentSetIndex = 0;

  List<RecommendedMeal> get currentRecommendations {
    if (_allRecommendationSets.isEmpty) return [];
    return _allRecommendationSets[_currentSetIndex];
  }

  int get currentSetNumber => _currentSetIndex + 1;
  int get totalSets => _allRecommendationSets.length;
  int get currentSetIndex => _currentSetIndex;
  bool get hasRecommendations => _allRecommendationSets.isNotEmpty;

  bool _isLoadingRecommendations = false;
  bool get isLoadingRecommendations => _isLoadingRecommendations;

  bool _isLoadingMoreSets = false;
  bool get isLoadingMoreSets => _isLoadingMoreSets;

  Future<void> initialize() async {
    await _loadUserProfile();
    await _loadTodayMeals();
    await _calculateTodayLQI();

    await _loadRecommendationsFromCache();

    if (!hasRecommendations) {
      _loadRecommendationsWithBatching();
    }
  }

  void setAIService(AIRecommendationService service) {
    _aiService = service;
  }

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

  Future<void> _loadTodayMeals() async {
    try {
      _todayMeals = await _mealRepository.getTodayMeals();
      notifyListeners();
    } catch (e) {
      _setError('加载餐食记录失败: $e');
    }
  }

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

  Future<void> _loadRecommendationsFromCache() async {
    try {
      final storageService = await StorageService.getInstance();
      final cachedData = storageService.getString('cached_recommendations');

      if (cachedData != null) {
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

  void _loadRecommendationsWithBatching() {
    if (_aiService == null) {
      print('❌ AI服务未初始化');
      return;
    }

    Future.microtask(() async {
      try {
        print('🚀 开始快速生成前2套推荐...');
        _isLoadingRecommendations = true;
        notifyListeners();

        final firstBatch = await _aiService!.getTwoRecommendationSets(
          user: _currentUser,
        );

        _allRecommendationSets = firstBatch;
        _currentSetIndex = 0;
        _isLoadingRecommendations = false;
        notifyListeners();

        print('✅ 前2套推荐已就绪，用户可以立即查看');

        await _saveRecommendationsToCache();

        print('🔄 后台开始生成剩余3套推荐...');
        _isLoadingMoreSets = true;
        notifyListeners();

        final secondBatch = await _aiService!.getThreeRecommendationSets(
          user: _currentUser,
        );

        _allRecommendationSets.addAll(secondBatch);
        _isLoadingMoreSets = false;
        notifyListeners();

        print('✅ 全部5套推荐已完成');

        await _saveRecommendationsToCache();

      } catch (e) {
        _setError('生成推荐失败: $e');
        _isLoadingRecommendations = false;
        _isLoadingMoreSets = false;
        notifyListeners();
      }
    });
  }

  Future<void> _saveRecommendationsToCache() async {
    try {
      final storageService = await StorageService.getInstance();

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

  Future<void> refreshRecommendations() async {
    if (_aiService == null) {
      _setError('AI服务未初始化');
      return;
    }

    try {
      print('🔄 手动刷新推荐（分批加载）...');

      _allRecommendationSets.clear();
      _currentSetIndex = 0;

      _loadRecommendationsWithBatching();

    } catch (e) {
      _setError('刷新推荐失败: $e');
      _isLoadingRecommendations = false;
      notifyListeners();
    }
  }

  void switchToNextSet() {
    if (_allRecommendationSets.isEmpty) return;

    _currentSetIndex = (_currentSetIndex + 1) % _allRecommendationSets.length;
    notifyListeners();

    print('📍 切换到第 ${_currentSetIndex + 1} 套推荐');
  }

  void switchToSet(int index) {
    if (index < 0 || index >= _allRecommendationSets.length) return;

    _currentSetIndex = index;
    notifyListeners();
  }

  Future<bool> adoptRecommendation(RecommendedMeal recommendation) async {
    try {
      final meal = _convertRecommendationToMeal(recommendation);

      final success = await addMeal(meal);

      if (success) {
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

  Meal _convertRecommendationToMeal(RecommendedMeal recommendation) {
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

  bool isUserProfileComplete() {
    if (_currentUser == null) return false;
    return _currentUser!.age != null &&
        _currentUser!.healthGoal.isNotEmpty &&
        _currentUser!.preferredCuisines.isNotEmpty;
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

  Future<void> selectDate(DateTime date) async {
    _selectedDate = date;

    if (_isToday(date)) {
      await _loadTodayMeals();
      await _calculateTodayLQI();
    } else {
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

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }

  Future<void> refresh() async {
    await initialize();
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

  int _getTargetCalories() {
    if (_currentUser == null) return 2000;

    const targets = {
      '减脂': 1800,
      '增肌': 2500,
      '维持': 2000,
      '随意': 2000,
      '胡吃海塞': 3000,
      '清汤寡欲': 1500,
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
      '胡吃海塞': 120,
      '清汤寡欲': 80,
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
      '胡吃海塞': 400,
      '清汤寡欲': 150,
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
      '胡吃海塞': 100,
      '清汤寡欲': 40,
    };
    return targets[_currentUser!.healthGoal] ?? 70;
  }

  int getTodayCompletedMealCount() {
    return _todayMeals.where((meal) => meal.isCompleted).length;
  }

  int getTodayTotalMealCount() {
    return _todayMeals.length;
  }

  double getTodayCompletionRate() {
    if (_todayMeals.isEmpty) return 0.0;
    return getTodayCompletedMealCount() / getTodayTotalMealCount();
  }

  bool hasMealType(String mealType) {
    return _todayMeals.any((meal) => meal.mealType == mealType);
  }

  Meal? getMealByType(String mealType) {
    try {
      return _todayMeals.firstWhere((meal) => meal.mealType == mealType);
    } catch (e) {
      return null;
    }
  }
}