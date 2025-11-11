// lib/presentation/widgets/meal_card.dart
// Dart类文件

import 'package:flutter/material.dart';
import '../../data/models/meal_model.dart';
import '../../config/theme_config.dart';

/// 餐食卡片组件
///
/// 显示单个餐食的信息卡片
class MealCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onComplete;
  final bool showActions;

  const MealCard({
    Key? key,
    required this.meal,
    this.onTap,
    this.onDelete,
    this.onComplete,
    this.showActions = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题行
              _buildHeader(context),

              const SizedBox(height: 12),

              // 营养信息
              _buildNutritionInfo(),

              if (meal.emotionROI != null) ...[
                const SizedBox(height: 12),
                _buildEmotionROI(),
              ],

              if (showActions) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                _buildActions(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 构建标题行
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // 餐次图标
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getMealTypeColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              _getMealTypeIcon(),
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // 餐次和名称
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    meal.mealType,
                    style: TextStyle(
                      fontSize: 14,
                      color: _getMealTypeColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (meal.isCompleted) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '已完成',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                meal.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // 来源标签
        if (meal.source.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              meal.source,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ),
      ],
    );
  }

  /// 构建营养信息
  Widget _buildNutritionInfo() {
    return Row(
      children: [
        _buildNutrientChip(
          '热量',
          '${meal.nutrition.calories.toStringAsFixed(0)} kcal',
          Icons.local_fire_department,
          Colors.orange,
        ),
        const SizedBox(width: 8),
        _buildNutrientChip(
          '蛋白质',
          '${meal.nutrition.protein.toStringAsFixed(1)} g',
          Icons.fitness_center,
          Colors.blue,
        ),
        const SizedBox(width: 8),
        _buildNutrientChip(
          '碳水',
          '${meal.nutrition.carbs.toStringAsFixed(1)} g',
          Icons.rice_bowl,
          Colors.amber,
        ),
      ],
    );
  }

  /// 构建营养素芯片
  Widget _buildNutrientChip(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建情绪ROI
  Widget _buildEmotionROI() {
    if (meal.emotionROI == null) return const SizedBox();

    final roi = meal.emotionROI!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple[200]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.sentiment_satisfied, color: Colors.purple),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      '情绪ROI: ',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '${roi.totalScore}分',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        roi.rating,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '主要益处: ${roi.primaryBenefit}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (!meal.isCompleted && onComplete != null)
          TextButton.icon(
            onPressed: onComplete,
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: const Text('标记完成'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.green,
            ),
          ),

        if (onTap != null)
          TextButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.info_outline, size: 18),
            label: const Text('查看详情'),
            style: TextButton.styleFrom(
              foregroundColor: ThemeConfig.primaryColor,
            ),
          ),

        if (onDelete != null)
          TextButton.icon(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('删除'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
      ],
    );
  }

  // ==================== 辅助方法 ====================

  /// 获取餐次图标
  String _getMealTypeIcon() {
    switch (meal.mealType) {
      case '早餐':
        return '🌅';
      case '午餐':
        return '☀️';
      case '晚餐':
        return '🌙';
      case '零食':
        return '🍪';
      default:
        return '🍽️';
    }
  }

  /// 获取餐次颜色
  Color _getMealTypeColor() {
    switch (meal.mealType) {
      case '早餐':
        return Colors.orange;
      case '午餐':
        return Colors.blue;
      case '晚餐':
        return Colors.indigo;
      case '零食':
        return Colors.green;
      default:
        return ThemeConfig.primaryColor;
    }
  }
}