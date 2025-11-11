// lib/presentation/widgets/common_dialog.dart
// Dart类文件

import 'package:flutter/material.dart';
import '../../config/theme_config.dart';

/// 通用对话框工具类
class CommonDialog {
  // ==================== 确认对话框 ====================

  /// 显示确认对话框
  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = '确认',
    String cancelText = '取消',
    Color? confirmColor,
    bool isDangerous = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: isDangerous
                  ? Colors.red
                  : (confirmColor ?? ThemeConfig.primaryColor),
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  // ==================== 信息对话框 ====================

  /// 显示信息对话框
  static Future<void> showInfoDialog(
    BuildContext context, {
    required String title,
    required String content,
    String buttonText = '确定',
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  // ==================== 成功对话框 ====================

  /// 显示成功对话框
  static Future<void> showSuccessDialog(
    BuildContext context, {
    required String title,
    String? content,
    String buttonText = '确定',
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 12),
            Text(title),
          ],
        ),
        content: content != null ? Text(content) : null,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  // ==================== 错误对话框 ====================

  /// 显示错误对话框
  static Future<void> showErrorDialog(
    BuildContext context, {
    required String title,
    String? content,
    String buttonText = '确定',
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error, color: Colors.red, size: 28),
            const SizedBox(width: 12),
            Expanded(child: Text(title)),
          ],
        ),
        content: content != null ? Text(content) : null,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  // ==================== 加载对话框 ====================

  /// 显示加载对话框
  static void showLoadingDialog(
    BuildContext context, {
    String? message,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Expanded(
                child: Text(message ?? '加载中...'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 关闭加载对话框
  static void hideLoadingDialog(BuildContext context) {
    Navigator.pop(context);
  }

  // ==================== 单选对话框 ====================

  /// 显示单选对话框
  static Future<T?> showSingleChoiceDialog<T>(
    BuildContext context, {
    required String title,
    required List<T> items,
    required String Function(T) itemLabel,
    T? selectedItem,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: items.map((item) {
            return RadioListTile<T>(
              title: Text(itemLabel(item)),
              value: item,
              groupValue: selectedItem,
              onChanged: (value) {
                Navigator.pop(context, value);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  // ==================== 多选对话框 ====================

  /// 显示多选对话框
  static Future<List<T>?> showMultiChoiceDialog<T>(
    BuildContext context, {
    required String title,
    required List<T> items,
    required String Function(T) itemLabel,
    List<T>? selectedItems,
    String confirmText = '确定',
    String cancelText = '取消',
  }) {
    final selected = List<T>.from(selectedItems ?? []);

    return showDialog<List<T>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: items.map((item) {
                return CheckboxListTile(
                  title: Text(itemLabel(item)),
                  value: selected.contains(item),
                  onChanged: (checked) {
                    setState(() {
                      if (checked == true) {
                        selected.add(item);
                      } else {
                        selected.remove(item);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text(cancelText),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, selected),
              child: Text(confirmText),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 输入对话框 ====================

  /// 显示文本输入对话框
  static Future<String?> showInputDialog(
    BuildContext context, {
    required String title,
    String? hint,
    String? initialValue,
    String confirmText = '确定',
    String cancelText = '取消',
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    final controller = TextEditingController(text: initialValue);

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
          ),
          maxLines: maxLines,
          keyboardType: keyboardType,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  // ==================== 底部弹出对话框 ====================

  /// 显示底部选项对话框
  static Future<T?> showBottomSheet<T>(
    BuildContext context, {
    required String title,
    required List<BottomSheetOption<T>> options,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 1),
          ...options.map((option) => ListTile(
            leading: option.icon != null
                ? Icon(option.icon, color: option.color)
                : null,
            title: Text(
              option.label,
              style: TextStyle(color: option.color),
            ),
            onTap: () => Navigator.pop(context, option.value),
          )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// 底部选项类
class BottomSheetOption<T> {
  final String label;
  final T value;
  final IconData? icon;
  final Color? color;

  const BottomSheetOption({
    required this.label,
    required this.value,
    this.icon,
    this.color,
  });
}