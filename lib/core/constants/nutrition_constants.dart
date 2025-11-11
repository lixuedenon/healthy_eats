// lib/core/constants/nutrition_constants.dart
// Dart类文件

/// 营养素相关常量配置类
class NutritionConstants {
  // ==================== 宏量营养素 ====================

  /// 每克蛋白质的热量（kcal）
  static const int CALORIES_PER_GRAM_PROTEIN = 4;

  /// 每克碳水化合物的热量（kcal）
  static const int CALORIES_PER_GRAM_CARBS = 4;

  /// 每克脂肪的热量（kcal）
  static const int CALORIES_PER_GRAM_FAT = 9;

  // ==================== 情绪调节相关营养素 ====================

  /// 镁 - 抗焦虑、助眠
  static const String NUTRIENT_MAGNESIUM = '镁';
  static const String MAGNESIUM_BENEFIT = '抗焦虑、助眠';
  static const List<String> MAGNESIUM_RICH_FOODS = [
    '深绿色蔬菜',
    '坚果',
    '全谷物',
    '香蕉',
    '黑巧克力',
  ];

  /// B族维生素 - 提升情绪、抗疲劳
  static const String NUTRIENT_VITAMIN_B = 'B族维生素';
  static const String VITAMIN_B_BENEFIT = '提升情绪、抗疲劳';
  static const List<String> VITAMIN_B_RICH_FOODS = [
    '全谷物',
    '鸡蛋',
    '牛奶',
    '瘦肉',
    '豆类',
  ];

  /// 色氨酸 - 生成血清素、改善情绪和睡眠
  static const String NUTRIENT_TRYPTOPHAN = '色氨酸';
  static const String TRYPTOPHAN_BENEFIT = '改善情绪和睡眠';
  static const List<String> TRYPTOPHAN_RICH_FOODS = [
    '火鸡肉',
    '鸡肉',
    '牛奶',
    '奶酪',
    '坚果',
    '香蕉',
  ];

  /// Omega-3脂肪酸 - 抗炎、保护大脑
  static const String NUTRIENT_OMEGA3 = 'Omega-3';
  static const String OMEGA3_BENEFIT = '抗炎、保护大脑';
  static const List<String> OMEGA3_RICH_FOODS = [
    '深海鱼',
    '亚麻籽',
    '核桃',
    '奇亚籽',
  ];

  /// 维生素C - 抗氧化、提升免疫力
  static const String NUTRIENT_VITAMIN_C = '维生素C';
  static const String VITAMIN_C_BENEFIT = '抗氧化、提升免疫力';
  static const List<String> VITAMIN_C_RICH_FOODS = [
    '柑橘类水果',
    '草莓',
    '西兰花',
    '彩椒',
    '猕猴桃',
  ];

  /// 铁 - 预防贫血、提升活力
  static const String NUTRIENT_IRON = '铁';
  static const String IRON_BENEFIT = '预防贫血、提升活力';
  static const List<String> IRON_RICH_FOODS = [
    '红肉',
    '菠菜',
    '豆类',
    '动物肝脏',
  ];

  /// 膳食纤维 - 促进消化、稳定血糖
  static const String NUTRIENT_FIBER = '膳食纤维';
  static const String FIBER_BENEFIT = '促进消化、稳定血糖';
  static const List<String> FIBER_RICH_FOODS = [
    '全谷物',
    '蔬菜',
    '水果',
    '豆类',
  ];

  /// 钙 - 强健骨骼、稳定神经
  static const String NUTRIENT_CALCIUM = '钙';
  static const String CALCIUM_BENEFIT = '强健骨骼、稳定神经';
  static const List<String> CALCIUM_RICH_FOODS = [
    '牛奶',
    '酸奶',
    '奶酪',
    '豆腐',
    '深绿色蔬菜',
  ];

  // ==================== 特殊饮食相关 ====================

  /// 低GI食物（适合血糖偏高人群）
  static const List<String> LOW_GI_FOODS = [
    '糙米',
    '燕麦',
    '全麦面包',
    '红薯',
    '紫薯',
    '豆类',
    '大部分蔬菜',
    '苹果',
    '梨',
  ];

  /// 高GI食物（血糖偏高人群应避免）
  static const List<String> HIGH_GI_FOODS = [
    '白米饭',
    '白面包',
    '精制糖',
    '糕点',
    '含糖饮料',
    '土豆泥',
    '西瓜',
  ];

  /// 优质植物蛋白来源（适合素食者）
  static const List<String> PLANT_PROTEIN_SOURCES = [
    '豆腐',
    '豆制品',
    '扁豆',
    '鹰嘴豆',
    '坚果',
    '种子',
    '藜麦',
  ];

  // ==================== 营养素符号映射 ====================

  /// 营养素充足的符号
  static const String SYMBOL_ABUNDANT = '↑';

  /// 营养素适量的符号
  static const String SYMBOL_ADEQUATE = '✓';

  /// 营养素不足的符号
  static const String SYMBOL_INSUFFICIENT = '↓';

  // ==================== 情绪ROI权重系数 ====================

  /// 镁含量对情绪ROI的权重
  static const double WEIGHT_MAGNESIUM = 0.25;

  /// B族维生素对情绪ROI的权重
  static const double WEIGHT_VITAMIN_B = 0.25;

  /// 色氨酸对情绪ROI的权重
  static const double WEIGHT_TRYPTOPHAN = 0.20;

  /// Omega-3对情绪ROI的权重
  static const double WEIGHT_OMEGA3 = 0.15;

  /// 其他营养素对情绪ROI的权重
  static const double WEIGHT_OTHER = 0.15;

  // ==================== 工具方法 ====================

  /// 根据含量判断营养素符号
  static String getNutrientSymbol(double amount, double standard) {
    double ratio = amount / standard;
    if (ratio >= 0.8) return SYMBOL_ABUNDANT;
    if (ratio >= 0.5) return SYMBOL_ADEQUATE;
    return SYMBOL_INSUFFICIENT;
  }

  /// 获取营养素富含该营养的食物列表
  static List<String> getRichFoods(String nutrient) {
    switch (nutrient) {
      case NUTRIENT_MAGNESIUM:
        return MAGNESIUM_RICH_FOODS;
      case NUTRIENT_VITAMIN_B:
        return VITAMIN_B_RICH_FOODS;
      case NUTRIENT_TRYPTOPHAN:
        return TRYPTOPHAN_RICH_FOODS;
      case NUTRIENT_OMEGA3:
        return OMEGA3_RICH_FOODS;
      case NUTRIENT_VITAMIN_C:
        return VITAMIN_C_RICH_FOODS;
      case NUTRIENT_IRON:
        return IRON_RICH_FOODS;
      case NUTRIENT_FIBER:
        return FIBER_RICH_FOODS;
      case NUTRIENT_CALCIUM:
        return CALCIUM_RICH_FOODS;
      default:
        return [];
    }
  }

  /// 获取营养素的健康益处
  static String getNutrientBenefit(String nutrient) {
    switch (nutrient) {
      case NUTRIENT_MAGNESIUM:
        return MAGNESIUM_BENEFIT;
      case NUTRIENT_VITAMIN_B:
        return VITAMIN_B_BENEFIT;
      case NUTRIENT_TRYPTOPHAN:
        return TRYPTOPHAN_BENEFIT;
      case NUTRIENT_OMEGA3:
        return OMEGA3_BENEFIT;
      case NUTRIENT_VITAMIN_C:
        return VITAMIN_C_BENEFIT;
      case NUTRIENT_IRON:
        return IRON_BENEFIT;
      case NUTRIENT_FIBER:
        return FIBER_BENEFIT;
      case NUTRIENT_CALCIUM:
        return CALCIUM_BENEFIT;
      default:
        return '';
    }
  }
}