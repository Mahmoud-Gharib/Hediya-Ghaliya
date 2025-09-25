import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

import 'github_chat_api.dart';
import 'notifications_api.dart';

class AdvancedNotificationsService 
{
  static const String _lastCheckKey  = 'last_notification_check';
  static const String _userPhoneKey  = 'user_phone';
  static const String _isLoggedInKey = 'is_logged_in';
  
  static Timer?  _backgroundTimer;
  static bool    _isInitialized = false;
  static String? _currentUserPhone;

  static Future<void> initialize(String userPhone) async 
  {
    if (_isInitialized) return;
    
    _currentUserPhone = userPhone;
    _isInitialized = true;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userPhoneKey, userPhone);
    await prefs.setBool(_isLoggedInKey, true);
    await _requestPermissions();
    await startBackgroundMonitoring();
    print('🔔 Advanced Notifications Service initialized for user: $userPhone');
  }

  static Future<void> _requestPermissions() async 
  {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) 
	{
      await Permission.notification.request();
      
      if (Platform.isAndroid) 
	  {
        await Permission.ignoreBatteryOptimizations.request();
      }
    }
  }

  static Future<void> startBackgroundMonitoring() async 
  {
    if (_backgroundTimer?.isActive == true) return;
    _backgroundTimer = Timer.periodic(const Duration(seconds: 10), (timer) async 
	{
      await _checkForNewMessages();
    });
    print('🔄 Background monitoring started');
  }

  static void stopBackgroundMonitoring() 
  {
    _backgroundTimer?.cancel();
    _backgroundTimer = null;
    print('⏹️ Background monitoring stopped');
  }

  static Future<void> _checkForNewMessages() async 
  {
    try 
	{
      if (_currentUserPhone == null) 
	  {
        final prefs = await SharedPreferences.getInstance();
        _currentUserPhone = prefs.getString(_userPhoneKey);
        final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
        
        if (!isLoggedIn || _currentUserPhone == null) 
		{
          return; 
        }
      }

      final prefs = await SharedPreferences.getInstance();
      final lastCheck = prefs.getInt(_lastCheckKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      final chatData = await GitHubChatApi.fetchChat(_currentUserPhone!);
      final adminMessages = chatData.messages
          .where((m) => m.senderPhone == '01147857132') 
          .where((m) 
		  {
            final msgTime = DateTime.tryParse(m.timestamp)?.millisecondsSinceEpoch ?? 0;
            return msgTime > lastCheck;
          })
          .toList();

      final notificationData = await NotificationsApi.fetch(_currentUserPhone!);
      final newNotifications = notificationData.items
          .where((n) 
		  {
            final notifTime = DateTime.tryParse(n.createdAt)?.millisecondsSinceEpoch ?? 0;
            return notifTime > lastCheck;
          })
          .toList();

      for (final message in adminMessages) 
	  {
        await _showChatNotification(message);
      }

      for (final notification in newNotifications) 
	  {
        if (notification.type != 'chat') 
		{ 
          await _showAppNotification(notification);
        }
      }
      await prefs.setInt(_lastCheckKey, now);
      
    } 
	catch (e) 
	{
      print('❌ Error checking for new messages: $e');
    }
  }

  static Future<void> _showChatNotification(Message message) async 
  {
    final title = 'رسالة جديدة من الدعم';
    String body = message.text;
    
    switch (message.type) 
	{
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
        break;
    }

    await _showSystemNotification
	(
      title: title,
      body: body,
      payload: jsonEncode
	  (
	  {
        'type': 'chat',
        'route': '/chat_user',
        'args': {'phone': _currentUserPhone},
      }),
    );
  }

  static Future<void> _showAppNotification(NotificationItem notification) async 
  {
    await _showSystemNotification
	(
      title: notification.title,
      body: notification.body,
      payload: jsonEncode
	  (
	   {
        'type': 'app',
        'route': notification.route,
        'args': notification.args,
       }
	  ),
    );
  }

  static Future<void> _showSystemNotification
  (
   {
    required String title,
    required String body,
    String? payload,
   }
  ) async 
  {
    try 
	{
      if (kIsWeb) 
	  {
        await _showWebNotification(title, body, payload);
      } 
	  else if (Platform.isAndroid || Platform.isIOS) 
	  {
        await _showMobileNotification(title, body, payload);
      } 
	  else 
	  {
        await _showDesktopNotification(title, body, payload);
      }
    } 
	catch (e) 
	{
      print('❌ Error showing notification: $e');
    }
  }

  static Future<void> _showWebNotification(String title, String body, String? payload) async 
  {
    print('🌐 Web Notification: $title - $body');
  }

  static Future<void> _showMobileNotification(String title, String body, String? payload) async 
  {
    print('📱 Mobile Notification: $title - $body');
    try 
	{
      await SystemSound.play(SystemSoundType.alert);
    } 
	catch (e) 
	{
      print('Could not play notification sound: $e');
    }
  }

  static Future<void> _showDesktopNotification(String title, String body, String? payload) async 
  {
    print('🖥️ Desktop Notification: $title - $body');
  }

  static Future<void> onUserLogout() async 
  {
    stopBackgroundMonitoring();
    _currentUserPhone = null;
    _isInitialized = false;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, false);
    await prefs.remove(_userPhoneKey);
    
    print('👋 User logged out - notifications stopped');
  }

  static Future<void> onAppResume() async 
  {
    if (_isInitialized && _currentUserPhone != null) 
	{
      await _checkForNewMessages();
    }
  }

  static Future<void> onAppPause() async 
  {

  }

  static Future<List<Map<String, dynamic>>> getNotificationHistory() async 
  {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList('notification_history') ?? [];
    
    return historyJson
        .map((json) => jsonDecode(json) as Map<String, dynamic>)
        .toList();
  }

  static Future<void> clearNotificationHistory() async 
  {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notification_history');
  }

  static Future<bool> areNotificationsEnabled() async 
  {
    if (kIsWeb) return true; 
    
    final status = await Permission.notification.status;
    return status == PermissionStatus.granted;
  }

  static Future<void> openNotificationSettings() async 
  {
    if (!kIsWeb) 
	{
      await openAppSettings();
    }
  }
}
