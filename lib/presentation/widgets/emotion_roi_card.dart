// lib/presentation/widgets/emotion_roi_card.dart
// Dart类文件

import 'package:flutter/material.dart';
import '../../data/models/emotion_roi_model.dart';

/// 情绪ROI显示卡片组件
///
/// 显示情绪ROI的详细信息
class EmotionROICard extends StatelessWidget {
  final EmotionROI emotionROI;
  final VoidCallback? onTap;

  const EmotionROICard({
    Key? key,
    required this.emotionROI,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.purple[50]!,
                Colors.pink[50]!,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题和总分
                _buildHeader(),

                const SizedBox(height: 20),

                // 总分显示
                _buildTotalScore(),

                const SizedBox(height: 20),

                // 各维度雷达图样式显示
                _buildDimensions(),

                const SizedBox(height: 16),

                // 营养因子贡献
                _buildNutrientContributions(),

                if (emotionROI.improvementSuggestion != null) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  _buildSuggestion(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建标题
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: const [
            Icon(Icons.sentiment_satisfied, color: Colors.purple, size: 28),
            SizedBox(width: 8),
            Text(
              '情绪ROI',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getRatingColor(),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            emotionROI.rating,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  /// 构建总分显示
  Widget _buildTotalScore() {
    return Center(
      child: Column(
        children: [
          Text(
            '${emotionROI.totalScore}',
            style: TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: _getRatingColor(),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '主要益处: ${emotionROI.primaryBenefit}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建各维度
  Widget _buildDimensions() {
    return Column(
      children: [
        _buildDimensionBar(
          '抗焦虑',
          emotionROI.antiAnxiety,
          Icons.self_improvement,
          Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildDimensionBar(
          '助眠',
          emotionROI.sleepAid,
          Icons.bedtime,
          Colors.indigo,
        ),
        const SizedBox(height: 12),
        _buildDimensionBar(
          '提神',
          emotionROI.energyBoost,
          Icons.bolt,
          Colors.orange,
        ),
        const SizedBox(height: 12),
        _buildDimensionBar(
          '愉悦感',
          emotionROI.happiness,
          Icons.sentiment_very_satisfied,
          Colors.pink,
        ),
        const SizedBox(height: 12),
        _buildDimensionBar(
          '抗疲劳',
          emotionROI.antiFatigue,
          Icons.fitness_center,
          Colors.green,
        ),
      ],
    );
  }

  /// 构建单个维度进度条
  Widget _buildDimensionBar(
    String label,
    int score,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        // 图标
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),

        // 标签
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // 进度条
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: score / 100,
              minHeight: 10,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // 分数
        SizedBox(
          width: 30,
          child: Text(
            '$score',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  /// 构建营养因子贡献
  Widget _buildNutrientContributions() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '营养因子贡献',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNutrientChip(
                '镁',
                emotionROI.magnesiumContribution,
                Colors.teal,
              ),
              _buildNutrientChip(
                'B族',
                emotionROI.vitaminBContribution,
                Colors.amber,
              ),
              _buildNutrientChip(
                '色氨酸',
                emotionROI.tryptophanContribution,
                Colors.purple,
              ),
              _buildNutrientChip(
                'Ω-3',
                emotionROI.omega3Contribution,
                Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建营养素芯片
  Widget _buildNutrientChip(String label, double score, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              score.toStringAsFixed(0),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  /// 构建建议
  Widget _buildSuggestion() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.tips_and_updates, color: Colors.amber[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              emotionROI.improvementSuggestion!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.amber[900],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== 辅助方法 ====================

  Color _getRatingColor() {
    if (emotionROI.totalScore >= 80) {
      return Colors.green;
    } else if (emotionROI.totalScore >= 60) {
      return Colors.blue;
    } else if (emotionROI.totalScore >= 40) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}