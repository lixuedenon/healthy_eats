// lib/core/constants/roi_standards.dart
// Dart类文件

/// ROI和LQI标准值配置类
///
/// 定义情绪ROI和生活质量指数(LQI)的标准值、评级标准等
class ROIStandards {
  // ==================== 情绪ROI标准值 ====================

  /// 情绪ROI完美分数
  static const int EMOTION_ROI_PERFECT = 100;

  /// 情绪ROI优秀分数线
  static const int EMOTION_ROI_EXCELLENT = 90;

  /// 情绪ROI良好分数线
  static const int EMOTION_ROI_GOOD = 80;

  /// 情绪ROI一般分数线
  static const int EMOTION_ROI_AVERAGE = 70;

  /// 情绪ROI较差分数线
  static const int EMOTION_ROI_POOR = 60;

  /// 情绪ROI各子项标准值（满分100）
  static const Map<String, int> EMOTION_SUB_STANDARDS = {
    '抗焦虑': 85,
    '助眠': 80,
    '提神': 75,
    '愉悦感': 82,
    '抗疲劳': 78,
  };

  // ==================== LQI生活质量指数标准值 ====================

  /// LQI完美分数
  static const int LQI_PERFECT = 100;

  /// LQI优秀分数线
  static const int LQI_EXCELLENT = 90;

  /// LQI良好分数线
  static const int LQI_GOOD = 80;

  /// LQI一般分数线
  static const int LQI_AVERAGE = 70;

  /// LQI建议目标值
  static const int LQI_TARGET = 85;

  /// LQI四大维度标准值（每项满分100）
  static const Map<String, int> LQI_DIMENSION_STANDARDS = {
    '健康指数': 88,
    '情绪指数': 85,
    '预算优化': 80,
    '便捷性': 82,
  };

  // ==================== 营养素每日推荐摄入量标准 ====================

  /// 根据不同健康目标的每日热量标准（kcal）
  static const Map<String, int> DAILY_CALORIES_STANDARDS = {
    '减脂': 1800,
    '增肌': 2500,
    '维持': 2000,
    '随意': 2000,
  };

  /// 根据不同健康目标的每日蛋白质标准（g）
  static const Map<String, int> DAILY_PROTEIN_STANDARDS = {
    '减脂': 120,
    '增肌': 150,
    '维持': 100,
    '随意': 100,
  };

  /// 根据不同健康目标的每日碳水化合物标准（g）
  static const Map<String, int> DAILY_CARBS_STANDARDS = {
    '减脂': 180,
    '增肌': 300,
    '维持': 250,
    '随意': 250,
  };

  /// 根据不同健康目标的每日脂肪标准（g）
  static const Map<String, int> DAILY_FAT_STANDARDS = {
    '减脂': 50,
    '增肌': 80,
    '维持': 70,
    '随意': 70,
  };

  // ==================== 微量元素每日推荐摄入量 ====================

  /// 镁（mg/天）
  static const int DAILY_MAGNESIUM = 400;

  /// 维生素B6（mg/天）
  static const double DAILY_VITAMIN_B6 = 1.5;

  /// 维生素B12（μg/天）
  static const double DAILY_VITAMIN_B12 = 2.4;

  /// 色氨酸（mg/天）
  static const int DAILY_TRYPTOPHAN = 250;

  /// 铁（mg/天）
  static const int DAILY_IRON = 18;

  /// Omega-3（g/天）
  static const double DAILY_OMEGA3 = 1.6;

  // ==================== 评级文案 ====================

  /// 获取情绪ROI评级文案
  static String getEmotionROIRating(int score) {
    if (score >= EMOTION_ROI_EXCELLENT) return '优秀';
    if (score >= EMOTION_ROI_GOOD) return '良好';
    if (score >= EMOTION_ROI_AVERAGE) return '一般';
    if (score >= EMOTION_ROI_POOR) return '较差';
    return '需改善';
  }

  /// 获取LQI评级文案
  static String getLQIRating(int score) {
    if (score >= LQI_EXCELLENT) return '优秀';
    if (score >= LQI_GOOD) return '良好';
    if (score >= LQI_AVERAGE) return '一般';
    return '需改善';
  }

  /// 获取LQI目标提示信息
  static String getLQIGoalMessage(int currentScore) {
    int target = LQI_TARGET;
    if (currentScore >= target) {
      return '太棒了！您已达到建议目标值！继续保持~';
    } else {
      int gap = target - currentScore;
      return '距离建议目标值还差${gap}分，加油！';
    }
  }

  /// 获取情绪ROI子项目标提示
  static String getEmotionSubGoalMessage(String category, int currentScore) {
    int standard = EMOTION_SUB_STANDARDS[category] ?? 80;
    if (currentScore >= standard) {
      return '已达标准值！';
    } else {
      int gap = standard - currentScore;
      return '还差${gap}分达标';
    }
  }

  /// 获取LQI维度目标提示
  static String getLQIDimensionGoalMessage(String dimension, int currentScore) {
    int standard = LQI_DIMENSION_STANDARDS[dimension] ?? 80;
    if (currentScore >= standard) {
      return '已达标准值！';
    } else {
      int gap = standard - currentScore;
      return '还差${gap}分达标';
    }
  }

  /// 获取营养素目标值
  static int getNutrientTarget(String healthGoal, String nutrientType) {
    switch (nutrientType) {
      case '热量':
        return DAILY_CALORIES_STANDARDS[healthGoal] ?? 2000;
      case '蛋白质':
        return DAILY_PROTEIN_STANDARDS[healthGoal] ?? 100;
      case '碳水':
        return DAILY_CARBS_STANDARDS[healthGoal] ?? 250;
      case '脂肪':
        return DAILY_FAT_STANDARDS[healthGoal] ?? 70;
      default:
        return 0;
    }
  }
}