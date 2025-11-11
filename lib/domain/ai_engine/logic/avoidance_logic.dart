// lib/domain/ai_engine/logic/avoidance_logic.dart
// Dart类文件

/// 忌口逻辑判断类
///
/// 处理用户的忌口食材，确保推荐的餐食中不包含这些食材
class AvoidanceLogic {
  // ==================== 忌口验证 ====================

  /// 检查某个食材是否在忌口列表中
  static bool isAvoided(String ingredient, List<String> avoidList) {
    // 完全匹配
    if (avoidList.contains(ingredient)) return true;

    // 模糊匹配（检查是否包含）
    for (String avoided in avoidList) {
      if (ingredient.contains(avoided) || avoided.contains(ingredient)) {
        return true;
      }
    }

    return false;
  }

  /// 检查多个食材是否有忌口
  static bool hasAvoidedIngredients(
    List<String> ingredients,
    List<String> avoidList,
  ) {
    for (String ingredient in ingredients) {
      if (isAvoided(ingredient, avoidList)) {
        return true;
      }
    }
    return false;
  }

  /// 获取菜品中被忌口的食材列表
  static List<String> getAvoidedIngredients(
    List<String> ingredients,
    List<String> avoidList,
  ) {
    List<String> avoided = [];

    for (String ingredient in ingredients) {
      if (isAvoided(ingredient, avoidList)) {
        avoided.add(ingredient);
      }
    }

    return avoided;
  }

  // ==================== 忌口分类整理 ====================

  /// 获取所有忌口食材的汇总
  static List<String> getAllAvoidedFoods({
    required List<String> avoidVegetables,
    required List<String> avoidFruits,
    required List<String> avoidMeats,
    required List<String> avoidSeafood,
  }) {
    return [
      ...avoidVegetables,
      ...avoidFruits,
      ...avoidMeats,
      ...avoidSeafood,
    ];
  }

  /// 按类别组织忌口食材
  static Map<String, List<String>> organizeAvoidedFoodsByCategory({
    required List<String> avoidVegetables,
    required List<String> avoidFruits,
    required List<String> avoidMeats,
    required List<String> avoidSeafood,
  }) {
    return {
      '蔬菜类': avoidVegetables,
      '水果类': avoidFruits,
      '肉类': avoidMeats,
      '海鲜类': avoidSeafood,
    };
  }

  // ==================== 替代食材建议 ====================

  /// 为忌口的食材提供替代建议
  static String getSuggestedReplacement(String avoidedIngredient) {
    // 蔬菜类替代
    const vegetableReplacements = {
      '香菜': '小葱或芹菜叶',
      '芹菜': '西芹或莴笋',
      '苦瓜': '丝瓜或黄瓜',
      '茄子': '西葫芦或南瓜',
      '青椒': '彩椒或西红柿',
      '洋葱': '大葱或蒜苗',
      '韭菜': '蒜苗或小葱',
    };

    // 肉类替代
    const meatReplacements = {
      '猪肉': '鸡肉或牛肉',
      '牛肉': '鸡肉或羊肉',
      '羊肉': '牛肉或鸡肉',
      '鸡肉': '火鸡肉或鸭肉',
      '鸭肉': '鸡肉或鹅肉',
    };

    // 海鲜类替代
    const seafoodReplacements = {
      '鱼': '鸡肉或豆腐',
      '虾': '鸡肉或贝类',
      '蟹': '虾或鱼',
      '贝类': '虾或鱼',
    };

    // 优先查找精确匹配
    if (vegetableReplacements.containsKey(avoidedIngredient)) {
      return vegetableReplacements[avoidedIngredient]!;
    }
    if (meatReplacements.containsKey(avoidedIngredient)) {
      return meatReplacements[avoidedIngredient]!;
    }
    if (seafoodReplacements.containsKey(avoidedIngredient)) {
      return seafoodReplacements[avoidedIngredient]!;
    }

    return '其他同类食材';
  }

  // ==================== AI提示词辅助 ====================

  /// 获取忌口的AI提示词描述
  static String getAvoidancePromptDescription({
    required List<String> avoidVegetables,
    required List<String> avoidFruits,
    required List<String> avoidMeats,
    required List<String> avoidSeafood,
  }) {
    List<String> prompts = [];

    if (avoidVegetables.isNotEmpty) {
      prompts.add('严格避免以下蔬菜：${avoidVegetables.join('、')}');
    }

    if (avoidFruits.isNotEmpty) {
      prompts.add('严格避免以下水果：${avoidFruits.join('、')}');
    }

    if (avoidMeats.isNotEmpty) {
      prompts.add('严格避免以下肉类：${avoidMeats.join('、')}');
    }

    if (avoidSeafood.isNotEmpty) {
      prompts.add('严格避免以下海鲜：${avoidSeafood.join('、')}');
    }

    if (prompts.isEmpty) {
      return '用户没有特殊忌口，可以自由推荐各类食材。';
    }

    String result = '用户忌口清单（重要）：\n';
    result += prompts.join('\n');
    result += '\n\n请确保推荐的所有菜品中都不包含以上食材。';
    result += '如果某个经典菜品包含忌口食材，请用其他食材替代或推荐其他菜品。';

    return result;
  }

  /// 获取完整的忌口提示（包括替代建议）
  static String getFullAvoidancePrompt({
    required List<String> avoidVegetables,
    required List<String> avoidFruits,
    required List<String> avoidMeats,
    required List<String> avoidSeafood,
  }) {
    String prompt = getAvoidancePromptDescription(
      avoidVegetables: avoidVegetables,
      avoidFruits: avoidFruits,
      avoidMeats: avoidMeats,
      avoidSeafood: avoidSeafood,
    );

    final allAvoided = getAllAvoidedFoods(
      avoidVegetables: avoidVegetables,
      avoidFruits: avoidFruits,
      avoidMeats: avoidMeats,
      avoidSeafood: avoidSeafood,
    );

    if (allAvoided.isNotEmpty) {
      prompt += '\n\n替代食材建议：\n';
      for (String ingredient in allAvoided.take(5)) {
        // 只显示前5个的替代建议
        String replacement = getSuggestedReplacement(ingredient);
        prompt += '- $ingredient → $replacement\n';
      }
    }

    return prompt;
  }

  // ==================== 菜品过滤 ====================

  /// 检查菜品是否符合忌口要求
  static bool isDishSuitableForUser({
    required List<String> dishIngredients,
    required List<String> avoidVegetables,
    required List<String> avoidFruits,
    required List<String> avoidMeats,
    required List<String> avoidSeafood,
  }) {
    final allAvoided = getAllAvoidedFoods(
      avoidVegetables: avoidVegetables,
      avoidFruits: avoidFruits,
      avoidMeats: avoidMeats,
      avoidSeafood: avoidSeafood,
    );

    return !hasAvoidedIngredients(dishIngredients, allAvoided);
  }

  /// 获取忌口提醒文本
  static String getAvoidanceReminderText(List<String> allAvoidedFoods) {
    if (allAvoidedFoods.isEmpty) {
      return '';
    }

    if (allAvoidedFoods.length <= 3) {
      return '已为您过滤：${allAvoidedFoods.join('、')}';
    } else {
      return '已为您过滤${allAvoidedFoods.length}种忌口食材';
    }
  }

  // ==================== 验证和清理 ====================

  /// 移除重复的忌口项
  static List<String> removeDuplicates(List<String> items) {
    return items.toSet().toList();
  }

  /// 验证忌口列表的合理性
  static Map<String, dynamic> validateAvoidanceLists({
    required List<String> avoidVegetables,
    required List<String> avoidFruits,
    required List<String> avoidMeats,
    required List<String> avoidSeafood,
  }) {
    final totalCount = avoidVegetables.length +
                      avoidFruits.length +
                      avoidMeats.length +
                      avoidSeafood.length;

    bool isReasonable = totalCount < 20; // 忌口项不应该太多
    String warning = '';

    if (totalCount >= 20) {
      warning = '忌口项目过多可能会限制推荐的多样性';
    }

    return {
      'isValid': isReasonable,
      'totalCount': totalCount,
      'warning': warning,
    };
  }
}