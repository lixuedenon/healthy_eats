// lib/presentation/screens/home_screen.dart
// Dart类文件

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/home_viewmodel.dart';
import '../widgets/meal_card.dart';
import '../widgets/lqi_card.dart';
import '../widgets/recommended_meal_card.dart';
import '../../config/theme_config.dart';
import 'meal_record_screen.dart';

/// 首页界面
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Consumer<HomeViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGreeting(viewModel),

                    // 用户信息不完整提示
                    if (!viewModel.isUserProfileComplete())
                      _buildProfileIncompleteBanner(viewModel),

                    // AI推荐区域
                    if (viewModel.currentRecommendations.isNotEmpty)
                      _buildRecommendationsSection(viewModel),

                    // LQI卡片
                    if (viewModel.todayLQI != null)
                      LQISimpleCard(
                        lqi: viewModel.todayLQI!,
                        onTap: () {
                          // TODO: 跳转到LQI详情页
                        },
                      ),

                    const SizedBox(height: 8),

                    // 今日餐食
                    _buildTodayMeals(viewModel),

                    const SizedBox(height: 80),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const MealRecordScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('添加餐食'),
        backgroundColor: ThemeConfig.primaryColor,
      ),
    );
  }

  /// 构建AppBar
  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: ThemeConfig.primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Healthy Eats',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ThemeConfig.primaryColor,
                ThemeConfig.primaryColor.withOpacity(0.8),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () {
            _showDatePicker();
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.pushNamed(context, '/settings');
          },
        ),
      ],
    );
  }

  /// 构建问候语
  Widget _buildGreeting(HomeViewModel viewModel) {
    final now = DateTime.now();
    String greeting = '早上好';
    String emoji = '🌅';

    if (now.hour >= 12 && now.hour < 18) {
      greeting = '下午好';
      emoji = '☀️';
    } else if (now.hour >= 18) {
      greeting = '晚上好';
      emoji = '🌙';
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$emoji $greeting，${viewModel.currentUser?.name ?? ''}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getMotivationalMessage(viewModel),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建用户信息不完整提示横幅
  Widget _buildProfileIncompleteBanner(HomeViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '⚠️ 您的个人信息或饮食偏好不完整',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[900],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '当前推荐基于大众口味，完善信息后可获得更精准的个性化推荐',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange[700],
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
            child: const Text('去完善'),
          ),
        ],
      ),
    );
  }

  /// 构建AI推荐区域
  Widget _buildRecommendationsSection(HomeViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '📍 今日推荐',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  // 模型切换按钮
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        _buildModelButton(
                          'GPT-4',
                          viewModel.selectedModel.contains('gpt-4'),
                          () => viewModel.switchModel('gpt-4'),
                        ),
                        _buildModelButton(
                          'GPT-3.5',
                          viewModel.selectedModel.contains('gpt-3.5'),
                          () => viewModel.switchModel('gpt-3.5-turbo'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 换一套按钮
                  TextButton.icon(
                    onPressed: viewModel.isLoadingRecommendations
                        ? null
                        : () async {
                            await viewModel.refreshRecommendations();
                          },
                    icon: viewModel.isLoadingRecommendations
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh, size: 18),
                    label: const Text('换一套'),
                    style: TextButton.styleFrom(
                      foregroundColor: ThemeConfig.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 推荐餐食卡片
        if (viewModel.isLoadingRecommendations)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
          )
        else
          ...viewModel.currentRecommendations.map(
            (recommendation) => RecommendedMealCard(
              meal: recommendation,
              showModelBadge: true,
              onAdopt: () async {
                await viewModel.adoptRecommendation(recommendation);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('已采用推荐！')),
                  );
                }
              },
              onViewDetail: () {
                // TODO: 查看推荐详情
              },
            ),
          ),
      ],
    );
  }

  /// 构建模型选择按钮
  Widget _buildModelButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? ThemeConfig.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  /// 构建今日餐食
  Widget _buildTodayMeals(HomeViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '今日餐食',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (viewModel.todayMeals.isNotEmpty)
                Text(
                  '${viewModel.getTodayCompletedMealCount()}/${viewModel.getTodayTotalMealCount()} 已完成',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
            ],
          ),
        ),

        if (viewModel.todayMeals.isEmpty)
          _buildEmptyState()
        else
          ...viewModel.todayMeals.map((meal) => MealCard(
            meal: meal,
            onTap: () {
              // TODO: 查看餐食详情
            },
            onDelete: () async {
              final confirmed = await _showDeleteConfirmDialog(meal.name);
              if (confirmed == true) {
                await viewModel.deleteMeal(meal.id);
              }
            },
            onComplete: () async {
              await viewModel.completeMeal(meal.id);
            },
          )),
      ],
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              '今天还没有记录餐食',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '点击下方按钮添加你的第一餐吧！',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 显示日期选择器
  Future<void> _showDatePicker() async {
    final viewModel = context.read<HomeViewModel>();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: viewModel.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('zh', 'CN'),
    );

    if (selectedDate != null) {
      await viewModel.selectDate(selectedDate);
    }
  }

  /// 显示删除确认对话框
  Future<bool?> _showDeleteConfirmDialog(String mealName) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除"$mealName"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  /// 获取激励消息
  String _getMotivationalMessage(HomeViewModel viewModel) {
    if (viewModel.todayMeals.isEmpty) {
      return '今天还没有记录餐食，开始记录吧！';
    }

    final completionRate = viewModel.getTodayCompletionRate();

    if (completionRate >= 1.0) {
      return '太棒了！今天的餐食都完成了！';
    } else if (completionRate >= 0.5) {
      return '继续加油！坚持健康饮食！';
    } else {
      return '记得按时吃饭，保持健康哦~';
    }
  }
}