// lib/presentation/screens/meal_record_screen.dart
// Dart类文件

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/home_viewmodel.dart';
import '../widgets/add_food_item_dialog.dart';
import '../../data/models/meal_model.dart';
import '../../data/models/food_item_model.dart';
import '../../data/models/nutrition_model.dart';
import '../../domain/ai_engine/calculators/nutrition_calculator.dart';
import '../../domain/ai_engine/calculators/emotion_roi_calculator.dart';
import '../../config/theme_config.dart';
import '../../core/constants/app_constants.dart';

/// 餐食记录页面
class MealRecordScreen extends StatefulWidget {
  const MealRecordScreen({Key? key}) : super(key: key);

  @override
  State<MealRecordScreen> createState() => _MealRecordScreenState();
}

class _MealRecordScreenState extends State<MealRecordScreen> {
  final _formKey = GlobalKey<FormState>();

  String _selectedMealType = '早餐';
  String _mealName = '';
  List<FoodItem> _foodItems = [];
  String _source = '自己做';
  int? _cookingTime;
  double? _cost;

  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('记录餐食'),
        backgroundColor: ThemeConfig.primaryColor,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveMeal,
            child: Text(
              '保存',
              style: TextStyle(
                color: _isSaving ? Colors.grey : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 餐次选择
              const Text(
                '餐次',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: AppConstants.MEAL_TIMES.map((mealType) {
                  final isSelected = _selectedMealType == mealType;
                  return ChoiceChip(
                    label: Text(mealType),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedMealType = mealType;
                        });
                      }
                    },
                    selectedColor: ThemeConfig.primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // 餐食名称
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '餐食名称',
                  hintText: '例如：健康早餐',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入餐食名称';
                  }
                  return null;
                },
                onChanged: (value) => _mealName = value,
              ),

              const SizedBox(height: 24),

              // 食物列表
              const Text(
                '食物列表',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              if (_foodItems.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Center(
                    child: Text(
                      '还没有添加食物',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                )
              else
                ..._foodItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final food = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.restaurant),
                      title: Text(food.name),
                      subtitle: Text(
                        '${food.amount.toStringAsFixed(0)}${food.unit} · ${food.nutrition.calories.toStringAsFixed(0)} kcal',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _foodItems.removeAt(index);
                          });
                        },
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 8),

              // 添加食物按钮
              OutlinedButton.icon(
                onPressed: _addFoodItem,
                icon: const Icon(Icons.add),
                label: const Text('添加食物'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ThemeConfig.primaryColor,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),

              const SizedBox(height: 24),

              // 来源
              const Text(
                '来源',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['自己做', '餐馆', '外卖'].map((source) {
                  final isSelected = _source == source;
                  return ChoiceChip(
                    label: Text(source),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _source = source;
                        });
                      }
                    },
                    selectedColor: ThemeConfig.primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // 烹饪时间（仅自己做时显示）
              if (_source == '自己做')
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: '烹饪时间（分钟）',
                    hintText: '例如：15',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _cookingTime = int.tryParse(value);
                  },
                ),

              if (_source == '自己做') const SizedBox(height: 24),

              // 成本
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '成本（元）',
                  hintText: '例如：10.5',
                  border: OutlineInputBorder(),
                  prefixText: '¥ ',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  _cost = double.tryParse(value);
                },
              ),

              const SizedBox(height: 32),

              // 营养摘要
              if (_foodItems.isNotEmpty)
                _buildNutritionSummary(),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建营养摘要
  Widget _buildNutritionSummary() {
    final totalNutrition = NutritionCalculator.calculateFoodListNutrition(_foodItems);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '营养摘要',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNutrientInfo(
                '热量',
                '${totalNutrition.calories.toStringAsFixed(0)} kcal',
                Colors.orange,
              ),
              _buildNutrientInfo(
                '蛋白质',
                '${totalNutrition.protein.toStringAsFixed(1)} g',
                Colors.blue,
              ),
              _buildNutrientInfo(
                '碳水',
                '${totalNutrition.carbs.toStringAsFixed(1)} g',
                Colors.amber,
              ),
              _buildNutrientInfo(
                '脂肪',
                '${totalNutrition.fat.toStringAsFixed(1)} g',
                Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建营养素信息
  Widget _buildNutrientInfo(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  /// 添加食物项
  void _addFoodItem() {
    showDialog(
      context: context,
      builder: (context) => AddFoodItemDialog(
        onAdd: (foodItem) {
          setState(() {
            _foodItems.add(foodItem);
          });
        },
      ),
    );
  }

  /// 保存餐食
  Future<void> _saveMeal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_foodItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请至少添加一项食物')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // 计算总营养
      final totalNutrition = NutritionCalculator.calculateFoodListNutrition(_foodItems);

      // 计算情绪ROI
      final emotionROI = EmotionROICalculator.calculateFromNutrition(totalNutrition);

      // 创建餐食对象
      final meal = Meal(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        mealType: _selectedMealType,
        name: _mealName,
        dateTime: DateTime.now(),
        foodItems: _foodItems,
        nutrition: totalNutrition,
        emotionROI: emotionROI.totalScore,
        emotionBenefit: emotionROI.primaryBenefit,
        source: _source,
        cookingTime: _cookingTime,
        totalCost: _cost,
      );

      // 保存
      final success = await context.read<HomeViewModel>().addMeal(meal);

      if (success) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('餐食记录成功！')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('保存失败，请重试')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}