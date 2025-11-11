// lib/domain/ai_engine/logic/special_diet_logic.dart
// Dart类文件

/// 特殊饮食逻辑判断类
///
/// 处理素食者、血糖偏高等特殊饮食需求
class SpecialDietLogic {
  // ==================== 素食者逻辑 ====================

  /// 获取素食者的饮食约束
  static Map<String, dynamic> getVegetarianConstraints() {
    return {
      'avoidAllMeat': true,
      'avoidAllSeafood': true,
      'avoidAnimalProducts': ['肉类', '鱼类', '海鲜', '禽类'],
      'proteinSources': ['豆腐', '豆制品', '坚果', '鸡蛋', '奶制品', '藜麦', '扁豆'],
      'emphasize': '优质植物蛋白',
      'nutrients_to_supplement': ['维生素B12', '铁', '锌', 'Omega-3'],
      'description': '素食饮食，避免所有肉类和海鲜，通过豆制品和坚果补充蛋白质',
    };
  }

  /// 获取素食者的推荐食材列表
  static List<String> getVegetarianProteinSources() {
    return [
      '豆腐',
      '豆浆',
      '豆制品（豆干、腐竹等）',
      '鹰嘴豆',
      '扁豆',
      '黑豆',
      '红豆',
      '坚果（杏仁、核桃、腰果）',
      '种子（奇亚籽、亚麻籽）',
      '藜麦',
      '鸡蛋（如果吃蛋）',
      '奶制品（如果吃奶）',
    ];
  }

  /// 素食者的典型餐食建议
  static List<String> getVegetarianMealExamples() {
    return [
      '豆腐炒时蔬 + 糙米饭',
      '扁豆咖喱 + 印度飞饼',
      '藜麦沙拉配鹰嘴豆',
      '素炒三丝 + 蒸蛋羹',
      '豆浆 + 全麦面包 + 坚果',
    ];
  }

  // ==================== 血糖偏高逻辑 ====================

  /// 获取血糖偏高的饮食约束
  static Map<String, dynamic> getHighBloodSugarConstraints() {
    return {
      'lowGI': true, // 低升糖指数
      'avoidRefinedCarbs': true, // 避免精制碳水
      'preferredCarbs': ['糙米', '燕麦', '全麦', '红薯', '紫薯', '藜麦'],
      'avoidFoods': ['白米饭', '白面包', '精制糖', '糕点', '含糖饮料', '土豆泥'],
      'emphasize': '控制碳水总量，选择低GI食物',
      'portionControl': '每餐碳水不超过50g',
      'description': '低GI饮食，控制血糖波动，避免精制碳水化合物',
    };
  }

  /// 获取低GI食物列表
  static List<String> getLowGIFoods() {
    return [
      // 主食类
      '糙米',
      '燕麦',
      '全麦面包',
      '荞麦面',
      '藜麦',
      // 薯类
      '红薯',
      '紫薯',
      '山药',
      // 豆类
      '绿豆',
      '红豆',
      '黑豆',
      '扁豆',
      // 蔬菜
      '大部分绿叶蔬菜',
      '西兰花',
      '花菜',
      '芦笋',
      // 水果
      '苹果',
      '梨',
      '樱桃',
      '柚子',
      '草莓',
    ];
  }

  /// 获取高GI食物列表（应避免）
  static List<String> getHighGIFoods() {
    return [
      '白米饭',
      '白面包',
      '馒头',
      '面条（非全麦）',
      '土豆泥',
      '玉米片',
      '糕点',
      '饼干',
      '含糖饮料',
      '西瓜',
      '菠萝',
    ];
  }

  /// 血糖偏高的典型餐食建议
  static List<String> getBloodSugarFriendlyMealExamples() {
    return [
      '燕麦粥 + 煮鸡蛋 + 坚果',
      '糙米饭 + 清蒸鱼 + 西兰花',
      '全麦面包 + 牛油果 + 蔬菜沙拉',
      '藜麦饭 + 鸡胸肉 + 炒青菜',
      '荞麦面 + 瘦肉 + 蔬菜',
    ];
  }

  // ==================== 综合处理 ====================

  /// 应用特殊饮食约束
  static Map<String, dynamic> applyConstraints({
    required bool isVegetarian,
    required bool hasHighBloodSugar,
  }) {
    Map<String, dynamic> constraints = {
      'hasSpecialDiet': isVegetarian || hasHighBloodSugar,
      'vegetarian': isVegetarian,
      'highBloodSugar': hasHighBloodSugar,
    };

    if (isVegetarian) {
      constraints['vegetarianConstraints'] = getVegetarianConstraints();
    }

    if (hasHighBloodSugar) {
      constraints['bloodSugarConstraints'] = getHighBloodSugarConstraints();
    }

    // 如果同时是素食者和血糖偏高
    if (isVegetarian && hasHighBloodSugar) {
      constraints['combinedNote'] = '需要同时满足素食和低GI要求，'
                                   '优先选择低GI的植物蛋白来源';
    }

    return constraints;
  }

  // ==================== AI提示词辅助 ====================

  /// 获取素食者的AI提示词
  static String getVegetarianPromptDescription() {
    return '''
重要：用户是素食者
- 严格避免所有肉类（猪肉、牛肉、羊肉、鸡肉、鸭肉等）
- 严格避免所有海鲜（鱼、虾、蟹、贝类等）
- 蛋白质来源：${getVegetarianProteinSources().take(6).join('、')}
- 特别注意补充：维生素B12、铁、锌、Omega-3

推荐餐食示例：
${getVegetarianMealExamples().take(3).map((e) => '- $e').join('\n')}

请确保所有推荐的菜品都符合素食要求。
''';
  }

  /// 获取血糖偏高的AI提示词
  static String getBloodSugarPromptDescription() {
    return '''
重要：用户血糖偏高，需要低GI饮食
- 选择低升糖指数（GI）的食物
- 优先推荐主食：糙米、燕麦、全麦、红薯、紫薯
- 严格避免：白米饭、白面包、精制糖、糕点、含糖饮料
- 控制每餐碳水化合物摄入量（不超过50g）
- 增加膳食纤维和蛋白质，延缓血糖上升

推荐低GI食物：
主食：${getLowGIFoods().where((e) => ['糙米', '燕麦', '全麦面包', '红薯'].contains(e)).join('、')}
蔬菜：绿叶蔬菜、西兰花、花菜
水果：苹果、梨、草莓（适量）

推荐餐食示例：
${getBloodSugarFriendlyMealExamples().take(3).map((e) => '- $e').join('\n')}

请确保所有推荐的菜品都符合低GI要求。
''';
  }

  /// 获取完整的特殊饮食AI提示词
  static String getFullSpecialDietPrompt({
    required bool isVegetarian,
    required bool hasHighBloodSugar,
  }) {
    if (!isVegetarian && !hasHighBloodSugar) {
      return '用户没有特殊饮食要求。';
    }

    String prompt = '=== 特殊饮食要求 ===\n\n';

    if (isVegetarian) {
      prompt += getVegetarianPromptDescription();
      prompt += '\n\n';
    }

    if (hasHighBloodSugar) {
      prompt += getBloodSugarPromptDescription();
      prompt += '\n\n';
    }

    if (isVegetarian && hasHighBloodSugar) {
      prompt += '''
特别注意：用户同时是素食者且血糖偏高
- 需要找到既符合素食要求又是低GI的食物
- 推荐：豆制品 + 糙米/燕麦 + 绿叶蔬菜 + 坚果
- 避免高GI的素食（如白米饭、白面包、精制糖）
- 确保蛋白质摄入充足（通过豆制品和坚果）
''';
    }

    return prompt;
  }

  // ==================== 食物验证 ====================

  /// 检查食物是否适合素食者
  static bool isSuitableForVegetarian(List<String> ingredients) {
    const meatKeywords = [
      '肉', '鸡', '鸭', '猪', '牛', '羊', '鱼', '虾', '蟹', '贝',
      '海鲜', '禽', '鸟', '鹅', '兔', '驴', '马',
    ];

    for (String ingredient in ingredients) {
      for (String keyword in meatKeywords) {
        if (ingredient.contains(keyword)) {
          return false;
        }
      }
    }

    return true;
  }

  /// 检查食物是否适合血糖偏高人群
  static bool isSuitableForHighBloodSugar(List<String> ingredients) {
    final highGIFoods = getHighGIFoods();

    for (String ingredient in ingredients) {
      for (String avoided in highGIFoods) {
        if (ingredient.contains(avoided) || avoided.contains(ingredient)) {
          return false;
        }
      }
    }

    return true;
  }

  /// 综合检查食物是否适合特殊饮食要求
  static bool isFoodSuitable({
    required List<String> ingredients,
    required bool isVegetarian,
    required bool hasHighBloodSugar,
  }) {
    if (isVegetarian && !isSuitableForVegetarian(ingredients)) {
      return false;
    }

    if (hasHighBloodSugar && !isSuitableForHighBloodSugar(ingredients)) {
      return false;
    }

    return true;
  }
}