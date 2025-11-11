// lib/presentation/widgets/bottom_nav_bar.dart
// Dart类文件

import 'package:flutter/material.dart';
import '../../config/theme_config.dart';

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
          icon: Icon(Icons.add_circle_outline, size: 32),
          activeIcon: Icon(Icons.add_circle, size: 36),
          label: '添加',
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

  // 页面列表
  final List<Widget> _pages = [
    const HomeScreenPlaceholder(),      // 首页
    const StatisticsScreenPlaceholder(), // 统计
    const AddMealScreenPlaceholder(),    // 添加餐食
    const ProfileScreenPlaceholder(),    // 个人
    const SettingsScreenPlaceholder(),   // 设置
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

// ==================== 占位符页面 ====================

class HomeScreenPlaceholder extends StatelessWidget {
  const HomeScreenPlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('首页'),
        backgroundColor: ThemeConfig.primaryColor,
      ),
      body: const Center(
        child: Text('首页内容'),
      ),
    );
  }
}

class StatisticsScreenPlaceholder extends StatelessWidget {
  const StatisticsScreenPlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('统计'),
        backgroundColor: ThemeConfig.primaryColor,
      ),
      body: const Center(
        child: Text('统计内容'),
      ),
    );
  }
}

class AddMealScreenPlaceholder extends StatelessWidget {
  const AddMealScreenPlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加餐食'),
        backgroundColor: ThemeConfig.primaryColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                // TODO: 打开手动添加页面
              },
              icon: const Icon(Icons.edit),
              label: const Text('手动添加'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: 打开AI推荐页面
              },
              icon: const Icon(Icons.auto_awesome),
              label: const Text('AI推荐'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileScreenPlaceholder extends StatelessWidget {
  const ProfileScreenPlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
        backgroundColor: ThemeConfig.primaryColor,
      ),
      body: const Center(
        child: Text('个人资料内容'),
      ),
    );
  }
}

class SettingsScreenPlaceholder extends StatelessWidget {
  const SettingsScreenPlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: ThemeConfig.primaryColor,
      ),
      body: const Center(
        child: Text('设置内容'),
      ),
    );
  }
}