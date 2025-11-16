// lib/presentation/screens/meal_detail_screen.dart
// Dart类文件

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/models/meal_model.dart';
import '../../config/theme_config.dart';

/// 餐食详情页面
class MealDetailScreen extends StatelessWidget {
  final Meal meal;

  const MealDetailScreen({
    Key? key,
    required this.meal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(meal.name),
        backgroundColor: ThemeConfig.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showMoreOptions(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 基本信息
            _buildBasicInfo(),

            const SizedBox(height: 24),

            // 营养成分图表
            _buildNutritionChart(),

            const SizedBox(height: 24),

            // 情绪ROI
            if (meal.emotionROI != null)
              _buildEmotionROI(),

            if (meal.emotionROI != null)
              const SizedBox(height: 24),

            // 食物列表
            _buildFoodList(),

            const SizedBox(height: 24),

            // 来源信息
            _buildSourceInfo(),
          ],
        ),
      ),
    );
  }

  /// 构建基本信息
  Widget _buildBasicInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  meal.getMealEmoji(),
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal.mealType,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        meal.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.black54),
                const SizedBox(width: 4),
                Text(
                  '${meal.dateTime.hour}:${meal.dateTime.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  meal.getSourceIcon(),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 4),
                Text(
                  meal.source,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建营养图表
  Widget _buildNutritionChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '营养成分',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // 饼图
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: meal.nutrition.protein * 4,
                      title: '蛋白质\n${meal.nutrition.proteinPercentage.toStringAsFixed(1)}%',
                      color: ThemeConfig.proteinColor,
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: meal.nutrition.carbs * 4,
                      title: '碳水\n${meal.nutrition.carbsPercentage.toStringAsFixed(1)}%',
                      color: ThemeConfig.carbsColor,
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: meal.nutrition.fat * 9,
                      title: '脂肪\n${meal.nutrition.fatPercentage.toStringAsFixed(1)}%',
                      color: ThemeConfig.fatColor,
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 营养数值
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNutrientValue(
                  '热量',
                  '${meal.nutrition.calories.toStringAsFixed(0)} kcal',
                  ThemeConfig.caloriesColor,
                ),
                _buildNutrientValue(
                  '蛋白质',
                  '${meal.nutrition.protein.toStringAsFixed(1)} g',
                  ThemeConfig.proteinColor,
                ),
                _buildNutrientValue(
                  '碳水',
                  '${meal.nutrition.carbs.toStringAsFixed(1)} g',
                  ThemeConfig.carbsColor,
                ),
                _buildNutrientValue(
                  '脂肪',
                  '${meal.nutrition.fat.toStringAsFixed(1)} g',
                  ThemeConfig.fatColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建营养素数值
  Widget _buildNutrientValue(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  /// 构建情绪ROI
  Widget _buildEmotionROI() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '情绪ROI',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.purple,
                      width: 4,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${meal.emotionROI}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getEmotionROIRating(meal.emotionROI!),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (meal.emotionBenefit != null)
                        Text(
                          '主要益处: ${meal.emotionBenefit}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建食物列表
  Widget _buildFoodList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '食物清单',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...meal.foodItems.map((food) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 8, color: Colors.black54),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      food.displayName,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Text(
                    '${food.nutrition.calories.toStringAsFixed(0)} kcal',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  /// 构建来源信息
  Widget _buildSourceInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '其他信息',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (meal.cookingTime != null)
              _buildInfoRow(
                Icons.timer,
                '烹饪时间',
                '${meal.cookingTime} 分钟',
              ),
            if (meal.totalCost != null)
              _buildInfoRow(
                Icons.attach_money,
                '成本',
                '¥ ${meal.totalCost!.toStringAsFixed(1)}',
              ),
            _buildInfoRow(
              Icons.calendar_today,
              '记录时间',
              '${meal.dateTime.year}-${meal.dateTime.month}-${meal.dateTime.day}',
            ),
          ],
        ),
      ),
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.black54),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// 显示更多选项
  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('编辑'),
            onTap: () {
              Navigator.pop(context);
              // TODO: 编辑功能
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('删除', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              // TODO: 删除功能
            },
          ),
        ],
      ),
    );
  }

  /// 获取情绪ROI评级
  String _getEmotionROIRating(int score) {
    if (score >= 90) return '优秀';
    if (score >= 80) return '良好';
    if (score >= 70) return '一般';
    if (score >= 60) return '较差';
    return '需改善';
  }
}