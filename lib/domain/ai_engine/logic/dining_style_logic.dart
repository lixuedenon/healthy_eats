// lib/domain/ai_engine/logic/dining_style_logic.dart
// Dart类文件

/// 就餐形式逻辑判断类
///
/// 根据用户的就餐方式（自己吃/和朋友家人/和同事）调整推荐
class DiningStyleLogic {
  // ==================== 就餐形式分析 ====================

  /// 根据就餐形式获取调整参数
  ///
  /// 返回：{
  ///   'portionSize': 份量大小,
  ///   'complexity': 复杂度,
  ///   'socialConsideration': 是否需要考虑社交因素,
  ///   'suggestion': 特殊建议
  /// }
  static Map<String, dynamic> adjustForDiningStyle(String diningStyle) {
    switch (diningStyle) {
      case '主要自己吃':
        return {
          'portionSize': '单人份',
          'portionMultiplier': 1.0,
          'complexity': '简单快捷',
          'socialConsideration': false,
          'cookingTime': '15-20分钟',
          'suggestion': '推荐简单易做、快速完成的单人餐',
          'dishCount': 2, // 一荤一素或主食+菜
        };

      case '经常和朋友家人':
        return {
          'portionSize': '2-4人份',
          'portionMultiplier': 3.0,
          'complexity': '适中，适合分享',
          'socialConsideration': true,
          'cookingTime': '30-45分钟',
          'suggestion': '推荐适合家庭聚餐的菜品，考虑不同口味偏好，菜品丰富多样',
          'dishCount': 4, // 3-4个菜 + 主食
          'extraTips': '注重菜品搭配和摆盘，适合家庭氛围',
        };

      case '经常和同事':
        return {
          'portionSize': '适合外出或团餐',
          'portionMultiplier': 2.0,
          'complexity': '不挑剔，社交友好',
          'socialConsideration': true,
          'cookingTime': '外出就餐',
          'suggestion': '推荐适合商务聚餐或团队聚餐的餐厅和菜品，考虑大众口味',
          'dishCount': 3, // 适合分享的菜品数量
          'extraTips': '选择环境舒适、菜品多样的餐厅，适合社交场合',
        };

      default:
        return {
          'portionSize': '单人份',
          'portionMultiplier': 1.0,
          'complexity': '简单',
          'socialConsideration': false,
          'cookingTime': '15-20分钟',
          'suggestion': '推荐简单快捷的餐食',
          'dishCount': 2,
        };
    }
  }

  // ==================== 份量计算 ====================

  /// 根据就餐形式计算份量倍数
  static double getPortionMultiplier(String diningStyle) {
    final params = adjustForDiningStyle(diningStyle);
    return params['portionMultiplier'] as double;
  }

  /// 获取建议的菜品数量
  static int getSuggestedDishCount(String diningStyle) {
    final params = adjustForDiningStyle(diningStyle);
    return params['dishCount'] as int;
  }

  // ==================== 社交考虑 ====================

  /// 判断是否需要考虑社交因素
  static bool needSocialConsideration(String diningStyle) {
    final params = adjustForDiningStyle(diningStyle);
    return params['socialConsideration'] as bool;
  }

  /// 获取社交场景下的特殊建议
  static String getSocialTips(String diningStyle) {
    if (!needSocialConsideration(diningStyle)) {
      return '';
    }

    if (diningStyle == '经常和朋友家人') {
      return '建议选择口味丰富、适合分享的菜品。可以包括：'
             '1个肉类主菜、1-2个蔬菜、1个汤品、主食。'
             '注意照顾不同家庭成员的口味偏好。';
    } else if (diningStyle == '经常和同事') {
      return '建议选择大众化、不容易踩雷的菜品。'
             '避免过于独特或刺激的口味（如过辣、过酸）。'
             '选择便于分享、摆盘精致的菜品。';
    }

    return '';
  }

  // ==================== 菜品选择建议 ====================

  /// 获取菜品类型建议
  static List<String> getDishTypeSuggestions(String diningStyle) {
    if (diningStyle == '主要自己吃') {
      return [
        '一荤一素的简单搭配',
        '一碗面/饭 + 小菜',
        '快手盖饭',
        '轻食沙拉',
      ];
    } else if (diningStyle == '经常和朋友家人') {
      return [
        '1个特色主菜（鱼/肉）',
        '1-2个炒菜（荤素搭配）',
        '1个汤品或凉菜',
        '主食（米饭/面食/饺子等）',
      ];
    } else if (diningStyle == '经常和同事') {
      return [
        '经典家常菜（如宫保鸡丁、鱼香肉丝）',
        '大众喜爱的菜品',
        '适合分享的大份菜',
        '环境舒适的餐厅',
      ];
    }

    return ['根据个人喜好选择'];
  }

  // ==================== 烹饪复杂度 ====================

  /// 获取建议的烹饪复杂度
  static String getCookingComplexity(String diningStyle) {
    final params = adjustForDiningStyle(diningStyle);
    return params['complexity'] as String;
  }

  /// 获取建议的烹饪时间
  static String getCookingTime(String diningStyle) {
    final params = adjustForDiningStyle(diningStyle);
    return params['cookingTime'] as String;
  }

  // ==================== AI提示词辅助 ====================

  /// 获取就餐形式的AI提示词描述
  static String getAIPromptDescription(String diningStyle) {
    final params = adjustForDiningStyle(diningStyle);
    return params['suggestion'] as String;
  }

  /// 获取完整的就餐形式提示词
  static String getFullPromptForDiningStyle(String diningStyle) {
    final params = adjustForDiningStyle(diningStyle);
    final portionSize = params['portionSize'] as String;
    final complexity = params['complexity'] as String;
    final suggestion = params['suggestion'] as String;
    final dishCount = params['dishCount'] as int;

    String prompt = '就餐形式：$diningStyle\n'
                   '份量：$portionSize\n'
                   '菜品数量：建议$dishCount个菜\n'
                   '复杂度：$complexity\n'
                   '建议：$suggestion\n';

    if (params.containsKey('extraTips')) {
      prompt += '额外提示：${params['extraTips']}\n';
    }

    if (needSocialConsideration(diningStyle)) {
      prompt += '\n社交建议：\n${getSocialTips(diningStyle)}';
    }

    return prompt;
  }

  // ==================== 餐馆推荐相关 ====================

  /// 获取餐馆类型建议
  static String getRestaurantTypeSuggestion(String diningStyle) {
    if (diningStyle == '主要自己吃') {
      return '适合单人就餐的快餐店、简餐店、轻食店';
    } else if (diningStyle == '经常和朋友家人') {
      return '适合家庭聚餐的中餐厅、火锅店、家常菜馆';
    } else if (diningStyle == '经常和同事') {
      return '适合商务聚餐的中高档餐厅、环境舒适的连锁餐厅';
    }

    return '各类餐厅均可';
  }

  /// 获取餐馆环境要求
  static String getRestaurantEnvironmentRequirement(String diningStyle) {
    if (diningStyle == '主要自己吃') {
      return '快速、便捷、干净即可';
    } else if (diningStyle == '经常和朋友家人') {
      return '温馨舒适、适合家庭、有包间更佳';
    } else if (diningStyle == '经常和同事') {
      return '环境优雅、适合商务、服务周到';
    }

    return '环境舒适';
  }
}