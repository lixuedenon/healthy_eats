// lib/data/models/token_usage_model.dart
// Dart类文件

/// Token使用记录模型
class TokenUsage {
  // ==================== 基本信息 ====================

  final String id;
  final String model; // gpt-4 / gpt-3.5-turbo
  final DateTime timestamp;

  // ==================== Token数量 ====================

  final int inputTokens;
  final int outputTokens;
  final int totalTokens;

  // ==================== 成本 ====================

  final double inputCost; // 美元
  final double outputCost; // 美元
  final double totalCost; // 美元

  // ==================== 上下文信息 ====================

  final String? purpose; // 用途：daily_recommendation / regenerate

  // ==================== 构造函数 ====================

  TokenUsage({
    required this.id,
    required this.model,
    required this.timestamp,
    required this.inputTokens,
    required this.outputTokens,
    required this.inputCost,
    required this.outputCost,
    this.purpose,
  })  : totalTokens = inputTokens + outputTokens,
        totalCost = inputCost + outputCost;

  // ==================== JSON序列化 ====================

  factory TokenUsage.fromJson(Map<String, dynamic> json) {
    return TokenUsage(
      id: json['id'] as String,
      model: json['model'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      inputTokens: json['inputTokens'] as int,
      outputTokens: json['outputTokens'] as int,
      inputCost: (json['inputCost'] as num).toDouble(),
      outputCost: (json['outputCost'] as num).toDouble(),
      purpose: json['purpose'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'model': model,
      'timestamp': timestamp.toIso8601String(),
      'inputTokens': inputTokens,
      'outputTokens': outputTokens,
      'totalTokens': totalTokens,
      'inputCost': inputCost,
      'outputCost': outputCost,
      'totalCost': totalCost,
      'purpose': purpose,
    };
  }

  // ==================== 成本计算 ====================

  /// 计算Token成本
  static TokenUsage calculate({
    required String model,
    required int inputTokens,
    required int outputTokens,
    String? purpose,
  }) {
    double inputCost;
    double outputCost;

    // GPT-4 定价
    if (model.contains('gpt-4')) {
      inputCost = inputTokens * 0.03 / 1000;
      outputCost = outputTokens * 0.06 / 1000;
    }
    // GPT-3.5-Turbo 定价
    else {
      inputCost = inputTokens * 0.0015 / 1000;
      outputCost = outputTokens * 0.002 / 1000;
    }

    return TokenUsage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      model: model,
      timestamp: DateTime.now(),
      inputTokens: inputTokens,
      outputTokens: outputTokens,
      inputCost: inputCost,
      outputCost: outputCost,
      purpose: purpose,
    );
  }

  // ==================== 工具方法 ====================

  /// 获取模型显示名称
  String get modelDisplayName {
    if (model.contains('gpt-4')) return 'GPT-4';
    if (model.contains('gpt-3.5')) return 'GPT-3.5-Turbo';
    return model;
  }

  /// 获取成本显示（格式化为美元）
  String get costDisplay {
    return '\$${totalCost.toStringAsFixed(4)}';
  }

  /// 获取Token数量显示
  String get tokensDisplay {
    return '${totalTokens.toString()} tokens';
  }
}

/// Token使用统计
class TokenStats {
  final int totalCalls; // 总调用次数
  final int totalInputTokens; // 总输入Token
  final int totalOutputTokens; // 总输出Token
  final double totalCost; // 总成本（美元）

  final int gpt4Calls; // GPT-4调用次数
  final double gpt4Cost; // GPT-4总成本

  final int gpt35Calls; // GPT-3.5调用次数
  final double gpt35Cost; // GPT-3.5总成本

  TokenStats({
    required this.totalCalls,
    required this.totalInputTokens,
    required this.totalOutputTokens,
    required this.totalCost,
    required this.gpt4Calls,
    required this.gpt4Cost,
    required this.gpt35Calls,
    required this.gpt35Cost,
  });

  /// 从记录列表计算统计数据
  factory TokenStats.fromRecords(List<TokenUsage> records) {
    int totalCalls = records.length;
    int totalInputTokens = 0;
    int totalOutputTokens = 0;
    double totalCost = 0;

    int gpt4Calls = 0;
    double gpt4Cost = 0;

    int gpt35Calls = 0;
    double gpt35Cost = 0;

    for (var record in records) {
      totalInputTokens += record.inputTokens;
      totalOutputTokens += record.outputTokens;
      totalCost += record.totalCost;

      if (record.model.contains('gpt-4')) {
        gpt4Calls++;
        gpt4Cost += record.totalCost;
      } else {
        gpt35Calls++;
        gpt35Cost += record.totalCost;
      }
    }

    return TokenStats(
      totalCalls: totalCalls,
      totalInputTokens: totalInputTokens,
      totalOutputTokens: totalOutputTokens,
      totalCost: totalCost,
      gpt4Calls: gpt4Calls,
      gpt4Cost: gpt4Cost,
      gpt35Calls: gpt35Calls,
      gpt35Cost: gpt35Cost,
    );
  }

  /// 获取总成本显示
  String get totalCostDisplay {
    return '\$${totalCost.toStringAsFixed(4)}';
  }

  /// 获取GPT-4成本显示
  String get gpt4CostDisplay {
    return '\$${gpt4Cost.toStringAsFixed(4)}';
  }

  /// 获取GPT-3.5成本显示
  String get gpt35CostDisplay {
    return '\$${gpt35Cost.toStringAsFixed(4)}';
  }
}