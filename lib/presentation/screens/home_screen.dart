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
    // ⭐ 不在这里调用 initialize，因为已经在 AppInitializerPage 中调用过了
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

                    // ⭐ AI推荐区域（5套方案）
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

  /// ⭐ 构建AI推荐区域（5套方案）
  Widget _buildRecommendationsSection(HomeViewModel viewModel) {
    // 如果正在加载且没有缓存
    if (viewModel.isLoadingRecommendations && !viewModel.hasRecommendations) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🤖 AI 正在为您准备今日推荐...',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '稍后将为您提供 5 套精选方案',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // 如果没有推荐
    if (!viewModel.hasRecommendations) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          children: [
            Icon(Icons.restaurant_menu, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              '暂无推荐',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () async {
                await viewModel.refreshRecommendations();
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('生成推荐'),
            ),
          ],
        ),
      );
    }

    // 显示推荐
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📍 今日推荐',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '方案 ${viewModel.currentSetNumber}/${viewModel.totalSets}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  // ⭐ 换一套按钮
                  TextButton.icon(
                    onPressed: viewModel.isLoadingRecommendations
                        ? null
                        : () {
                            viewModel.switchToNextSet();
                          },
                    icon: const Icon(Icons.swap_horiz, size: 18),
                    label: const Text('换一套'),
                    style: TextButton.styleFrom(
                      foregroundColor: ThemeConfig.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // ⭐ 重新生成按钮
                  IconButton(
                    onPressed: viewModel.isLoadingRecommendations
                        ? null
                        : () async {
                            final confirmed = await _showRefreshConfirmDialog();
                            if (confirmed == true) {
                              await viewModel.refreshRecommendations();
                            }
                          },
                    icon: viewModel.isLoadingRecommendations
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                    tooltip: '重新生成',
                  ),
                ],
              ),
            ],
          ),
        ),

        // ⭐ 推荐餐食卡片（当前套餐的3个餐食）
        ...viewModel.currentRecommendations.map(
          (recommendation) => RecommendedMealCard(
            meal: recommendation,
            showModelBadge: false, // 不显示模型标签（只用GPT-3.5）
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

        // ⭐ 套餐指示器（显示当前是第几套）
        if (viewModel.totalSets > 1)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                viewModel.totalSets,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: index == viewModel.currentSetIndex ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: index == viewModel.currentSetIndex
                        ? ThemeConfig.primaryColor
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
      ],
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

  /// ⭐ 显示重新生成确认对话框
  Future<bool?> _showRefreshConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重新生成推荐'),
        content: const Text('确定要重新生成今日推荐吗？这将替换当前的 5 套方案。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确定'),
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
