// lib/presentation/widgets/recommended_meal_card.dart
// Dart类文件

import 'package:flutter/material.dart';
import '../../data/models/recommended_meal_model.dart';
import '../../config/theme_config.dart';

/// 推荐餐食卡片组件
class RecommendedMealCard extends StatelessWidget {
  final RecommendedMeal meal;
  final VoidCallback? onAdopt;
  final VoidCallback? onViewDetail;
  final bool showModelBadge;

  const RecommendedMealCard({
    Key? key,
    required this.meal,
    this.onAdopt,
    this.onViewDetail,
    this.showModelBadge = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: meal.isAdopted ? 1 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: meal.isAdopted
              ? LinearGradient(
                  colors: [
                    Colors.grey[100]!,
                    Colors.grey[50]!,
                  ],
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题行
              _buildHeader(context),

              const SizedBox(height: 12),

              // 描述
              Text(
                meal.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 12),

              // 食材列表
              _buildIngredients(),

              const SizedBox(height: 12),

              // 营养信息
              _buildNutritionInfo(),

              const SizedBox(height: 12),

              // ROI和烹饪时间
              _buildMetaInfo(),

              if (!meal.isAdopted) ...[
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
              meal.mealEmoji,
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
                  if (showModelBadge) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: meal.sourceModel.contains('gpt-4')
                            ? Colors.blue[100]
                            : Colors.green[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        meal.sourceModel.contains('gpt-4') ? 'GPT-4' : 'GPT-3.5',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: meal.sourceModel.contains('gpt-4')
                              ? Colors.blue[700]
                              : Colors.green[700],
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

        // 已采用标记
        if (meal.isAdopted)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              '已采用',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  /// 构建食材列表
  Widget _buildIngredients() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.restaurant, size: 16, color: Colors.black54),
              SizedBox(width: 6),
              Text(
                '食材',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...meal.ingredients.map((ingredient) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Text('• ', style: TextStyle(color: Colors.black54)),
                    Expanded(
                      child: Text(
                        ingredient,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
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
          '蛋白',
          '${meal.nutrition.protein.toStringAsFixed(0)}g',
          Icons.fitness_center,
          Colors.blue,
        ),
        const SizedBox(width: 8),
        _buildNutrientChip(
          '碳水',
          '${meal.nutrition.carbs.toStringAsFixed(0)}g',
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
            Icon(icon, size: 14, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建元信息（ROI和时间）
  Widget _buildMetaInfo() {
    return Row(
      children: [
        // 情绪ROI
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.purple[50],
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.purple[200]!),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.sentiment_satisfied, color: Colors.purple, size: 16),
              const SizedBox(width: 6),
              Text(
                'ROI: ${meal.estimatedROI}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // 烹饪时间
        if (meal.cookingTime != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.access_time, color: Colors.green, size: 16),
                const SizedBox(width: 6),
                Text(
                  '${meal.cookingTime}分钟',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// 构建操作按钮
  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (onViewDetail != null)
          Expanded(
            child: TextButton.icon(
              onPressed: onViewDetail,
              icon: const Icon(Icons.info_outline, size: 18),
              label: const Text('查看详情'),
              style: TextButton.styleFrom(
                foregroundColor: ThemeConfig.primaryColor,
              ),
            ),
          ),
        if (onViewDetail != null && onAdopt != null)
          Container(
            width: 1,
            height: 30,
            color: Colors.grey[300],
          ),
        if (onAdopt != null)
          Expanded(
            child: TextButton.icon(
              onPressed: onAdopt,
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text('采用此推荐'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.green,
              ),
            ),
          ),
      ],
    );
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
      default:
        return ThemeConfig.primaryColor;
    }
  }
}