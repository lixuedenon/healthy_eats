// lib/domain/ai_engine/logic/preference_logic.dart
// Dart类文件

/// 饮食偏好逻辑判断类
///
/// 处理用户的菜系偏好、零食偏好等
class PreferenceLogic {
  // ==================== 菜系轮换 ====================

  /// 每天轮换不同菜系
  ///
  /// 参数：
  /// - cuisines: 用户偏好的菜系列表
  /// - dayOfWeek: 星期几（1-7）
  static String rotateCuisine(List<String> cuisines, int dayOfWeek) {
    if (cuisines.isEmpty) return '中餐';

    // 使用日期作为索引，循环选择菜系
    final index = (dayOfWeek - 1) % cuisines.length;
    return cuisines[index];
  }

  /// 为一周分配不同菜系
  ///
  /// 返回：Map<int, String>，key是星期几（1-7），value是菜系
  static Map<int, String> assignWeeklyCuisines(List<String> cuisines) {
    Map<int, String> weeklyPlan = {};

    if (cuisines.isEmpty) {
      // 如果没有偏好，默认都是中餐
      for (int i = 1; i <= 7; i++) {
        weeklyPlan[i] = '中餐';
      }
      return weeklyPlan;
    }

    for (int day = 1; day <= 7; day++) {
      weeklyPlan[day] = rotateCuisine(cuisines, day);
    }

    return weeklyPlan;
  }

  // ==================== 零食偏好处理 ====================

  /// 根据零食偏好决定是否推荐零食
  static bool shouldRecommendSnack(String snackFrequency) {
    return snackFrequency != '不吃零食';
  }

  /// 获取每周零食推荐次数
  static int getWeeklySnackCount(String snackFrequency) {
    switch (snackFrequency) {
      case '不吃零食':
        return 0;
      case '很少吃':
        return 2; // 每周2次
      case '经常吃':
        return 7; // 每天1次
      default:
        return 0;
    }
  }

  /// 获取零食推荐的AI提示词
  static String getSnackPromptDescription(String snackFrequency) {
    switch (snackFrequency) {
      case '不吃零食':
        return '用户不吃零食，请不要推荐任何零食。';
      case '很少吃':
        return '用户很少吃零食（每周1-2次），请推荐健康、营养的零食，'
               '如坚果、水果、酸奶等。控制在150kcal以内。';
      case '经常吃':
        return '用户经常吃零食（每天），请推荐多样化的健康零食，'
               '包括坚果、水果、全麦饼干、酸奶等。注意控制每次热量在150-200kcal。';
      default:
        return '';
    }
  }

  /// 获取健康零食建议列表
  static List<String> getHealthySnackSuggestions() {
    return [
      '坚果组合（杏仁、核桃、腰果）',
      '新鲜水果（苹果、香蕉、橙子）',
      '无糖酸奶',
      '全麦饼干',
      '黑巧克力（可可含量>70%）',
      '胡萝卜条配鹰嘴豆泥',
      '煮鸡蛋',
      '奇亚籽布丁',
    ];
  }

  // ==================== 菜系特点分析 ====================

  /// 获取菜系的特点描述（用于AI提示）
  static String getCuisineCharacteristics(String cuisine) {
    switch (cuisine) {
      case '中餐':
        return '中餐特点：注重色香味俱全，烹饪方法多样（炒、蒸、煮、炖等），'
               '讲究营养搭配和食材的新鲜度。';
      case '法餐':
        return '法餐特点：精致优雅，注重酱汁调配，食材考究，'
               '强调原汁原味和精细烹饪技巧。';
      case '意餐':
        return '意餐特点：以面食为主，橄榄油、番茄、奶酪为常用食材，'
               '口味清淡，注重食材本身的味道。';
      case '日料':
        return '日料特点：清淡健康，注重食材新鲜度和季节性，'
               '摆盘精致，少油少盐，强调原味。';
      case '韩餐':
        return '韩餐特点：泡菜、烧烤为特色，口味偏辣和咸，'
               '注重发酵食品和蔬菜搭配。';
      case '东南亚':
        return '东南亚菜特点：香料丰富，口味酸辣咸鲜并重，'
               '常用椰奶、香茅、咖喱等调味。';
      case '拉美':
        return '拉美菜特点：豆类、玉米、辣椒为主要食材，'
               '口味浓郁，喜用香料和烧烤。';
      case '中东':
        return '中东菜特点：橄榄油、豆类、羊肉为常用食材，'
               '香料丰富，口味独特。';
      case '印度':
        return '印度菜特点：咖喱为主，香料种类繁多，'
               '素食选择丰富，口味浓郁偏辣。';
      case '美式':
        return '美式餐特点：份量大，烹饪简单直接，'
               '汉堡、牛排、烧烤为特色，口味偏甜和咸。';
      default:
        return '根据该菜系的传统特色进行推荐。';
    }
  }

  /// 获取菜系的典型菜品示例
  static List<String> getCuisineExamples(String cuisine) {
    switch (cuisine) {
      case '中餐':
        return ['宫保鸡丁', '麻婆豆腐', '红烧肉', '清蒸鱼', '糖醋里脊'];
      case '法餐':
        return ['法式洋葱汤', '鹅肝', '红酒炖牛肉', '尼斯沙拉'];
      case '意餐':
        return ['意大利面', '披萨', '提拉米苏', '意式烩饭'];
      case '日料':
        return ['寿司', '拉面', '天妇罗', '照烧鸡', '味增汤'];
      case '韩餐':
        return ['石锅拌饭', '韩式烤肉', '部队火锅', '泡菜煎饼'];
      case '东南亚':
        return ['泰式咖喱', '越南河粉', '新加坡海南鸡饭', '印尼炒饭'];
      case '拉美':
        return ['墨西哥卷饼', '巴西烤肉', '牛油果沙拉', '玉米饼'];
      case '中东':
        return ['烤肉串', '鹰嘴豆泥', '塔布勒沙拉', '皮塔饼'];
      case '印度':
        return ['咖喱鸡', '印度飞饼', '坦都里烤鸡', '玛萨拉茶'];
      case '美式':
        return ['汉堡', '牛排', '炸鸡', '热狗', '烤肋排'];
      default:
        return [];
    }
  }

  // ==================== AI提示词辅助 ====================

  /// 获取菜系偏好的完整AI提示词
  static String getFullCuisinePrompt(List<String> preferredCuisines, String todayCuisine) {
    if (preferredCuisines.isEmpty) {
      return '用户没有特定菜系偏好，可以推荐各类健康餐食。';
    }

    String prompt = '用户偏好的菜系：${preferredCuisines.join('、')}\n';
    prompt += '今日推荐菜系：$todayCuisine\n';
    prompt += '菜系特点：${getCuisineCharacteristics(todayCuisine)}\n';

    final examples = getCuisineExamples(todayCuisine);
    if (examples.isNotEmpty) {
      prompt += '典型菜品参考：${examples.join('、')}\n';
    }

    prompt += '\n请基于以上菜系特点，推荐符合用户健康目标的餐食。';

    return prompt;
  }

  /// 验证菜系列表的有效性
  static List<String> validateCuisines(List<String> cuisines) {
    const validCuisines = [
      '中餐', '法餐', '意餐', '日料', '韩餐',
      '东南亚', '拉美', '中东', '印度', '美式',
    ];

    return cuisines.where((c) => validCuisines.contains(c)).toList();
  }

  /// 获取推荐的菜系组合
  static List<String> getRecommendedCuisineSet() {
    return ['中餐', '日料', '意餐']; // 默认推荐组合
  }
}