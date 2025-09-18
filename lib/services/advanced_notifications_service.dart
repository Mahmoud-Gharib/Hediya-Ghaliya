import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'github_chat_api.dart';
import 'notifications_api.dart';

class AdvancedNotificationsService {
  static const String _lastCheckKey = 'last_notification_check';
  static const String _userPhoneKey = 'user_phone';
  static const String _isLoggedInKey = 'is_logged_in';
  
  static Timer? _backgroundTimer;
  static bool _isInitialized = false;
  static String? _currentUserPhone;

  // Initialize the service
  static Future<void> initialize(String userPhone) async {
    if (_isInitialized) return;
    
    _currentUserPhone = userPhone;
    _isInitialized = true;
    
    // Save user info for background checks
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userPhoneKey, userPhone);
    await prefs.setBool(_isLoggedInKey, true);
    
    // Request notification permissions
    await _requestPermissions();
    
    // Start background monitoring
    await startBackgroundMonitoring();
    
    print('🔔 Advanced Notifications Service initialized for user: $userPhone');
  }

  // Request necessary permissions
  static Future<void> _requestPermissions() async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      await Permission.notification.request();
      
      if (Platform.isAndroid) {
        await Permission.ignoreBatteryOptimizations.request();
      }
    }
  }

  // Start background monitoring
  static Future<void> startBackgroundMonitoring() async {
    if (_backgroundTimer?.isActive == true) return;
    
    _backgroundTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      await _checkForNewMessages();
    });
    
    print('🔄 Background monitoring started');
  }

  // Stop background monitoring
  static void stopBackgroundMonitoring() {
    _backgroundTimer?.cancel();
    _backgroundTimer = null;
    print('⏹️ Background monitoring stopped');
  }

  // Check for new messages in background
  static Future<void> _checkForNewMessages() async {
    try {
      if (_currentUserPhone == null) {
        final prefs = await SharedPreferences.getInstance();
        _currentUserPhone = prefs.getString(_userPhoneKey);
        final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
        
        if (!isLoggedIn || _currentUserPhone == null) {
          return; // User not logged in
        }
      }

      final prefs = await SharedPreferences.getInstance();
      final lastCheck = prefs.getInt(_lastCheckKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      // Check for new chat messages
      final chatData = await GitHubChatApi.fetchChat(_currentUserPhone!);
      final adminMessages = chatData.messages
          .where((m) => m.senderPhone == '01147857132') // Admin phone
          .where((m) {
            final msgTime = DateTime.tryParse(m.timestamp)?.millisecondsSinceEpoch ?? 0;
            return msgTime > lastCheck;
          })
          .toList();

      // Check for new notifications
      final notificationData = await NotificationsApi.fetch(_currentUserPhone!);
      final newNotifications = notificationData.items
          .where((n) {
            final notifTime = DateTime.tryParse(n.createdAt)?.millisecondsSinceEpoch ?? 0;
            return notifTime > lastCheck;
          })
          .toList();

      // Show notifications for new messages
      for (final message in adminMessages) {
        await _showChatNotification(message);
      }

      // Show notifications for new app notifications
      for (final notification in newNotifications) {
        if (notification.type != 'chat') { // Don't duplicate chat notifications
          await _showAppNotification(notification);
        }
      }

      // Update last check time
      await prefs.setInt(_lastCheckKey, now);
      
    } catch (e) {
      print('❌ Error checking for new messages: $e');
    }
  }

  // Show chat notification
  static Future<void> _showChatNotification(Message message) async {
    final title = 'رسالة جديدة من الدعم';
    String body = message.text;
    
    // Customize body based on message type
    switch (message.type) {
      case MessageType.image:
        body = '📷 صورة';
        if (message.text.isNotEmpty) body += ': ${message.text}';
        break;
      case MessageType.video:
        body = '🎬 فيديو';
        if (message.text.isNotEmpty) body += ': ${message.text}';
        break;
      case MessageType.file:
        body = '📎 ملف: ${message.attachment?.fileName ?? 'ملف'}';
        if (message.text.isNotEmpty) body += '\n${message.text}';
        break;
      case MessageType.voice:
        body = '🎤 رسالة صوتية';
        if (message.text.isNotEmpty) body += ': ${message.text}';
        break;
      case MessageType.text:
        // Keep original text
        break;
    }

    await _showSystemNotification(
      title: title,
      body: body,
      payload: jsonEncode({
        'type': 'chat',
        'route': '/chat_user',
        'args': {'phone': _currentUserPhone},
      }),
    );
  }

  // Show app notification
  static Future<void> _showAppNotification(NotificationItem notification) async {
    await _showSystemNotification(
      title: notification.title,
      body: notification.body,
      payload: jsonEncode({
        'type': 'app',
        'route': notification.route,
        'args': notification.args,
      }),
    );
  }

  // Show system notification (platform-specific)
  static Future<void> _showSystemNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      if (kIsWeb) {
        // Web notifications
        await _showWebNotification(title, body, payload);
      } else if (Platform.isAndroid || Platform.isIOS) {
        // Mobile notifications
        await _showMobileNotification(title, body, payload);
      } else {
        // Desktop notifications
        await _showDesktopNotification(title, body, payload);
      }
    } catch (e) {
      print('❌ Error showing notification: $e');
    }
  }

  // Web notifications
  static Future<void> _showWebNotification(String title, String body, String? payload) async {
    // For web, we'll use browser notifications API through JS interop
    // This is a simplified version - in production you'd use a proper web notification package
    print('🌐 Web Notification: $title - $body');
    
    // You could implement actual web notifications here using js package
    // For now, we'll just log and could show an in-app notification
  }

  // Mobile notifications
  static Future<void> _showMobileNotification(String title, String body, String? payload) async {
    // For mobile, you'd typically use flutter_local_notifications
    // Since we're keeping it simple with GitHub only, we'll simulate
    print('📱 Mobile Notification: $title - $body');
    
    // Play notification sound
    try {
      await SystemSound.play(SystemSoundType.alert);
    } catch (e) {
      print('Could not play notification sound: $e');
    }
  }

  // Desktop notifications
  static Future<void> _showDesktopNotification(String title, String body, String? payload) async {
    // For desktop, you could use system notifications
    print('🖥️ Desktop Notification: $title - $body');
  }

  // Handle user logout
  static Future<void> onUserLogout() async {
    stopBackgroundMonitoring();
    _currentUserPhone = null;
    _isInitialized = false;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, false);
    await prefs.remove(_userPhoneKey);
    
    print('👋 User logged out - notifications stopped');
  }

  // Handle app resume (when user returns to app)
  static Future<void> onAppResume() async {
    if (_isInitialized && _currentUserPhone != null) {
      await _checkForNewMessages();
    }
  }

  // Handle app pause (when user leaves app)
  static Future<void> onAppPause() async {
    // Continue background monitoring even when app is paused
    // This ensures notifications work when app is in background
  }

  // Get notification history
  static Future<List<Map<String, dynamic>>> getNotificationHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList('notification_history') ?? [];
    
    return historyJson
        .map((json) => jsonDecode(json) as Map<String, dynamic>)
        .toList();
  }


  // Clear notification history
  static Future<void> clearNotificationHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notification_history');
  }

  // Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    if (kIsWeb) return true; // Web notifications are always "enabled" for our purposes
    
    final status = await Permission.notification.status;
    return status == PermissionStatus.granted;
  }

  // Open notification settings
  static Future<void> openNotificationSettings() async {
    if (!kIsWeb) {
      await openAppSettings();
    }
  }
}
