// lib/presentation/widgets/bottom_nav_bar.dart
// Dart类文件

import 'package:flutter/material.dart';
import '../../config/theme_config.dart';
import '../screens/home_screen.dart';
import '../screens/statistics_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';

/// 底部导航栏组件
///
/// 用于应用主页面的底部导航
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: ThemeConfig.primaryColor,
      unselectedItemColor: Colors.grey,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          activeIcon: Icon(Icons.home, size: 28),
          label: '首页',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          activeIcon: Icon(Icons.bar_chart, size: 28),
          label: '统计',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          activeIcon: Icon(Icons.person, size: 28),
          label: '我的',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          activeIcon: Icon(Icons.settings, size: 28),
          label: '设置',
        ),
      ],
    );
  }
}

/// 主页面导航容器
///
/// 包含底部导航栏和页面切换逻辑
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  // 页面列表 - 使用真实页面
  final List<Widget> _pages = [
    const HomeScreen(),         // 首页
    const StatisticsScreen(),   // 统计
    const ProfileScreen(),      // 我的
    const SettingsScreen(),     // 设置
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