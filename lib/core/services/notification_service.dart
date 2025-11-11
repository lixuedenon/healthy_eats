// lib/core/services/notification_service.dart
// Dart类文件

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../data/models/reminder_model.dart';

/// 通知服务
///
/// 管理本地通知的显示和调度
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  // ==================== 初始化 ====================

  /// 初始化通知服务
  static Future<void> initialize() async {
    if (_initialized) return;

    // Android初始化设置
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS初始化设置
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  /// 通知被点击时的回调
  static void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    // TODO: 处理通知点击事件
  }

  // ==================== 请求权限 ====================

  /// 请求通知权限（iOS）
  static Future<bool> requestPermissions() async {
    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true; // Android默认已授权
  }

  // ==================== 显示通知 ====================

  /// 显示即时通知
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'healthy_eats_channel',
      'Healthy Eats Notifications',
      channelDescription: '健康饮食提醒',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // ==================== 调度通知 ====================

  /// 调度每日定时通知
  static Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // 如果今天的时间已过，则安排到明天
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'healthy_eats_reminders',
      'Meal Reminders',
      channelDescription: '用餐提醒',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // 每天重复
      payload: payload,
    );
  }

  /// 调度提醒列表
  static Future<void> scheduleReminders(List<Reminder> reminders) async {
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

      await scheduleDailyNotification(
        id: reminder.id.hashCode,
        title: reminder.title,
        body: reminder.message ?? '',
        hour: hour,
        minute: minute,
        payload: reminder.type,
      );
    }
  }

  // ==================== 取消通知 ====================

  /// 取消指定通知
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// 取消所有通知
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // ==================== 查询通知 ====================

  /// 获取待处理的通知列表
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// 获取活跃的通知列表
  static Future<List<ActiveNotification>> getActiveNotifications() async {
    final plugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (plugin != null) {
      return await plugin.getActiveNotifications();
    }

    return [];
  }

  // ==================== 预设通知 ====================

  /// 发送早餐提醒
  static Future<void> sendBreakfastReminder() async {
    await showNotification(
      id: 1,
      title: '🌅 早餐时间',
      body: '该吃早餐啦！开始美好的一天~',
      payload: 'breakfast',
    );
  }

  /// 发送午餐提醒
  static Future<void> sendLunchReminder() async {
    await showNotification(
      id: 2,
      title: '☀️ 午餐时间',
      body: '中午了，记得按时吃午饭哦~',
      payload: 'lunch',
    );
  }

  /// 发送晚餐提醒
  static Future<void> sendDinnerReminder() async {
    await showNotification(
      id: 3,
      title: '🌙 晚餐时间',
      body: '晚餐时间到了，享受美食吧~',
      payload: 'dinner',
    );
  }

  /// 发送喝水提醒
  static Future<void> sendWaterReminder() async {
    await showNotification(
      id: 4,
      title: '💧 喝水提醒',
      body: '记得喝水哦，保持身体水分~',
      payload: 'water',
    );
  }

  /// 发送休息提醒
  static Future<void> sendRestReminder() async {
    await showNotification(
      id: 5,
      title: '🧘 休息时间',
      body: '休息一下，放松身心~',
      payload: 'rest',
    );
  }

  /// 发送天气关怀提醒
  static Future<void> sendWeatherReminder(String message) async {
    await showNotification(
      id: 6,
      title: '🌤️ 天气关怀',
      body: message,
      payload: 'weather',
    );
  }
}