// lib/presentation/widgets/bottom_nav_bar.dart
// Dart类文件

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../viewmodels/user_viewmodel.dart';
import '../screens/home_screen.dart';
import '../screens/statistics_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';

/// 主导航页面
///
/// 包含底部导航栏和四个主要页面的切换
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const StatisticsScreen(),
    const ProfileScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

/// 底部导航栏组件
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: ThemeConfig.primaryColor,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首页',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: '统计',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '我的',
          ),
          BottomNavigationBarItem(
            icon: _buildSettingsIcon(context),
            label: '设置',
          ),
        ],
      ),
    );
  }

  /// 构建设置图标（带红点提示）
  Widget _buildSettingsIcon(BuildContext context) {
    return Consumer<UserViewModel>(
      builder: (context, userViewModel, child) {
        final shouldShowRedDot = _shouldShowRedDot(userViewModel);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.settings),
            if (shouldShowRedDot)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  /// 判断是否应该显示红点
  ///
  /// 规则：用户填写了部分信息但不完整时显示红点
  bool _shouldShowRedDot(UserViewModel userViewModel) {
    final user = userViewModel.currentUser;
    if (user == null) return false;

    // 判断是否填写了任何一项
    final hasFilledAny = userViewModel.hasFilledAnyInfo();

    // 判断是否完整
    final isComplete = user.age != null &&
        user.height != null &&
        user.weight != null &&
        user.gender != null &&
        (user.city != null && user.city!.isNotEmpty) &&
        user.preferredCuisines.isNotEmpty &&
        user.healthConditions.isNotEmpty;

    // 填写了部分但不完整时显示红点
    return hasFilledAny && !isComplete;
  }
}