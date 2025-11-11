// lib/presentation/screens/statistics_screen.dart
// Dart类文件

import 'package:flutter/material.dart';
import '../../config/theme_config.dart';

/// 统计页面
///
/// 显示历史数据统计和分析
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('统计分析'),
        backgroundColor: ThemeConfig.primaryColor,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '本周'),
            Tab(text: '本月'),
            Tab(text: '全部'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWeekView(),
          _buildMonthView(),
          _buildAllTimeView(),
        ],
      ),
    );
  }

  /// 构建本周视图
  Widget _buildWeekView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 本周概览卡片
        _buildOverviewCard(
          title: '本周概览',
          items: [
            _buildStatItem('打卡天数', '5/7', '天', Colors.blue),
            _buildStatItem('平均LQI', '82', '分', Colors.green),
            _buildStatItem('完成餐次', '18', '次', Colors.orange),
          ],
        ),

        const SizedBox(height: 16),

        // LQI趋势图
        _buildChartCard(
          title: 'LQI趋势',
          child: _buildPlaceholderChart('LQI趋势图'),
        ),

        const SizedBox(height: 16),

        // 营养摄入分析
        _buildChartCard(
          title: '营养摄入分析',
          child: _buildPlaceholderChart('营养分析图'),
        ),

        const SizedBox(height: 16),

        // 情绪ROI分析
        _buildChartCard(
          title: '情绪ROI分析',
          child: _buildPlaceholderChart('情绪ROI图'),
        ),
      ],
    );
  }

  /// 构建本月视图
  Widget _buildMonthView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 本月概览卡片
        _buildOverviewCard(
          title: '本月概览',
          items: [
            _buildStatItem('打卡天数', '20/30', '天', Colors.blue),
            _buildStatItem('平均LQI', '79', '分', Colors.green),
            _buildStatItem('完成餐次', '72', '次', Colors.orange),
          ],
        ),

        const SizedBox(height: 16),

        // 月度统计
        _buildMonthlyStats(),

        const SizedBox(height: 16),

        // 热力图
        _buildChartCard(
          title: '打卡热力图',
          child: _buildPlaceholderChart('打卡热力图'),
        ),
      ],
    );
  }

  /// 构建全部时间视图
  Widget _buildAllTimeView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 全部概览卡片
        _buildOverviewCard(
          title: '全部统计',
          items: [
            _buildStatItem('累计天数', '120', '天', Colors.blue),
            _buildStatItem('累计餐次', '360', '次', Colors.orange),
            _buildStatItem('最高LQI', '95', '分', Colors.green),
          ],
        ),

        const SizedBox(height: 16),

        // 成就徽章
        _buildAchievementsCard(),

        const SizedBox(height: 16),

        // 长期趋势
        _buildChartCard(
          title: '长期趋势',
          child: _buildPlaceholderChart('长期趋势图'),
        ),
      ],
    );
  }

  /// 构建概览卡片
  Widget _buildOverviewCard({
    required String title,
    required List<Widget> items,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: items,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建统计项
  Widget _buildStatItem(String label, String value, String unit, Color color) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                unit,
                style: TextStyle(
                  fontSize: 14,
                  color: color.withOpacity(0.7),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  /// 构建图表卡片
  Widget _buildChartCard({
    required String title,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  /// 构建占位符图表
  Widget _buildPlaceholderChart(String text) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '(待实现)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建月度统计
  Widget _buildMonthlyStats() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '月度分析',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildProgressRow('健康指数', 0.85, Colors.red),
            const SizedBox(height: 12),
            _buildProgressRow('情绪指数', 0.78, Colors.purple),
            const SizedBox(height: 12),
            _buildProgressRow('预算优化', 0.72, Colors.green),
            const SizedBox(height: 12),
            _buildProgressRow('便捷性', 0.88, Colors.orange),
          ],
        ),
      ),
    );
  }

  /// 构建进度行
  Widget _buildProgressRow(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(value * 100).toInt()}分',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  /// 构建成就徽章卡片
  Widget _buildAchievementsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '成就徽章',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: 查看全部成就
                  },
                  child: const Text('查看全部'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildAchievementBadge('🎖️', '连续打卡7天', true),
                _buildAchievementBadge('⭐', 'LQI达到90分', true),
                _buildAchievementBadge('🏆', '完成100次餐食', true),
                _buildAchievementBadge('💎', '连续打卡30天', false),
                _buildAchievementBadge('👑', 'VIP会员', false),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建成就徽章
  Widget _buildAchievementBadge(String emoji, String title, bool unlocked) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: unlocked ? Colors.amber[100] : Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              emoji,
              style: TextStyle(
                fontSize: 28,
                color: unlocked ? null : Colors.grey,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 70,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: unlocked ? Colors.black87 : Colors.grey,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}