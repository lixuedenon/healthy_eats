// lib/presentation/screens/settings_screen.dart
// Dart类文件

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_viewmodel.dart';
import '../../config/theme_config.dart';

/// 设置页面
///
/// 显示各种设置选项
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: ThemeConfig.primaryColor,
      ),
      body: Consumer<UserViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.currentUser == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = viewModel.currentUser!;

          return ListView(
            children: [
              // 用户信息卡片
              _buildUserCard(context, user),

              const Divider(height: 1),

              // 个人信息
              _buildSection(
                context,
                title: '个人信息',
                children: [
                  _buildListTile(
                    icon: Icons.person,
                    title: '基本信息',
                    subtitle: '姓名、年龄、身高、体重等',
                    onTap: () {
                      // TODO: 跳转到基本信息编辑页
                    },
                  ),
                  _buildListTile(
                    icon: Icons.favorite,
                    title: '健康目标',
                    subtitle: user.healthGoal,
                    onTap: () {
                      _showHealthGoalDialog(context, viewModel);
                    },
                  ),
                ],
              ),

              const Divider(height: 1),

              // 餐食偏好
              _buildSection(
                context,
                title: '餐食偏好',
                children: [
                  _buildListTile(
                    icon: Icons.restaurant,
                    title: '餐食来源',
                    subtitle: _getMealSourceText(user.defaultMealSource),
                    onTap: () {
                      // TODO: 跳转到餐食来源设置页
                    },
                  ),
                  _buildListTile(
                    icon: Icons.people,
                    title: '就餐方式',
                    subtitle: user.defaultDiningStyle,
                    onTap: () {
                      // TODO: 跳转到就餐方式设置页
                    },
                  ),
                  _buildListTile(
                    icon: Icons.public,
                    title: '菜系偏好',
                    subtitle: user.preferredCuisines.isEmpty
                        ? '未设置'
                        : user.preferredCuisines.take(3).join('、'),
                    onTap: () {
                      // TODO: 跳转到菜系偏好设置页
                    },
                  ),
                  _buildListTile(
                    icon: Icons.cookie,
                    title: '零食偏好',
                    subtitle: user.snackFrequency,
                    onTap: () {
                      // TODO: 跳转到零食偏好设置页
                    },
                  ),
                ],
              ),

              const Divider(height: 1),

              // 忌口管理
              _buildSection(
                context,
                title: '忌口管理',
                children: [
                  _buildListTile(
                    icon: Icons.block,
                    title: '忌口食材',
                    subtitle: _getAvoidanceCountText(user),
                    onTap: () {
                      // TODO: 跳转到忌口设置页
                    },
                  ),
                  if (user.isVegetarian)
                    _buildListTile(
                      icon: Icons.eco,
                      title: '素食者',
                      subtitle: '已启用素食模式',
                      trailing: const Icon(Icons.check_circle, color: Colors.green),
                    ),
                  if (user.hasHighBloodSugar)
                    _buildListTile(
                      icon: Icons.medical_services,
                      title: '血糖管理',
                      subtitle: '已启用血糖控制模式',
                      trailing: const Icon(Icons.check_circle, color: Colors.orange),
                    ),
                ],
              ),

              const Divider(height: 1),

              // 提醒设置
              _buildSection(
                context,
                title: '提醒设置',
                children: [
                  _buildSwitchTile(
                    icon: Icons.alarm,
                    title: '早餐提醒',
                    subtitle: user.enableBreakfastReminder
                        ? '${user.breakfastTime}'
                        : '已关闭',
                    value: user.enableBreakfastReminder,
                    onChanged: (value) {
                      viewModel.updateReminderSettings(
                        enableBreakfastReminder: value,
                      );
                    },
                  ),
                  _buildSwitchTile(
                    icon: Icons.alarm,
                    title: '午餐提醒',
                    subtitle: user.enableLunchReminder
                        ? '${user.lunchTime}'
                        : '已关闭',
                    value: user.enableLunchReminder,
                    onChanged: (value) {
                      viewModel.updateReminderSettings(
                        enableLunchReminder: value,
                      );
                    },
                  ),
                  _buildSwitchTile(
                    icon: Icons.alarm,
                    title: '晚餐提醒',
                    subtitle: user.enableDinnerReminder
                        ? '${user.dinnerTime}'
                        : '已关闭',
                    value: user.enableDinnerReminder,
                    onChanged: (value) {
                      viewModel.updateReminderSettings(
                        enableDinnerReminder: value,
                      );
                    },
                  ),
                ],
              ),

              const Divider(height: 1),

              // 应用设置
              _buildSection(
                context,
                title: '应用设置',
                children: [
                  _buildListTile(
                    icon: Icons.language,
                    title: '语言',
                    subtitle: _getLanguageText(user.language),
                    onTap: () {
                      _showLanguageDialog(context, viewModel);
                    },
                  ),
                  _buildListTile(
                    icon: Icons.palette,
                    title: '主题',
                    subtitle: '浅色',
                    onTap: () {
                      // TODO: 主题切换
                    },
                  ),
                ],
              ),

              const Divider(height: 1),

              // VIP会员
              _buildSection(
                context,
                title: 'VIP会员',
                children: [
                  _buildListTile(
                    icon: Icons.star,
                    title: user.isVIPValid ? 'VIP会员' : '升级VIP',
                    subtitle: user.isVIPValid
                        ? '到期时间: ${_formatDate(user.vipExpiryDate)}'
                        : '解锁更多功能',
                    trailing: user.isVIPValid
                        ? const Icon(Icons.check_circle, color: Colors.amber)
                        : const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: 跳转到VIP页面
                    },
                  ),
                ],
              ),

              const Divider(height: 1),

              // 关于
              _buildSection(
                context,
                title: '关于',
                children: [
                  _buildListTile(
                    icon: Icons.info,
                    title: '关于应用',
                    subtitle: '版本 1.0.0',
                    onTap: () {
                      _showAboutDialog(context);
                    },
                  ),
                  _buildListTile(
                    icon: Icons.privacy_tip,
                    title: '隐私政策',
                    onTap: () {
                      // TODO: 显示隐私政策
                    },
                  ),
                  _buildListTile(
                    icon: Icons.description,
                    title: '用户协议',
                    onTap: () {
                      // TODO: 显示用户协议
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  /// 构建用户卡片
  Widget _buildUserCard(BuildContext context, user) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ThemeConfig.primaryColor,
            ThemeConfig.primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // 头像
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                '👤',
                style: TextStyle(fontSize: 30),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // 用户信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.city ?? '未设置城市',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                if (user.bmi != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'BMI: ${user.bmi!.toStringAsFixed(1)} (${user.bmiRating})',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // VIP标识
          if (user.isVIPValid)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'VIP',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 构建分组
  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: ThemeConfig.primaryColor,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  /// 构建列表项
  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: ThemeConfig.primaryColor),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  /// 构建开关列表项
  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: ThemeConfig.primaryColor),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: ThemeConfig.primaryColor,
      ),
    );
  }

  // ==================== 对话框 ====================

  /// 显示健康目标选择对话框
  void _showHealthGoalDialog(BuildContext context, UserViewModel viewModel) {
    final goals = ['减脂', '增肌', '维持', '随意'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择健康目标'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: goals.map((goal) => RadioListTile<String>(
            title: Text(goal),
            value: goal,
            groupValue: viewModel.currentUser?.healthGoal,
            onChanged: (value) {
              if (value != null) {
                viewModel.updateHealthGoal(value);
                Navigator.pop(context);
              }
            },
          )).toList(),
        ),
      ),
    );
  }

  /// 显示语言选择对话框
  void _showLanguageDialog(BuildContext context, UserViewModel viewModel) {
    final languages = {
      'zh': '中文',
      'en': 'English',
      'es': 'Español',
      'ja': '日本語',
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择语言'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.entries.map((entry) => RadioListTile<String>(
            title: Text(entry.value),
            value: entry.key,
            groupValue: viewModel.currentUser?.language,
            onChanged: (value) {
              if (value != null) {
                viewModel.updateLanguage(value);
                Navigator.pop(context);
              }
            },
          )).toList(),
        ),
      ),
    );
  }

  /// 显示关于对话框
  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Healthy Eats',
      applicationVersion: '1.0.0',
      applicationIcon: const Text('🍽️', style: TextStyle(fontSize: 40)),
      children: [
        const Text('AI驱动的智能健康饮食管理应用'),
        const SizedBox(height: 8),
        const Text('© 2025 Healthy Eats Team'),
      ],
    );
  }

  // ==================== 辅助方法 ====================

  String _getMealSourceText(int level) {
    const texts = {
      1: '基本外食',
      2: '较多外食',
      3: '对半',
      4: '较多自己做',
      5: '基本自己做',
    };
    return texts[level] ?? '未设置';
  }

  String _getAvoidanceCountText(user) {
    int count = user.avoidVegetables.length +
                user.avoidFruits.length +
                user.avoidMeats.length +
                user.avoidSeafood.length;
    return count > 0 ? '已设置 $count 项' : '未设置';
  }

  String _getLanguageText(String code) {
    const languages = {
      'zh': '中文',
      'en': 'English',
      'es': 'Español',
      'ja': '日本語',
    };
    return languages[code] ?? '中文';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '未设置';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}