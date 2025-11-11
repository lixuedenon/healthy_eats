// lib/domain/ai_engine/logic/meal_source_logic.dart
// Dart类文件

/// 餐食来源逻辑判断类
///
/// 根据用户的餐食来源级别（1-5）决定推荐方式
class MealSourceLogic {
  // ==================== 推荐类型判断 ====================

  /// 根据餐食来源级别决定推荐方式
  ///
  /// 级别1: 基本只吃餐馆和外卖 → 100%餐馆推荐
  /// 级别2: 大部分餐馆外卖，少量自己做 → 80%餐馆 + 20%菜谱
  /// 级别3: 餐馆外卖和自己做基本对半 → 50%餐馆 + 50%菜谱
  /// 级别4: 少量餐馆外卖，大部分自己做 → 20%餐馆 + 80%菜谱
  /// 级别5: 基本自己做 → 100%菜谱
  static String getRecommendationType(int mealSource) {
    switch (mealSource) {
      case 1:
        return '餐馆推荐';
      case 2:
        return '80%餐馆推荐 + 20%菜谱';
      case 3:
        return '50%餐馆推荐 + 50%菜谱';
      case 4:
        return '20%餐馆推荐 + 80%菜谱';
      case 5:
        return '菜谱';
      default:
        return '50%餐馆推荐 + 50%菜谱';
    }
  }

  /// 判断是否需要推荐餐馆
  static bool needRestaurantRecommendation(int mealSource) {
    return mealSource <= 3;
  }

  /// 判断是否需要提供菜谱（仅VIP可见）
  static bool needRecipe(int mealSource, bool isVIP) {
    // 级别2以上（有自己做的部分）且是VIP才提供菜谱
    return mealSource >= 2 && isVIP;
  }

  /// 判断是否主要依赖外食
  static bool isPrimarilyDiningOut(int mealSource) {
    return mealSource <= 2;
  }

  /// 判断是否主要自己做
  static bool isPrimarilyCooking(int mealSource) {
    return mealSource >= 4;
  }

  // ==================== 餐食分配 ====================

  /// 根据餐食来源级别，决定一周内餐馆和自己做的餐食分配
  ///
  /// 返回：{
  ///   'restaurant': 餐馆餐数,
  ///   'homeCooking': 自己做餐数
  /// }
  static Map<String, int> getWeeklyMealDistribution(int mealSource) {
    // 假设一周21餐（早中晚各7餐）
    const totalMeals = 21;

    switch (mealSource) {
      case 1: // 基本只吃餐馆和外卖
        return {'restaurant': 21, 'homeCooking': 0};
      case 2: // 大部分餐馆外卖，少量自己做
        return {'restaurant': 17, 'homeCooking': 4};
      case 3: // 对半
        return {'restaurant': 11, 'homeCooking': 10};
      case 4: // 少量餐馆外卖，大部分自己做
        return {'restaurant': 4, 'homeCooking': 17};
      case 5: // 基本自己做
        return {'restaurant': 0, 'homeCooking': 21};
      default:
        return {'restaurant': 11, 'homeCooking': 10};
    }
  }

  /// 决定今天某一餐应该是餐馆还是自己做
  ///
  /// 参数：
  /// - mealSource: 餐食来源级别
  /// - mealIndex: 第几餐（0-20，一周21餐）
  static String decideMealSource(int mealSource, int mealIndex) {
    final distribution = getWeeklyMealDistribution(mealSource);
    final restaurantCount = distribution['restaurant']!;

    // 均匀分布餐馆餐食
    if (mealSource == 1) {
      return '餐馆';
    } else if (mealSource == 5) {
      return '自己做';
    } else {
      // 按比例分配
      final threshold = restaurantCount / 21.0;
      final random = (mealIndex * 0.618033988749895) % 1.0; // 黄金分割数，产生均匀分布
      return random < threshold ? '餐馆' : '自己做';
    }
  }

  // ==================== AI提示词辅助 ====================

  /// 获取餐食来源的AI提示词描述
  static String getAIPromptDescription(int mealSource) {
    switch (mealSource) {
      case 1:
        return '用户基本只吃餐馆和外卖，请推荐适合的餐馆菜品，包括餐馆名称和具体菜品。';
      case 2:
        return '用户大部分吃餐馆外卖，少量自己做。请80%推荐餐馆菜品，20%提供简单易做的家常菜谱。';
      case 3:
        return '用户餐馆外卖和自己做基本对半。请平衡推荐餐馆菜品和家常菜谱。';
      case 4:
        return '用户大部分自己做，少量吃餐馆外卖。请80%提供家常菜谱，20%推荐餐馆菜品作为偶尔选择。';
      case 5:
        return '用户基本自己做饭，请提供完整的家常菜谱，包括食材清单和制作步骤。';
      default:
        return '请根据用户的餐食来源偏好推荐合适的餐食。';
    }
  }

  /// 获取烹饪复杂度建议
  static String getCookingComplexitySuggestion(int mealSource) {
    if (mealSource <= 2) {
      return '简单快手菜，15分钟内完成';
    } else if (mealSource == 3) {
      return '中等复杂度，20-30分钟';
    } else if (mealSource == 4) {
      return '可以稍微复杂，30-40分钟';
    } else {
      return '可以准备较复杂的菜品，享受烹饪过程';
    }
  }

  /// 获取食材采购建议
  static String getIngredientSuggestion(int mealSource) {
    if (mealSource <= 2) {
      return '建议购买预处理食材或半成品，节省时间';
    } else if (mealSource == 3) {
      return '可以混合使用新鲜食材和预处理食材';
    } else {
      return '建议购买新鲜食材，注重食材质量';
    }
  }
}