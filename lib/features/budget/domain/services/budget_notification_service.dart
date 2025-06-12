// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:money_track/domain/entities/transaction_entity.dart';
// import 'package:money_track/features/budget/domain/entities/budget_entity.dart';
// import 'package:money_track/features/budget/domain/utils/budget_progress_calculator.dart';

// /// Service for handling budget notifications
// class BudgetNotificationService {
//   final FlutterLocalNotificationsPlugin _notificationsPlugin;

//   // Notification thresholds (percentage of budget used)
//   static const double _warningThreshold = 0.8; // 80%
//   static const double _criticalThreshold = 0.95; // 95%

//   // Notification channels
//   static const String _warningChannelId = 'budget_warning_channel';
//   static const String _criticalChannelId = 'budget_critical_channel';

//   BudgetNotificationService(this._notificationsPlugin);

//   /// Initialize the notification service
//   Future<void> initialize() async {
//     // Android initialization
//     final AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     // iOS initialization
//     final DarwinInitializationSettings initializationSettingsIOS =
//         DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//       onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
//     );

//     // Initialize settings for both platforms
//     final InitializationSettings initializationSettings =
//         InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: initializationSettingsIOS,
//     );

//     // Initialize the plugin
//     await _notificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
//     );

//     // Create notification channels for Android
//     if (Platform.isAndroid) {
//       await _createNotificationChannels();
//     }
//   }

//   // Create notification channels for Android
//   Future<void> _createNotificationChannels() async {
//     // Warning channel
//     const AndroidNotificationChannel warningChannel =
//         AndroidNotificationChannel(
//       _warningChannelId,
//       'Budget Warnings',
//       description: 'Notifications for budgets approaching their limits',
//       importance: Importance.high,
//     );

//     // Critical channel
//     const AndroidNotificationChannel criticalChannel =
//         AndroidNotificationChannel(
//       _criticalChannelId,
//       'Budget Alerts',
//       description:
//           'Notifications for budgets that have almost reached their limits',
//       importance: Importance.max,
//     );

//     // Create the channels
//     await _notificationsPlugin
//         .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(warningChannel);

//     await _notificationsPlugin
//         .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(criticalChannel);
//   }

//   // Handle iOS notification when app is in foreground (iOS < 10)
//   void _onDidReceiveLocalNotification(
//       int id, String? title, String? body, String? payload) {
//     debugPrint('Received iOS notification: $title');
//   }

//   // Handle notification response when user taps on notification
//   void _onDidReceiveNotificationResponse(NotificationResponse response) {
//     debugPrint('Notification response received: ${response.payload}');
//   }

//   /// Check budgets and send notifications if thresholds are reached
//   Future<void> checkBudgetsAndNotify(
//     List<BudgetEntity> budgets,
//     List<TransactionEntity> transactions,
//   ) async {
//     for (final budget in budgets) {
//       if (!budget.isActive) continue;

//       final double usedPercentage =
//           BudgetProgressCalculator.calculateBudgetUsedPercentage(
//         budget,
//         transactions,
//       );

//       if (usedPercentage >= _criticalThreshold) {
//         await _showCriticalBudgetNotification(budget, usedPercentage);
//       } else if (usedPercentage >= _warningThreshold) {
//         await _showWarningBudgetNotification(budget, usedPercentage);
//       }
//     }
//   }

//   /// Show a warning notification when budget is approaching the limit
//   Future<void> _showWarningBudgetNotification(
//     BudgetEntity budget,
//     double percentage,
//   ) async {
//     final int percentageInt = (percentage * 100).round();

//     // Android notification details
//     final AndroidNotificationDetails androidDetails =
//         AndroidNotificationDetails(
//       _warningChannelId,
//       'Budget Warnings',
//       channelDescription: 'Notifications for budgets approaching their limits',
//       importance: Importance.high,
//       priority: Priority.high,
//     );

//     // iOS notification details
//     const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//     );

//     // Combined notification details
//     final NotificationDetails notificationDetails = NotificationDetails(
//       android: androidDetails,
//       iOS: iOSDetails,
//     );

//     await _notificationsPlugin.show(
//       budget.id.hashCode, // Use budget ID hash as notification ID
//       'Budget Warning',
//       'Your ${budget.name} budget is at $percentageInt% of its limit',
//       notificationDetails,
//       payload: 'budget_warning_${budget.id}',
//     );
//   }

//   /// Show a critical notification when budget is almost depleted
//   Future<void> _showCriticalBudgetNotification(
//     BudgetEntity budget,
//     double percentage,
//   ) async {
//     final int percentageInt = (percentage * 100).round();

//     // Android notification details
//     final AndroidNotificationDetails androidDetails =
//         AndroidNotificationDetails(
//       _criticalChannelId,
//       'Budget Alerts',
//       channelDescription:
//           'Notifications for budgets that have almost reached their limits',
//       importance: Importance.max,
//       priority: Priority.max,
//     );

//     // iOS notification details
//     const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//     );

//     // Combined notification details
//     final NotificationDetails notificationDetails = NotificationDetails(
//       android: androidDetails,
//       iOS: iOSDetails,
//     );

//     await _notificationsPlugin.show(
//       budget.id.hashCode +
//           1000, // Use budget ID hash + offset as notification ID
//       'Budget Alert',
//       'Your ${budget.name} budget is at $percentageInt% of its limit!',
//       notificationDetails,
//       payload: 'budget_critical_${budget.id}',
//     );
//   }
// }
