// lib/presentation/widgets/bottom_nav_bar.dart
// Dart类文件

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../viewmodels/user_viewmodel.dart';

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
            icon: Icon(Icons.restaurant),
            label: '记录',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: '分析',
          ),
          BottomNavigationBarItem(
            icon: _buildProfileIcon(context),
            label: '我的',
          ),
        ],
      ),
    );
  }

  Widget _buildProfileIcon(BuildContext context) {
    return Consumer<UserViewModel>(
      builder: (context, userViewModel, child) {
        final shouldShowRedDot = _shouldShowRedDot(userViewModel);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.person),
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

  bool _shouldShowRedDot(UserViewModel userViewModel) {
    final user = userViewModel.currentUser;
    if (user == null) return false;

    final hasFilledAny = userViewModel.hasFilledAnyInfo();

    final isComplete = user.age != null &&
        user.height != null &&
        user.weight != null &&
        user.gender != null &&
        (user.city != null && user.city!.isNotEmpty) &&
        user.preferredCuisines.isNotEmpty &&
        user.healthConditions.isNotEmpty;

    return hasFilledAny && !isComplete;
  }
}