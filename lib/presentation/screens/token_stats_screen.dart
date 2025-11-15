// lib/presentation/screens/token_stats_screen.dart
// Dart类文件

import 'package:flutter/material.dart';
import '../../data/models/token_usage_model.dart';
import '../../data/repositories/token_stats_repository.dart';
import '../../config/theme_config.dart';
import '../../core/services/storage_service.dart';

/// Token使用统计页面
class TokenStatsScreen extends StatefulWidget {
  const TokenStatsScreen({Key? key}) : super(key: key);

  @override
  State<TokenStatsScreen> createState() => _TokenStatsScreenState();
}

class _TokenStatsScreenState extends State<TokenStatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TokenStatsRepository _repository;

  TokenStats? _totalStats;
  TokenStats? _todayStats;
  TokenStats? _weekStats;
  TokenStats? _monthStats;

  List<TokenUsage> _recentRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initRepository();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initRepository() async {
    final storage = await StorageService.getInstance();
    _repository = TokenStatsRepository(storage);
    await _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await Future.wait([
        _repository.getTotalStats(),
        _repository.getTodayStats(),
        _repository.getWeekStats(),
        _repository.getMonthStats(),
        _repository.getRecentRecords(20),
      ]);

      setState(() {
        _totalStats = results[0] as TokenStats;
        _todayStats = results[1] as TokenStats;
        _weekStats = results[2] as TokenStats;
        _monthStats = results[3] as TokenStats;
        _recentRecords = results[4] as List<TokenUsage>;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading token stats: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Token 使用统计'),
        backgroundColor: ThemeConfig.primaryColor,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '总览'),
            Tab(text: '今日'),
            Tab(text: '本周'),
            Tab(text: '本月'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildStatsView(_totalStats, '总计'),
                _buildStatsView(_todayStats, '今日'),
                _buildStatsView(_weekStats, '本周'),
                _buildStatsView(_monthStats, '本月'),
              ],
            ),
    );
  }

  /// 构建统计视图
  Widget _buildStatsView(TokenStats? stats, String title) {
    if (stats == null) {
      return const Center(child: Text('暂无数据'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 概览卡片
        _buildOverviewCard(stats, title),

        const SizedBox(height: 16),

        // 模型对比卡片
        _buildModelComparisonCard(stats),

        const SizedBox(height: 16),

        // 调用记录
        _buildRecordsSection(),
      ],
    );
  }

  /// 构建概览卡片
  Widget _buildOverviewCard(TokenStats stats, String title) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$title统计',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // 总成本（突出显示）
            Center(
              child: Column(
                children: [
                  const Text(
                    '总成本',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    stats.totalCostDisplay,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: ThemeConfig.primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 其他统计
            _buildStatRow('调用次数', '${stats.totalCalls} 次'),
            const SizedBox(height: 12),
            _buildStatRow(
              'Token总量',
              '${stats.totalInputTokens + stats.totalOutputTokens} tokens',
            ),
            const SizedBox(height: 12),
            _buildStatRow('输入Token', '${stats.totalInputTokens} tokens'),
            const SizedBox(height: 12),
            _buildStatRow('输出Token', '${stats.totalOutputTokens} tokens'),
          ],
        ),
      ),
    );
  }

  /// 构建模型对比卡片
  Widget _buildModelComparisonCard(TokenStats stats) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '模型对比',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // GPT-4
            _buildModelRow(
              'GPT-4',
              stats.gpt4Calls,
              stats.gpt4CostDisplay,
              Colors.blue,
            ),

            const SizedBox(height: 16),

            // GPT-3.5
            _buildModelRow(
              'GPT-3.5-Turbo',
              stats.gpt35Calls,
              stats.gpt35CostDisplay,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建模型行
  Widget _buildModelRow(String model, int calls, String cost, Color color) {
    return Row(
      children: [
        // 图标
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.psychology, color: color, size: 24),
        ),

        const SizedBox(width: 16),

        // 信息
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                model,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$calls 次调用',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),

        // 成本
        Text(
          cost,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  /// 构建调用记录区域
  Widget _buildRecordsSection() {
    if (_recentRecords.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.inbox, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  '暂无调用记录',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            '最近调用记录',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ..._recentRecords.map((record) => _buildRecordCard(record)),
      ],
    );
  }

  /// 构建调用记录卡片
  Widget _buildRecordCard(TokenUsage record) {
    final isGPT4 = record.model.contains('gpt-4');
    final color = isGPT4 ? Colors.blue : Colors.green;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题行
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    record.modelDisplayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _formatTimestamp(record.timestamp),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ),
                Text(
                  record.costDisplay,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Token信息
            Row(
              children: [
                _buildTokenInfo('输入', record.inputTokens, Icons.input),
                const SizedBox(width: 24),
                _buildTokenInfo('输出', record.outputTokens, Icons.output),
                const SizedBox(width: 24),
                _buildTokenInfo('总计', record.totalTokens, Icons.token),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建Token信息
  Widget _buildTokenInfo(String label, int value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.black54),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
        Text(
          '$value',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// 构建统计行
  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// 格式化时间戳
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inDays > 0) {
      return '${timestamp.month}月${timestamp.day}日 ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}小时前';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
}