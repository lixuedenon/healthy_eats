// lib/presentation/screens/home_screen.dart
// Dart类文件

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/home_viewmodel.dart';
import '../viewmodels/user_viewmodel.dart';
import '../widgets/meal_card.dart';
import '../widgets/lqi_card.dart';
import '../widgets/recommended_meal_card.dart';
import '../../config/theme_config.dart';
import 'meal_record_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // ✅ 修改1：压缩 AppBar 高度
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
                    // ✅ 修改2：合并问候语和开关，开关放右侧
                    _buildGreetingWithSwitch(viewModel),

                    // ✅ 删除：原来独立的健康饮食开关卡片已移除

                    if (!viewModel.hasFilledAnyInfo())
                      _buildProfileIncompleteBanner(viewModel),

                    _buildRecommendationsSection(viewModel),

                    if (viewModel.todayLQI != null)
                      LQISimpleCard(
                        lqi: viewModel.todayLQI!,
                        onTap: () {
                        },
                      ),

                    const SizedBox(height: 8),

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

  // ✅ 修改1：压缩 AppBar 高度（从 120 → 80）
  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 80, // ✅ 从 120 改为 80
      floating: false,
      pinned: true,
      backgroundColor: ThemeConfig.primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Healthy Eats',
          style: TextStyle(
            fontSize: 18, // ✅ 从 20 改为 18
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

  // ✅ 修改2：合并问候语和模式切换按钮（新方法）
  Widget _buildGreetingWithSwitch(HomeViewModel homeViewModel) {
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ThemeConfig.primaryColor,
            ThemeConfig.primaryColor.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ThemeConfig.primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 问候语部分
          Text(
            '$emoji $greeting，${homeViewModel.currentUser?.name ?? '用户'}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _getMotivationalMessage(homeViewModel),
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white70,
            ),
          ),

          const SizedBox(height: 12),

          // ✅ 模式切换按钮
          Consumer<UserViewModel>(
            builder: (context, userViewModel, child) {
              final isHealthyMode = userViewModel.currentUser?.isHealthyEatingMode ?? false;

              return Row(
                children: [
                  const Text(
                    '📍 推荐模式：',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // 美味优先按钮
                  _buildModeButton(
                    label: '美味优先',
                    icon: Icons.restaurant,
                    isActive: !isHealthyMode,
                    onTap: () => _onModeChanged(context, false, userViewModel, homeViewModel),
                  ),

                  const SizedBox(width: 8),

                  // 健康优先按钮
                  _buildModeButton(
                    label: '健康优先',
                    icon: Icons.favorite,
                    isActive: isHealthyMode,
                    onTap: () => _onModeChanged(context, true, userViewModel, homeViewModel),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ✅ 构建模式按钮
  Widget _buildModeButton({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isActive ? null : onTap, // 已激活的按钮不可点击
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive ? ThemeConfig.primaryColor : Colors.white.withOpacity(0.7),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? ThemeConfig.primaryColor : Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ 处理模式切换
  Future<void> _onModeChanged(
    BuildContext context,
    bool newMode,
    UserViewModel userViewModel,
    HomeViewModel homeViewModel,
  ) async {
    // 先更新状态（开关立即改变）
    await userViewModel.updateHealthyEatingMode(newMode);

    // 弹出确认对话框
    if (!mounted) return;

    final confirmed = await _showModeChangeConfirmDialog(newMode);

    if (confirmed == true) {
      // 用户选择"是" → 刷新推荐
      if (mounted) {
        await homeViewModel.refreshRecommendations();
      }
    } else {
      // 用户选择"否" → 回退状态
      await userViewModel.updateHealthyEatingMode(!newMode);
    }
  }

  // ✅ 模式切换确认对话框
  Future<bool?> _showModeChangeConfirmDialog(bool isHealthyMode) {
    final String modeText = isHealthyMode ? '健康优先' : '美味优先（不考虑是否为健康饮食）';
    final String description = isHealthyMode
        ? '将根据您的健康目标、BMI 和健康状况推荐餐食'
        : '将主要考虑口味偏好，不特别考虑健康因素';

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('切换推荐模式'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('是否按【$modeText】标准重新生成推荐？'),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConfig.primaryColor,
            ),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  // ✅ 删除：原来的 _buildGreeting 方法已被 _buildGreetingWithSwitch 替代
  // ✅ 删除：原来的 _buildHealthyEatingSwitch 方法已被合并到 _buildGreetingWithSwitch

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
                  '⚠️ 完善个人信息，获得精准推荐',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[900],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '当前推荐基于大众口味，完善信息后可获得更个性化的餐食方案',
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

  Widget _buildRecommendationsSection(HomeViewModel viewModel) {
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

        _buildRecommendationContext(viewModel),

        ...viewModel.currentRecommendations.map(
          (recommendation) => RecommendedMealCard(
            meal: recommendation,
            showModelBadge: false,
            onAdopt: () async {
              await viewModel.adoptRecommendation(recommendation);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已采用推荐！')),
                );
              }
            },
            onViewDetail: () {
            },
          ),
        ),

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

  Widget _buildRecommendationContext(HomeViewModel viewModel) {
    final user = viewModel.currentUser;
    if (user == null) return const SizedBox.shrink();

    String contextText;

    if (user.isHealthyEatingMode) {
      final healthGoal = user.healthGoal;
      final mealSource = _getMealSourceText(user.defaultMealSource);
      final city = user.city ?? '未知城市';

      contextText = '根据您的【$healthGoal】目标、【$mealSource】偏好';
      if (user.city != null && user.city!.isNotEmpty) {
        contextText += '、【$city】消费水平';
      }
      contextText += '，为您推荐营养均衡的餐食';
    } else {
      final mealSource = _getMealSourceText(user.defaultMealSource);
      contextText = '根据您的【$mealSource】偏好和口味喜好，为您推荐美味餐食';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: Colors.green[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              contextText,
              style: TextStyle(
                fontSize: 13,
                color: Colors.green[900],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getMealSourceText(int level) {
    const texts = {
      1: '基本外食',
      2: '较多外食',
      3: '外食与自制各半',
      4: '较多自己做',
      5: '基本自己做',
    };
    return texts[level] ?? '未设置';
  }

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