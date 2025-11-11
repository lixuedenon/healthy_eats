// lib/presentation/widgets/empty_state.dart
// Dart类文件

import 'package:flutter/material.dart';

/// 空状态显示组件
///
/// 用于显示列表为空、数据加载失败等状态
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onAction;
  final Color? iconColor;

  const EmptyState({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onAction,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 图标
            Icon(
              icon,
              size: 80,
              color: iconColor ?? Colors.grey[300],
            ),

            const SizedBox(height: 24),

            // 标题
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),

            // 副标题
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // 操作按钮
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 预设的空状态组件

class EmptyMealListState extends StatelessWidget {
  final VoidCallback? onAddMeal;

  const EmptyMealListState({
    Key? key,
    this.onAddMeal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.restaurant_menu,
      title: '还没有餐食记录',
      subtitle: '点击下方按钮添加你的第一餐吧！',
      actionText: '添加餐食',
      onAction: onAddMeal,
    );
  }
}

class EmptyStatisticsState extends StatelessWidget {
  const EmptyStatisticsState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.bar_chart,
      title: '暂无统计数据',
      subtitle: '记录更多餐食后即可查看统计分析',
    );
  }
}

class EmptySearchResultState extends StatelessWidget {
  final String searchKeyword;

  const EmptySearchResultState({
    Key? key,
    required this.searchKeyword,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.search_off,
      title: '未找到结果',
      subtitle: '没有找到与"$searchKeyword"相关的内容',
    );
  }
}

class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorState({
    Key? key,
    required this.message,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.error_outline,
      title: '出错了',
      subtitle: message,
      actionText: onRetry != null ? '重试' : null,
      onAction: onRetry,
      iconColor: Colors.red[300],
    );
  }
}

class NetworkErrorState extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorState({
    Key? key,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.wifi_off,
      title: '网络连接失败',
      subtitle: '请检查网络设置后重试',
      actionText: '重试',
      onAction: onRetry,
      iconColor: Colors.orange[300],
    );
  }
}

class NoDataState extends StatelessWidget {
  final String? message;

  const NoDataState({
    Key? key,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.inbox,
      title: '暂无数据',
      subtitle: message ?? '当前没有可显示的内容',
    );
  }
}

class LoadingState extends StatelessWidget {
  final String? message;

  const LoadingState({
    Key? key,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }
}