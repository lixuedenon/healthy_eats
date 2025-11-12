// lib/core/services/notification_service.dart
// 通知服务 - 使用 awesome_notifications

import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import '../../data/models/reminder_model.dart';

/// 通知服务
///
/// 使用 awesome_notifications 管理本地通知
class NotificationService {
  static bool _initialized = false;

  // ==================== 通知渠道ID ====================

  static const String CHANNEL_MEAL_REMINDER = 'meal_reminder';
  static const String CHANNEL_WATER_REMINDER = 'water_reminder';
  static const String CHANNEL_REST_REMINDER = 'rest_reminder';
  static const String CHANNEL_WEATHER = 'weather';

  // ==================== 初始化 ====================

  /// 初始化通知服务
  static Future<bool> initialize() async {
    if (_initialized) return true;

    try {
      // 初始化 Awesome Notifications
      await AwesomeNotifications().initialize(
        null, // 使用默认图标
        [
          // 餐食提醒渠道
          NotificationChannel(
            channelKey: CHANNEL_MEAL_REMINDER,
            channelName: '餐食提醒',
            channelDescription: '早餐、午餐、晚餐提醒',
            defaultColor: const Color(0xFF4CAF50),
            ledColor: const Color(0xFF4CAF50),
            importance: NotificationImportance.High,
            channelShowBadge: true,
            playSound: true,
            enableVibration: true,
          ),

          // 喝水提醒渠道
          NotificationChannel(
            channelKey: CHANNEL_WATER_REMINDER,
            channelName: '喝水提醒',
            channelDescription: '定时喝水提醒',
            defaultColor: const Color(0xFF2196F3),
            ledColor: const Color(0xFF2196F3),
            importance: NotificationImportance.Default,
            channelShowBadge: true,
            playSound: true,
            enableVibration: true,
          ),

          // 休息提醒渠道
          NotificationChannel(
            channelKey: CHANNEL_REST_REMINDER,
            channelName: '休息提醒',
            channelDescription: '休息时间提醒',
            defaultColor: const Color(0xFF9C27B0),
            ledColor: const Color(0xFF9C27B0),
            importance: NotificationImportance.Default,
            channelShowBadge: true,
            playSound: true,
            enableVibration: true,
          ),

          // 天气关怀渠道
          NotificationChannel(
            channelKey: CHANNEL_WEATHER,
            channelName: '天气关怀',
            channelDescription: '天气变化提醒',
            defaultColor: const Color(0xFFFF9800),
            ledColor: const Color(0xFFFF9800),
            importance: NotificationImportance.Default,
            channelShowBadge: false,
            playSound: true,
            enableVibration: false,
          ),
        ],
        debug: false,
      );

      // 设置通知点击监听
      AwesomeNotifications().setListeners(
        onActionReceivedMethod: _onNotificationTapped,
        onNotificationCreatedMethod: _onNotificationCreated,
        onNotificationDisplayedMethod: _onNotificationDisplayed,
        onDismissActionReceivedMethod: _onNotificationDismissed,
      );

      _initialized = true;
      print('[NotificationService] Initialized successfully');
      return true;
    } catch (e) {
      print('[NotificationService] Initialization failed: $e');
      return false;
    }
  }

  // ==================== 通知监听回调 ====================

  /// 通知被创建
  @pragma('vm:entry-point')
  static Future<void> _onNotificationCreated(
    ReceivedNotification receivedNotification,
  ) async {
    print('[NotificationService] Notification created: ${receivedNotification.id}');
  }

  /// 通知被显示
  @pragma('vm:entry-point')
  static Future<void> _onNotificationDisplayed(
    ReceivedNotification receivedNotification,
  ) async {
    print('[NotificationService] Notification displayed: ${receivedNotification.id}');
  }

  /// 通知被点击
  @pragma('vm:entry-point')
  static Future<void> _onNotificationTapped(
    ReceivedAction receivedAction,
  ) async {
    print('[NotificationService] Notification tapped: ${receivedAction.payload}');
    // TODO: 处理通知点击事件，跳转到相应页面
  }

  /// 通知被关闭
  @pragma('vm:entry-point')
  static Future<void> _onNotificationDismissed(
    ReceivedAction receivedAction,
  ) async {
    print('[NotificationService] Notification dismissed: ${receivedAction.id}');
  }

  // ==================== 请求权限 ====================

  /// 请求通知权限
  static Future<bool> requestPermissions() async {
    try {
      final isAllowed = await AwesomeNotifications().isNotificationAllowed();

      if (!isAllowed) {
        final granted = await AwesomeNotifications().requestPermissionToSendNotifications();
        return granted;
      }

      return true;
    } catch (e) {
      print('[NotificationService] Request permissions failed: $e');
      return false;
    }
  }

  // ==================== 显示通知 ====================

  /// 显示即时通知
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String channelKey = CHANNEL_MEAL_REMINDER,
  }) async {
    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: channelKey,
          title: title,
          body: body,
          payload: payload != null ? {'type': payload} : null,
          notificationLayout: NotificationLayout.Default,
          displayOnForeground: true,
          displayOnBackground: true,
        ),
      );

      print('[NotificationService] Notification shown: $id - $title');
    } catch (e) {
      print('[NotificationService] Show notification failed: $e');
    }
  }

  // ==================== 调度定时通知 ====================

  /// 调度每日定时通知
  static Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
    String channelKey = CHANNEL_MEAL_REMINDER,
  }) async {
    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: channelKey,
          title: title,
          body: body,
          payload: payload != null ? {'type': payload} : null,
          notificationLayout: NotificationLayout.Default,
        ),
        schedule: NotificationCalendar(
          hour: hour,
          minute: minute,
          second: 0,
          millisecond: 0,
          repeats: true, // 每天重复
        ),
      );

      print('[NotificationService] Daily notification scheduled: $id at $hour:$minute');
    } catch (e) {
      print('[NotificationService] Schedule daily notification failed: $e');
    }
  }

  /// 调度提醒列表
  static Future<void> scheduleReminders(List<Reminder> reminders) async {
    try {
      // 先取消所有现有提醒
      await cancelAllNotifications();

      // 调度新的提醒
      for (Reminder reminder in reminders) {
        if (!reminder.isEnabled) continue;

        final timeParts = reminder.time.split(':');
        if (timeParts.length != 2) continue;

        final hour = int.tryParse(timeParts[0]);
        final minute = int.tryParse(timeParts[1]);

        if (hour == null || minute == null) continue;

        // 确定渠道
        String channelKey = CHANNEL_MEAL_REMINDER;
        if (reminder.type == '喝水提醒') {
          channelKey = CHANNEL_WATER_REMINDER;
        } else if (reminder.type == '休息提醒') {
          channelKey = CHANNEL_REST_REMINDER;
        } else if (reminder.type == '天气关怀') {
          channelKey = CHANNEL_WEATHER;
        }

        await scheduleDailyNotification(
          id: reminder.id.hashCode,
          title: reminder.title,
          body: reminder.message ?? '',
          hour: hour,
          minute: minute,
          payload: reminder.type,
          channelKey: channelKey,
        );
      }

      print('[NotificationService] Scheduled ${reminders.length} reminders');
    } catch (e) {
      print('[NotificationService] Schedule reminders failed: $e');
    }
  }

  // ==================== 取消通知 ====================

  /// 取消指定通知
  static Future<void> cancelNotification(int id) async {
    try {
      await AwesomeNotifications().cancel(id);
      print('[NotificationService] Notification cancelled: $id');
    } catch (e) {
      print('[NotificationService] Cancel notification failed: $e');
    }
  }

  /// 取消所有通知
  static Future<void> cancelAllNotifications() async {
    try {
      await AwesomeNotifications().cancelAll();
      print('[NotificationService] All notifications cancelled');
    } catch (e) {
      print('[NotificationService] Cancel all notifications failed: $e');
    }
  }

  // ==================== 查询通知 ====================

  /// 获取待处理的通知列表
  static Future<List<NotificationModel>> getPendingNotifications() async {
    try {
      final schedules = await AwesomeNotifications().listScheduledNotifications();
      return schedules;
    } catch (e) {
      print('[NotificationService] Get pending notifications failed: $e');
      return [];
    }
  }

  /// 获取活跃的通知列表
  static Future<List<NotificationModel>> getActiveNotifications() async {
    try {
      // awesome_notifications 不直接支持获取活跃通知
      // 这里返回空列表
      return [];
    } catch (e) {
      print('[NotificationService] Get active notifications failed: $e');
      return [];
    }
  }

  // ==================== 预设通知 ====================

  /// 发送早餐提醒
  static Future<void> sendBreakfastReminder() async {
    await showNotification(
      id: 1,
      title: '🌅 早餐时间',
      body: '该吃早餐啦！开始美好的一天~',
      payload: 'breakfast',
      channelKey: CHANNEL_MEAL_REMINDER,
    );
  }

  /// 发送午餐提醒
  static Future<void> sendLunchReminder() async {
    await showNotification(
      id: 2,
      title: '☀️ 午餐时间',
      body: '中午了，记得按时吃午饭哦~',
      payload: 'lunch',
      channelKey: CHANNEL_MEAL_REMINDER,
    );
  }

  /// 发送晚餐提醒
  static Future<void> sendDinnerReminder() async {
    await showNotification(
      id: 3,
      title: '🌙 晚餐时间',
      body: '晚餐时间到了，享受美食吧~',
      payload: 'dinner',
      channelKey: CHANNEL_MEAL_REMINDER,
    );
  }

  /// 发送喝水提醒
  static Future<void> sendWaterReminder() async {
    await showNotification(
      id: 4,
      title: '💧 喝水提醒',
      body: '记得喝水哦，保持身体水分~',
      payload: 'water',
      channelKey: CHANNEL_WATER_REMINDER,
    );
  }

  /// 发送休息提醒
  static Future<void> sendRestReminder() async {
    await showNotification(
      id: 5,
      title: '🧘 休息时间',
      body: '休息一下，放松身心~',
      payload: 'rest',
      channelKey: CHANNEL_REST_REMINDER,
    );
  }

  /// 发送天气关怀提醒
  static Future<void> sendWeatherReminder(String message) async {
    await showNotification(
      id: 6,
      title: '🌤️ 天气关怀',
      body: message,
      payload: 'weather',
      channelKey: CHANNEL_WEATHER,
    );
  }
}