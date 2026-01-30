import 'dart:io';
import 'dart:ui';

import 'package:api_sdk/log_util.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:share_plus/share_plus.dart';

class LocalNotificationService {
  static final LocalNotificationService _instance =
      LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize the local notification service
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@drawable/wealthy_push_notification');

      final List<DarwinNotificationCategory> darwinNotificationCategories =
          <DarwinNotificationCategory>[
        DarwinNotificationCategory(
          'download_category',
          actions: <DarwinNotificationAction>[
            DarwinNotificationAction.plain('open_file', 'Open'),
          ],
        ),
      ];

      final DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        notificationCategories: darwinNotificationCategories,
      );

      final InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _isInitialized = true;
      LogUtil.printLog('LocalNotificationService initialized successfully');
    } catch (error) {
      LogUtil.printLog('Error initializing LocalNotificationService: $error');
    }
  }

  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse notificationResponse) {
    final payload = notificationResponse.payload;
    if (payload != null) {
      _openFileEnhanced(payload);
    }
  }

  /// Open file using the enhanced method with fallbacks
  static Future<void> _openFile(String filePath) async {
    await _openFileEnhanced(filePath);
  }

  /// Enhanced method to open file with fallback options
  static Future<void> _openFileEnhanced(String filePath) async {
    try {
      LogUtil.printLog('Attempting to open file: $filePath');

      if (Platform.isIOS && !await File(filePath).exists()) {
        // On iOS, if file doesn't exist at path, try sharing instead
        LogUtil.printLog('File not found, attempting to share instead');
        await _shareFile(filePath);
        return;
      }

      // Try to open the file
      final file = File(filePath);
      if (await file.exists()) {
        final result = await OpenFile.open(filePath);
        LogUtil.printLog('File open result: ${result.message}');

        if (result.type != ResultType.done) {
          LogUtil.printLog(
              'Failed to open file directly, trying alternative methods');
          await _handleFileOpenFallback(filePath);
        }
      } else {
        LogUtil.printLog('File does not exist at path: $filePath');
        await _handleFileOpenFallback(filePath);
      }
    } catch (error) {
      LogUtil.printLog('Error opening file: $error');
      await _handleFileOpenFallback(filePath);
    }
  }

  /// Handle fallback options when direct file opening fails
  static Future<void> _handleFileOpenFallback(String filePath) async {
    try {
      // For both iOS and Android, try sharing the file as fallback
      await _shareFile(filePath);
    } catch (error) {
      LogUtil.printLog('Error in fallback file handling: $error');
    }
  }

  /// Share file using the system share sheet
  static Future<void> _shareFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(filePath)],
            text: 'Check out this file!',
            sharePositionOrigin: Rect.fromLTWH(0, 0, 100, 100),
          ),
        );
        LogUtil.printLog('File shared successfully');
      } else {
        LogUtil.printLog('Cannot share file - file does not exist: $filePath');
      }
    } catch (error) {
      LogUtil.printLog('Error sharing file: $error');
    }
  }

  /// Request notification permissions (mainly for iOS)
  Future<bool> requestPermissions() async {
    try {
      if (Platform.isIOS) {
        final result = await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
        return result ?? false;
      }
      return true; // Android doesn't need explicit permission for local notifications
    } catch (error) {
      LogUtil.printLog('Error requesting notification permissions: $error');
      return false;
    }
  }

  /// Show a local notification for successful file download
  Future<void> showDownloadSuccessNotification({
    required String title,
    required String body,
    required String filePath,
    int? id,
  }) async {
    try {
      await init(); // Ensure service is initialized

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'download_channel',
        'Download Notifications',
        channelDescription: 'Notifications for successful file downloads',
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'Download completed',
        largeIcon: DrawableResourceAndroidBitmap(
            '@drawable/wealthy_push_notification'),
        styleInformation: DefaultStyleInformation(true, true),
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction(
            'open_file',
            'Open',
            showsUserInterface: true,
          ),
        ],
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        categoryIdentifier: 'download_category',
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _flutterLocalNotificationsPlugin.show(
        id ?? DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        platformChannelSpecifics,
        payload: filePath,
      );

      LogUtil.printLog('Download notification shown successfully');
    } catch (error) {
      LogUtil.printLog('Error showing download notification: $error');
    }
  }

  /// Show a local notification for birthday card download
  Future<void> showBirthdayCardDownloadNotification({
    required String clientName,
    required String filePath,
  }) async {
    await showDownloadSuccessNotification(
      title: 'Birthday Card Downloaded',
      body:
          'Birthday card for $clientName has been saved successfully. Tap to open.',
      filePath: filePath,
      id: 1001, // Use a specific ID for birthday card notifications
    );
  }

  /// Show a local notification for resource download
  Future<void> showResourceDownloadNotification({
    required String fileName,
    required String filePath,
  }) async {
    await showDownloadSuccessNotification(
      title: 'File Downloaded',
      body: '$fileName has been saved successfully. Tap to open.',
      filePath: filePath,
      id: 1002, // Use a specific ID for resource notifications
    );
  }

  /// Show a notification when file cannot be opened
  Future<void> showFileOpenFailedNotification({
    required String clientName,
  }) async {
    try {
      await init(); // Ensure service is initialized

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'download_channel',
        'Download Notifications',
        channelDescription: 'Notifications for file operations',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        ticker: 'File open failed',
        largeIcon: DrawableResourceAndroidBitmap(
            '@drawable/wealthy_push_notification'),
        styleInformation: DefaultStyleInformation(true, true),
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        'File Saved Successfully',
        'Birthday card for $clientName was saved to your gallery. You can find it in your photos app.',
        platformChannelSpecifics,
      );

      LogUtil.printLog('File open failed notification shown successfully');
    } catch (error) {
      LogUtil.printLog('Error showing file open failed notification: $error');
    }
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(id);
    } catch (error) {
      LogUtil.printLog('Error canceling notification: $error');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
    } catch (error) {
      LogUtil.printLog('Error canceling all notifications: $error');
    }
  }
}
