// lib/presentation/screens/settings_screen.dart
// Dart类文件

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_viewmodel.dart';
import '../../config/theme_config.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: ThemeConfig.primaryColor,
      ),
      body: Consumer<UserViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = viewModel.currentUser;
          if (user == null) {
            return const Center(child: Text('加载失败'));
          }

          return ListView(
            children: [
              _buildSectionHeader('个人信息'),
              _buildListTile(
                icon: Icons.person,
                title: '基本信息',
                subtitle: _getBasicInfoSubtitle(user),
                onTap: () => _showBasicInfoDialog(viewModel),
                isIncomplete: viewModel.isFieldIncomplete('basicInfo'),
              ),

              const Divider(height: 1),

              _buildSectionHeader('健康目标'),
              _buildListTile(
                icon: Icons.flag,
                title: '健康目标',
                subtitle: user.healthGoal,
                onTap: () => _showHealthGoalDialog(viewModel),
                isIncomplete: viewModel.isFieldIncomplete('healthGoal'),
              ),
              _buildListTile(
                icon: Icons.health_and_safety,
                title: '健康状况',
                subtitle: user.getHealthConditionsDisplay(),
                onTap: () => _showHealthConditionsDialog(viewModel),
                isIncomplete: viewModel.isFieldIncomplete('healthConditions'),
              ),

              const Divider(height: 1),

              _buildSectionHeader('饮食偏好'),
              _buildListTile(
                icon: Icons.restaurant,
                title: '餐食来源',
                subtitle: _getMealSourceText(user.defaultMealSource),
                onTap: () => _showMealSourceDialog(viewModel),
                isIncomplete: viewModel.isFieldIncomplete('mealSource'),
              ),
              _buildListTile(
                icon: Icons.people,
                title: '就餐方式',
                subtitle: user.defaultDiningStyle,
                onTap: () => _showDiningStyleDialog(viewModel),
                isIncomplete: viewModel.isFieldIncomplete('diningStyle'),
              ),
              _buildListTile(
                icon: Icons.fastfood,
                title: '菜系偏好',
                subtitle: user.preferredCuisines.join('、'),
                onTap: () => _showCuisinePreferenceDialog(viewModel),
                isIncomplete: viewModel.isFieldIncomplete('cuisines'),
              ),
              _buildListTile(
                icon: Icons.cookie,
                title: '零食偏好',
                subtitle: user.snackFrequency,
                onTap: () => _showSnackFrequencyDialog(viewModel),
                isIncomplete: viewModel.isFieldIncomplete('snack'),
              ),

              const Divider(height: 1),

              _buildSectionHeader('忌口设置'),
              _buildListTile(
                icon: Icons.block,
                title: '忌口管理',
                subtitle: _getAvoidanceSubtitle(user),
                onTap: () => _showAvoidanceDialog(viewModel),
                isIncomplete: viewModel.isFieldIncomplete('avoidance'),
              ),
              _buildSwitchTile(
                icon: Icons.eco,
                title: '素食者',
                value: user.isVegetarian,
                onChanged: (value) async {
                  await viewModel.updateVegetarianStatus(value);
                },
              ),
              _buildSwitchTile(
                icon: Icons.water_drop,
                title: '需要控制血糖',
                value: user.hasHighBloodSugar,
                onChanged: (value) async {
                  await viewModel.updateHighBloodSugarStatus(value);
                },
              ),

              const Divider(height: 1),

              _buildSectionHeader('其他设置'),
              _buildListTile(
                icon: Icons.notifications,
                title: '提醒设置',
                subtitle: '餐食提醒、饮水提醒等',
                onTap: () {
                  // TODO: 跳转到提醒设置页面
                },
              ),
              _buildListTile(
                icon: Icons.language,
                title: '语言',
                subtitle: user.language == 'zh' ? '简体中文' : 'English',
                onTap: () {
                  // TODO: 语言切换
                },
              ),
              _buildListTile(
                icon: Icons.info,
                title: '关于',
                subtitle: 'Healthy Eats v1.0.0',
                onTap: () {
                  // TODO: 关于页面
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.grey[100],
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    bool isIncomplete = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isIncomplete ? Colors.orange[700] : ThemeConfig.primaryColor,
      ),
      title: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: isIncomplete ? Colors.orange[900] : null,
              fontWeight: isIncomplete ? FontWeight.w600 : null,
            ),
          ),
          if (isIncomplete) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '未完善',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.orange[900],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: isIncomplete ? Colors.orange[700] : null,
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right,
        color: isIncomplete ? Colors.orange[700] : null,
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: ThemeConfig.primaryColor),
      title: Text(title),
      value: value,
      onChanged: onChanged,
      activeColor: ThemeConfig.primaryColor,
    );
  }

  String _getBasicInfoSubtitle(user) {
    List<String> parts = [];

    if (user.gender != null) parts.add(user.gender!);
    if (user.age != null) parts.add('${user.age}岁');
    if (user.height != null) parts.add('${user.height}cm');
    if (user.weight != null) parts.add('${user.weight}kg');
    if (user.city != null && user.city!.isNotEmpty) parts.add(user.city!);

    return parts.isEmpty ? '未设置' : parts.join(' / ');
  }

  String _getMealSourceText(int level) {
    const texts = {
      1: '基本外食',
      2: '较多外食',
      3: '外食与自制各半',
      4: '较多自己做',
      5: '基本自己做',
    };
    return texts[level] ?? '未设置';
  }

  String _getAvoidanceSubtitle(user) {
    int count = user.avoidVegetables.length +
        user.avoidFruits.length +
        user.avoidMeats.length +
        user.avoidSeafood.length;

    return count > 0 ? '已设置 $count 项忌口' : '无忌口';
  }

  Future<void> _showBasicInfoDialog(UserViewModel viewModel) async {
    final user = viewModel.currentUser!;

    final genderController = TextEditingController(text: user.gender ?? '');
    final cityController = TextEditingController(text: user.city ?? '');
    final ageController = TextEditingController(text: user.age?.toString() ?? '');
    final heightController = TextEditingController(text: user.height?.toString() ?? '');
    final weightController = TextEditingController(text: user.weight?.toString() ?? '');

    String? selectedGender = user.gender;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('基本信息'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedGender,
                  decoration: const InputDecoration(
                    labelText: '性别',
                    border: OutlineInputBorder(),
                  ),
                  items: ['男', '女', '其他'].map((gender) {
                    return DropdownMenuItem(
                      value: gender,
                      child: Text(gender),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedGender = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: cityController,
                  decoration: const InputDecoration(
                    labelText: '城市',
                    hintText: '如：北京、上海、旧金山',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '年龄',
                    border: OutlineInputBorder(),
                    suffixText: '岁',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: heightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '身高',
                    border: OutlineInputBorder(),
                    suffixText: 'cm',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '体重',
                    border: OutlineInputBorder(),
                    suffixText: 'kg',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                await viewModel.updateBasicInfo(
                  gender: selectedGender,
                  city: cityController.text.trim().isNotEmpty ? cityController.text.trim() : null,
                  age: int.tryParse(ageController.text),
                  height: double.tryParse(heightController.text),
                  weight: double.tryParse(weightController.text),
                );
                if (mounted) Navigator.pop(context);
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showHealthGoalDialog(UserViewModel viewModel) async {
    final user = viewModel.currentUser!;
    String? selectedGoal = user.healthGoal;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('健康目标'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              '减脂',
              '增肌',
              '维持',
              '随意',
              '胡吃海塞',
              '清汤寡欲',
            ].map((goal) {
              return RadioListTile<String>(
                title: Text(goal),
                value: goal,
                groupValue: selectedGoal,
                onChanged: (value) {
                  setState(() {
                    selectedGoal = value;
                  });
                },
                activeColor: ThemeConfig.primaryColor,
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                if (selectedGoal != null) {
                  await viewModel.updateHealthGoal(selectedGoal!);
                }
                if (mounted) Navigator.pop(context);
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showHealthConditionsDialog(UserViewModel viewModel) async {
    final user = viewModel.currentUser!;
    List<String> selectedConditions = List.from(user.healthConditions);

    final availableConditions = [
      '无',
      '高血压',
      '高血脂',
      '高血糖/糖尿病',
      '甲亢',
      '甲减',
      '痛风',
      '肾病',
      '心脏病',
      '脂肪肝',
      '胃病',
      '其他',
    ];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('健康状况'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: availableConditions.map((condition) {
                final isSelected = selectedConditions.contains(condition);
                final isNone = condition == '无';

                return CheckboxListTile(
                  title: Text(condition),
                  subtitle: _getHealthConditionDescription(condition),
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      if (isNone) {
                        if (value == true) {
                          selectedConditions = ['无'];
                        }
                      } else {
                        if (value == true) {
                          selectedConditions.remove('无');
                          selectedConditions.add(condition);
                        } else {
                          selectedConditions.remove(condition);
                          if (selectedConditions.isEmpty) {
                            selectedConditions = ['无'];
                          }
                        }
                      }
                    });
                  },
                  activeColor: ThemeConfig.primaryColor,
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                await viewModel.updateHealthConditions(selectedConditions);
                if (mounted) Navigator.pop(context);
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _getHealthConditionDescription(String condition) {
    final descriptions = {
      '高血压': '避免高盐、腌制食品',
      '高血脂': '避免高脂肪、油腻食物',
      '高血糖/糖尿病': '避免高GI食物、甜食',
      '甲亢': '避免海带、紫菜等高碘食物',
      '痛风': '避免海鲜、动物内脏、啤酒',
      '肾病': '低蛋白、低盐饮食',
      '心脏病': '低脂、低盐饮食',
      '脂肪肝': '低脂、低糖饮食',
      '胃病': '避免刺激性食物',
    };

    final desc = descriptions[condition];
    if (desc == null) return null;

    return Text(
      desc,
      style: const TextStyle(fontSize: 11, color: Colors.grey),
    );
  }

  Future<void> _showMealSourceDialog(UserViewModel viewModel) async {
    final user = viewModel.currentUser!;
    int selectedSource = user.defaultMealSource;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('餐食来源'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [1, 2, 3, 4, 5].map((level) {
              return RadioListTile<int>(
                title: Text(_getMealSourceText(level)),
                subtitle: Text(_getMealSourceDescription(level)),
                value: level,
                groupValue: selectedSource,
                onChanged: (value) {
                  setState(() {
                    selectedSource = value!;
                  });
                },
                activeColor: ThemeConfig.primaryColor,
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                await viewModel.updateDefaultMealSource(selectedSource);
                if (mounted) Navigator.pop(context);
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  String _getMealSourceDescription(int level) {
    const descriptions = {
      1: '几乎所有餐食都在外面吃',
      2: '大部分餐食在外面吃',
      3: '外食和自己做各占一半',
      4: '大部分餐食自己做',
      5: '几乎所有餐食都自己做',
    };
    return descriptions[level] ?? '';
  }

  Future<void> _showDiningStyleDialog(UserViewModel viewModel) async {
    final user = viewModel.currentUser!;
    String? selectedStyle = user.defaultDiningStyle;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('就餐方式'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              '主要自己吃',
              '经常和朋友家人',
              '经常和同事',
            ].map((style) {
              return RadioListTile<String>(
                title: Text(style),
                value: style,
                groupValue: selectedStyle,
                onChanged: (value) {
                  setState(() {
                    selectedStyle = value;
                  });
                },
                activeColor: ThemeConfig.primaryColor,
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                if (selectedStyle != null) {
                  await viewModel.updateDefaultDiningStyle(selectedStyle!);
                }
                if (mounted) Navigator.pop(context);
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCuisinePreferenceDialog(UserViewModel viewModel) async {
    final user = viewModel.currentUser!;
    List<String> selectedCuisines = List.from(user.preferredCuisines);

    final availableCuisines = [
      '中餐',
      '川菜',
      '粤菜',
      '湘菜',
      '鲁菜',
      '西餐',
      '日餐',
      '韩餐',
      '东南亚菜',
      '其他',
    ];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('菜系偏好（可多选）'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: availableCuisines.map((cuisine) {
                return CheckboxListTile(
                  title: Text(cuisine),
                  value: selectedCuisines.contains(cuisine),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        selectedCuisines.add(cuisine);
                      } else {
                        selectedCuisines.remove(cuisine);
                      }
                    });
                  },
                  activeColor: ThemeConfig.primaryColor,
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                if (selectedCuisines.isNotEmpty) {
                  await viewModel.updatePreferredCuisines(selectedCuisines);
                }
                if (mounted) Navigator.pop(context);
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSnackFrequencyDialog(UserViewModel viewModel) async {
    final user = viewModel.currentUser!;
    String? selectedFrequency = user.snackFrequency;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('零食偏好'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              '很少吃',
              '偶尔吃',
              '经常吃',
              '每天都吃',
            ].map((frequency) {
              return RadioListTile<String>(
                title: Text(frequency),
                value: frequency,
                groupValue: selectedFrequency,
                onChanged: (value) {
                  setState(() {
                    selectedFrequency = value;
                  });
                },
                activeColor: ThemeConfig.primaryColor,
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                if (selectedFrequency != null) {
                  await viewModel.updateSnackFrequency(selectedFrequency!);
                }
                if (mounted) Navigator.pop(context);
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAvoidanceDialog(UserViewModel viewModel) async {
    final user = viewModel.currentUser!;

    List<String> selectedVegetables = List.from(user.avoidVegetables);
    List<String> selectedFruits = List.from(user.avoidFruits);
    List<String> selectedMeats = List.from(user.avoidMeats);
    List<String> selectedSeafood = List.from(user.avoidSeafood);

    final vegetables = ['芹菜', '香菜', '洋葱', '大蒜', '韭菜', '茄子', '苦瓜', '青椒'];
    final fruits = ['榴莲', '芒果', '菠萝', '猕猴桃', '火龙果', '柚子'];
    final meats = ['猪肉', '牛肉', '羊肉', '鸡肉', '鸭肉', '内脏'];
    final seafood = ['虾', '蟹', '贝类', '鱼', '海参', '海蜇'];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => DefaultTabController(
          length: 4,
          child: AlertDialog(
            title: const Text('忌口管理'),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: Column(
                children: [
                  const TabBar(
                    labelColor: ThemeConfig.primaryColor,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: ThemeConfig.primaryColor,
                    tabs: [
                      Tab(text: '蔬菜'),
                      Tab(text: '水果'),
                      Tab(text: '肉类'),
                      Tab(text: '海鲜'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildAvoidanceList(vegetables, selectedVegetables, setState),
                        _buildAvoidanceList(fruits, selectedFruits, setState),
                        _buildAvoidanceList(meats, selectedMeats, setState),
                        _buildAvoidanceList(seafood, selectedSeafood, setState),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () async {
                  await viewModel.updateAvoidVegetables(selectedVegetables);
                  await viewModel.updateAvoidFruits(selectedFruits);
                  await viewModel.updateAvoidMeats(selectedMeats);
                  await viewModel.updateAvoidSeafood(selectedSeafood);
                  if (mounted) Navigator.pop(context);
                },
                child: const Text('保存'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvoidanceList(
    List<String> items,
    List<String> selected,
    StateSetter setState,
  ) {
    return ListView(
      children: items.map((item) {
        return CheckboxListTile(
          title: Text(item),
          value: selected.contains(item),
          onChanged: (value) {
            setState(() {
              if (value == true) {
                selected.add(item);
              } else {
                selected.remove(item);
              }
            });
          },
          activeColor: ThemeConfig.primaryColor,
        );
      }).toList(),
    );
  }
}