// lib/presentation/widgets/add_food_item_dialog.dart
// Dart类文件

import 'package:flutter/material.dart';
import '../../data/models/food_item_model.dart';
import '../../data/models/nutrition_model.dart';
import '../../config/theme_config.dart';

/// 添加食物项对话框
class AddFoodItemDialog extends StatefulWidget {
  final Function(FoodItem) onAdd;

  const AddFoodItemDialog({
    Key? key,
    required this.onAdd,
  }) : super(key: key);

  @override
  State<AddFoodItemDialog> createState() => _AddFoodItemDialogState();
}

class _AddFoodItemDialogState extends State<AddFoodItemDialog> {
  final _formKey = GlobalKey<FormState>();

  String _name = '';
  double _amount = 100;
  String _unit = 'g';

  double _calories = 0;
  double _protein = 0;
  double _carbs = 0;
  double _fat = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('添加食物'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 食物名称
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '食物名称',
                  hintText: '例如：鸡蛋',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入食物名称';
                  }
                  return null;
                },
                onChanged: (value) => _name = value,
              ),

              const SizedBox(height: 16),

              // 份量和单位
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: '份量',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: '100',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入份量';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return '请输入有效份量';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        _amount = double.tryParse(value) ?? 100;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: '单位',
                        border: OutlineInputBorder(),
                      ),
                      value: _unit,
                      items: ['g', 'ml', '个', '份'].map((unit) {
                        return DropdownMenuItem(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _unit = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              const Divider(),

              const SizedBox(height: 8),

              const Text(
                '营养成分（估算）',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 16),

              // 热量
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '热量 (kcal)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                initialValue: '0',
                validator: (value) {
                  final calories = double.tryParse(value ?? '');
                  if (calories == null || calories < 0) {
                    return '请输入有效热量';
                  }
                  return null;
                },
                onChanged: (value) {
                  _calories = double.tryParse(value) ?? 0;
                },
              ),

              const SizedBox(height: 16),

              // 蛋白质
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '蛋白质 (g)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                initialValue: '0',
                onChanged: (value) {
                  _protein = double.tryParse(value) ?? 0;
                },
              ),

              const SizedBox(height: 16),

              // 碳水
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '碳水化合物 (g)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                initialValue: '0',
                onChanged: (value) {
                  _carbs = double.tryParse(value) ?? 0;
                },
              ),

              const SizedBox(height: 16),

              // 脂肪
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '脂肪 (g)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                initialValue: '0',
                onChanged: (value) {
                  _fat = double.tryParse(value) ?? 0;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _addFood,
          style: ElevatedButton.styleFrom(
            backgroundColor: ThemeConfig.primaryColor,
          ),
          child: const Text('添加'),
        ),
      ],
    );
  }

  /// 添加食物
  void _addFood() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final nutrition = Nutrition(
      calories: _calories,
      protein: _protein,
      carbs: _carbs,
      fat: _fat,
    );

    final foodItem = FoodItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _name,
      amount: _amount,
      unit: _unit,
      nutrition: nutrition,
    );

    widget.onAdd(foodItem);
    Navigator.pop(context);
  }
}