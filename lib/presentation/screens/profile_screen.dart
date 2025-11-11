// lib/presentation/screens/profile_screen.dart
// Dart类文件

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_viewmodel.dart';
import '../../config/theme_config.dart';

/// 个人资料页面
///
/// 显示和编辑用户个人信息
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('个人资料'),
        backgroundColor: ThemeConfig.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: 进入编辑模式
            },
          ),
        ],
      ),
      body: Consumer<UserViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.currentUser == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = viewModel.currentUser!;
          final completionPercentage = viewModel.getProfileCompletionPercentage();

          return ListView(
            children: [
              // 头像和基本信息
              _buildHeader(context, user),

              // 完成度提示
              if (completionPercentage < 100)
                _buildCompletionTip(context, completionPercentage),

              const SizedBox(height: 16),

              // 基本信息
              _buildSection(
                context,
                title: '基本信息',
                children: [
                  _buildInfoTile(
                    icon: Icons.person,
                    label: '姓名',
                    value: user.name,
                  ),
                  _buildInfoTile(
                    icon: Icons.location_city,
                    label: '城市',
                    value: user.city ?? '未设置',
                  ),
                  _buildInfoTile(
                    icon: Icons.cake,
                    label: '年龄',
                    value: user.age != null ? '${user.age}岁' : '未设置',
                  ),
                  _buildInfoTile(
                    icon: Icons.wc,
                    label: '性别',
                    value: user.gender ?? '未设置',
                  ),
                ],
              ),

              const Divider(height: 1),

              // 身体指标
              _buildSection(
                context,
                title: '身体指标',
                children: [
                  _buildInfoTile(
                    icon: Icons.height,
                    label: '身高',
                    value: user.height != null ? '${user.height}cm' : '未设置',
                  ),
                  _buildInfoTile(
                    icon: Icons.monitor_weight,
                    label: '体重',
                    value: user.weight != null ? '${user.weight}kg' : '未设置',
                  ),
                  if (user.bmi != null)
                    _buildInfoTile(
                      icon: Icons.analytics,
                      label: 'BMI',
                      value: '${user.bmi!.toStringAsFixed(1)} (${user.bmiRating})',
                      valueColor: _getBMIColor(user.bmi!),
                    ),
                ],
              ),

              const Divider(height: 1),

              // 健康目标
              _buildSection(
                context,
                title: '健康目标',
                children: [
                  _buildInfoTile(
                    icon: Icons.favorite,
                    label: '目标',
                    value: user.healthGoal,
                    valueColor: ThemeConfig.primaryColor,
                  ),
                ],
              ),

              const Divider(height: 1),

              // 餐食偏好
              _buildSection(
                context,
                title: '餐食偏好',
                children: [
                  _buildInfoTile(
                    icon: Icons.restaurant,
                    label: '餐食来源',
                    value: _getMealSourceText(user.defaultMealSource),
                  ),
                  _buildInfoTile(
                    icon: Icons.people,
                    label: '就餐方式',
                    value: user.defaultDiningStyle,
                  ),
                  _buildInfoTile(
                    icon: Icons.public,
                    label: '菜系偏好',
                    value: user.preferredCuisines.isEmpty
                        ? '未设置'
                        : user.preferredCuisines.join('、'),
                  ),
                  _buildInfoTile(
                    icon: Icons.cookie,
                    label: '零食偏好',
                    value: user.snackFrequency,
                  ),
                ],
              ),

              const Divider(height: 1),

              // 特殊标记
              if (user.isVegetarian || user.hasHighBloodSugar)
                _buildSection(
                  context,
                  title: '特殊饮食',
                  children: [
                    if (user.isVegetarian)
                      _buildBadgeTile(
                        icon: Icons.eco,
                        label: '素食者',
                        badgeColor: Colors.green,
                      ),
                    if (user.hasHighBloodSugar)
                      _buildBadgeTile(
                        icon: Icons.medical_services,
                        label: '血糖管理',
                        badgeColor: Colors.orange,
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

  /// 构建头部
  Widget _buildHeader(BuildContext context, user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ThemeConfig.primaryColor,
            ThemeConfig.primaryColor.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        children: [
          // 头像
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
            ),
            child: const Center(
              child: Text(
                '👤',
                style: TextStyle(fontSize: 50),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 姓名
          Text(
            user.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 8),

          // VIP标识
          if (user.isVIPValid)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  const Text(
                    'VIP会员',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '免费版',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 构建完成度提示
  Widget _buildCompletionTip(BuildContext context, int percentage) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '个人信息完成度: $percentage%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '完善个人信息可以获得更精准的AI推荐',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              // TODO: 跳转到编辑页面
            },
            child: const Text('去完善'),
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

  /// 构建信息项
  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: ThemeConfig.primaryColor),
      title: Text(label),
      trailing: Text(
        value,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: valueColor ?? Colors.black87,
        ),
      ),
    );
  }

  /// 构建徽章项
  Widget _buildBadgeTile({
    required IconData icon,
    required String label,
    required Color badgeColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: badgeColor),
      title: Text(label),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: badgeColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          '已启用',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
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

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) {
      return Colors.blue;
    } else if (bmi < 24) {
      return Colors.green;
    } else if (bmi < 28) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}