// lib/presentation/widgets/lqi_card.dart
// Dart类文件

import 'package:flutter/material.dart';
import '../../data/models/lqi_model.dart';
import '../../config/theme_config.dart';

/// LQI显示卡片组件
///
/// 显示生活质量指数的详细信息
class LQICard extends StatelessWidget {
  final LQI lqi;
  final VoidCallback? onTap;

  const LQICard({
    Key? key,
    required this.lqi,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
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
                _getRatingColor().withOpacity(0.1),
                _getRatingColor().withOpacity(0.05),
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

                // 总分圆环
                _buildScoreRing(),

                const SizedBox(height: 24),

                // 各维度指标
                _buildDimensionIndicators(),

                if (lqi.improvementSuggestion != null) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '生活质量指数',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              lqi.goalMessage,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
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
            lqi.rating,
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

  /// 构建总分圆环
  Widget _buildScoreRing() {
    return Center(
      child: SizedBox(
        width: 160,
        height: 160,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 背景圆环
            SizedBox(
              width: 160,
              height: 160,
              child: CircularProgressIndicator(
                value: 1.0,
                strokeWidth: 16,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[200]!),
              ),
            ),
            // 分数圆环
            SizedBox(
              width: 160,
              height: 160,
              child: CircularProgressIndicator(
                value: lqi.totalScore / 100,
                strokeWidth: 16,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(_getRatingColor()),
              ),
            ),
            // 中心文字
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${lqi.totalScore}',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: _getRatingColor(),
                  ),
                ),
                const Text(
                  '总分',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建各维度指标
  Widget _buildDimensionIndicators() {
    return Column(
      children: [
        _buildDimensionRow(
          '健康指数',
          lqi.healthIndex,
          Icons.favorite,
          Colors.red,
        ),
        const SizedBox(height: 12),
        _buildDimensionRow(
          '情绪指数',
          lqi.emotionIndex,
          Icons.sentiment_satisfied,
          Colors.purple,
        ),
        const SizedBox(height: 12),
        _buildDimensionRow(
          '预算优化',
          lqi.budgetOptimization,
          Icons.account_balance_wallet,
          Colors.green,
        ),
        const SizedBox(height: 12),
        _buildDimensionRow(
          '便捷性',
          lqi.convenience,
          Icons.speed,
          Colors.orange,
        ),
      ],
    );
  }

  /// 构建单个维度行
  Widget _buildDimensionRow(
    String label,
    int score,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        // 图标
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),

        const SizedBox(width: 12),

        // 标签
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
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
              minHeight: 8,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // 分数
        SizedBox(
          width: 40,
          child: Text(
            '$score',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
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
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: Colors.blue[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              lqi.improvementSuggestion!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue[900],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== 辅助方法 ====================

  /// 获取评级颜色
  Color _getRatingColor() {
    if (lqi.totalScore >= 85) {
      return Colors.green;
    } else if (lqi.totalScore >= 70) {
      return Colors.blue;
    } else if (lqi.totalScore >= 60) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}

/// LQI简化卡片（用于首页等）
class LQISimpleCard extends StatelessWidget {
  final LQI lqi;
  final VoidCallback? onTap;

  const LQISimpleCard({
    Key? key,
    required this.lqi,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 分数圆环
              SizedBox(
                width: 60,
                height: 60,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        value: lqi.totalScore / 100,
                        strokeWidth: 6,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getRatingColor(),
                        ),
                      ),
                    ),
                    Text(
                      '${lqi.totalScore}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _getRatingColor(),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // 信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          '生活质量指数',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getRatingColor(),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            lqi.rating,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lqi.goalMessage,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRatingColor() {
    if (lqi.totalScore >= 85) {
      return Colors.green;
    } else if (lqi.totalScore >= 70) {
      return Colors.blue;
    } else if (lqi.totalScore >= 60) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}