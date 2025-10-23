import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:money_track/features/groups/domain/entities/shared_expense_entity.dart';
import 'package:money_track/features/groups/domain/entities/settlement_entity.dart';
import 'package:money_track/features/groups/domain/entities/group_entity.dart';
import 'package:money_track/features/groups/domain/services/recurring_expense_service.dart';

enum NotificationType {
  expenseAdded,
  expenseUpdated,
  settlementRequested,
  settlementConfirmed,
  settlementReminder,
  recurringExpenseGenerated,
  balanceUpdate,
  groupInvitation,
  paymentReminder,
}

class NotificationPayload {
  final NotificationType type;
  final String groupId;
  final String? expenseId;
  final String? settlementId;
  final String? templateId;
  final Map<String, dynamic>? additionalData;

  const NotificationPayload({
    required this.type,
    required this.groupId,
    this.expenseId,
    this.settlementId,
    this.templateId,
    this.additionalData,
  });

  String toJson() {
    return '{'
        '"type":"${type.name}",'
        '"groupId":"$groupId",'
        '"expenseId":"${expenseId ?? ''}",'
        '"settlementId":"${settlementId ?? ''}",'
        '"templateId":"${templateId ?? ''}",'
        '"additionalData":${additionalData?.toString() ?? '{}'}'
        '}';
  }

  static NotificationPayload fromJson(String json) {
    // Simple JSON parsing - in production, use proper JSON parsing
    final data = json.replaceAll('{', '').replaceAll('}', '').split(',');
    final map = <String, String>{};

    for (final item in data) {
      final parts = item.split(':');
      if (parts.length == 2) {
        map[parts[0].replaceAll('"', '')] = parts[1].replaceAll('"', '');
      }
    }

    return NotificationPayload(
      type: NotificationType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => NotificationType.expenseAdded,
      ),
      groupId: map['groupId'] ?? '',
      expenseId: map['expenseId']?.isEmpty == true ? null : map['expenseId'],
      settlementId:
          map['settlementId']?.isEmpty == true ? null : map['settlementId'],
      templateId: map['templateId']?.isEmpty == true ? null : map['templateId'],
    );
  }
}

class GroupNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  /// Initialize the notification service
  static Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
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

    _isInitialized = true;
  }

  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      final payload = NotificationPayload.fromJson(response.payload!);
      // Handle navigation based on notification type
      _handleNotificationNavigation(payload);
    }
  }

  /// Handle navigation when notification is tapped
  static void _handleNotificationNavigation(NotificationPayload payload) {
    // This would typically use a navigation service or router
    // For now, we'll just print the action
    print('Navigate to: ${payload.type.name} for group ${payload.groupId}');

    switch (payload.type) {
      case NotificationType.expenseAdded:
      case NotificationType.expenseUpdated:
        // Navigate to expense details or group page
        break;
      case NotificationType.settlementRequested:
      case NotificationType.settlementConfirmed:
      case NotificationType.settlementReminder:
        // Navigate to settlement details or settlements page
        break;
      case NotificationType.recurringExpenseGenerated:
        // Navigate to expense details
        break;
      case NotificationType.balanceUpdate:
        // Navigate to balance overview
        break;
      case NotificationType.groupInvitation:
        // Navigate to group invitation page
        break;
      case NotificationType.paymentReminder:
        // Navigate to payment/settlement page
        break;
    }
  }

  /// Request notification permissions
  static Future<bool> requestPermissions() async {
    await initialize();

    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }

    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    return true;
  }

  /// Show notification for new expense
  static Future<void> notifyExpenseAdded(
    SharedExpenseEntity expense,
    GroupEntity group,
  ) async {
    await _showNotification(
      id: expense.id.hashCode,
      title: 'New Expense in ${group.name}',
      body:
          '${expense.primaryPayer?.memberName ?? 'Unknown'} added "${expense.title}" for \$${expense.totalAmount}',
      payload: NotificationPayload(
        type: NotificationType.expenseAdded,
        groupId: group.id,
        expenseId: expense.id,
      ),
    );
  }

  /// Show notification for expense update
  static Future<void> notifyExpenseUpdated(
    SharedExpenseEntity expense,
    GroupEntity group,
  ) async {
    await _showNotification(
      id: expense.id.hashCode,
      title: 'Expense Updated in ${group.name}',
      body: '"${expense.description}" has been updated',
      payload: NotificationPayload(
        type: NotificationType.expenseUpdated,
        groupId: group.id,
        expenseId: expense.id,
      ),
    );
  }

  /// Show notification for settlement request
  static Future<void> notifySettlementRequested(
    SettlementEntity settlement,
    GroupEntity group,
  ) async {
    await _showNotification(
      id: settlement.id.hashCode,
      title: 'Settlement Request in ${group.name}',
      body:
          '${settlement.payerName} owes ${settlement.receiverName} \$${settlement.amount}',
      payload: NotificationPayload(
        type: NotificationType.settlementRequested,
        groupId: group.id,
        settlementId: settlement.id,
      ),
    );
  }

  /// Show notification for settlement confirmation
  static Future<void> notifySettlementConfirmed(
    SettlementEntity settlement,
    GroupEntity group,
  ) async {
    await _showNotification(
      id: settlement.id.hashCode,
      title: 'Settlement Confirmed in ${group.name}',
      body: 'Payment of \$${settlement.amount} has been confirmed',
      payload: NotificationPayload(
        type: NotificationType.settlementConfirmed,
        groupId: group.id,
        settlementId: settlement.id,
      ),
    );
  }

  /// Show notification for recurring expense generation
  static Future<void> notifyRecurringExpenseGenerated(
    SharedExpenseEntity expense,
    RecurringExpenseTemplate template,
    GroupEntity group,
  ) async {
    await _showNotification(
      id: expense.id.hashCode,
      title: 'Recurring Expense in ${group.name}',
      body: 'Generated "${expense.description}" for \$${expense.totalAmount}',
      payload: NotificationPayload(
        type: NotificationType.recurringExpenseGenerated,
        groupId: group.id,
        expenseId: expense.id,
        templateId: template.id,
      ),
    );
  }

  /// Show notification for balance update
  static Future<void> notifyBalanceUpdate(
    GroupEntity group,
    String memberName,
    double newBalance,
  ) async {
    final balanceText = newBalance >= 0
        ? 'is owed \$${newBalance.abs()}'
        : 'owes \$${newBalance.abs()}';

    await _showNotification(
      id: '${group.id}_balance'.hashCode,
      title: 'Balance Update in ${group.name}',
      body: '$memberName $balanceText',
      payload: NotificationPayload(
        type: NotificationType.balanceUpdate,
        groupId: group.id,
      ),
    );
  }

  /// Show payment reminder notification
  static Future<void> notifyPaymentReminder(
    SettlementEntity settlement,
    GroupEntity group,
  ) async {
    await _showNotification(
      id: '${settlement.id}_reminder'.hashCode,
      title: 'Payment Reminder',
      body:
          'Don\'t forget to settle \$${settlement.amount} with ${settlement.receiverName}',
      payload: NotificationPayload(
        type: NotificationType.paymentReminder,
        groupId: group.id,
        settlementId: settlement.id,
      ),
    );
  }

  /// Schedule recurring payment reminders
  static Future<void> schedulePaymentReminders(
    List<SettlementEntity> pendingSettlements,
    GroupEntity group,
  ) async {
    for (final settlement in pendingSettlements) {
      // Schedule reminder for 3 days from now
      final reminderDate = DateTime.now().add(const Duration(days: 3));

      await _scheduleNotification(
        id: '${settlement.id}_reminder'.hashCode,
        title: 'Payment Reminder',
        body: 'Settlement of \$${settlement.amount} is still pending',
        scheduledDate: reminderDate,
        payload: NotificationPayload(
          type: NotificationType.paymentReminder,
          groupId: group.id,
          settlementId: settlement.id,
        ),
      );
    }
  }

  /// Show a notification immediately
  static Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    required NotificationPayload payload,
  }) async {
    await initialize();

    const androidDetails = AndroidNotificationDetails(
      'group_notifications',
      'Group Notifications',
      channelDescription: 'Notifications for group expense activities',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id,
      title,
      body,
      details,
      payload: payload.toJson(),
    );
  }

  /// Schedule a notification for later
  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required NotificationPayload payload,
  }) async {
    await initialize();

    const androidDetails = AndroidNotificationDetails(
      'scheduled_notifications',
      'Scheduled Notifications',
      channelDescription: 'Scheduled reminders and notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      payload: payload.toJson(),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancel a scheduled notification
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Get pending notifications
  static Future<List<PendingNotificationRequest>>
      getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
