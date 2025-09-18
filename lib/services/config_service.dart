import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ConfigService {
  static const String _configUrl =
      'https://raw.githubusercontent.com/mahmoud-gharib/app-config/main/config.json';
  static const String _cacheKey = 'app_config_cache';
  static const String _cacheTimeKey = 'config_cache_time';
  static const int _cacheValidityHours = 1; // Cache for 24 hours

  static Map<String, dynamic>? _cachedConfig;

  /// Get configuration with caching mechanism
  static Future<Map<String, dynamic>> getConfig() async {
    // Check if we have valid cached config
    if (_cachedConfig != null) {
      return _cachedConfig!;
    }

    final prefs = await SharedPreferences.getInstance();
    final cachedConfigString = prefs.getString(_cacheKey);
    final cacheTime = prefs.getInt(_cacheTimeKey) ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    // Check if cached config is still valid (within 24 hours)
    if (cachedConfigString != null &&
        (currentTime - cacheTime) < (_cacheValidityHours * 60 * 60 * 1000)) {
      try {
        _cachedConfig = json.decode(cachedConfigString);
        return _cachedConfig!;
      } catch (e) {
        // If cached config is corrupted, continue to fetch new one
      }
    }

    // Check if we're on mobile platform - only try GitHub on mobile
    if (!kIsWeb) {
      // Mobile platform - try to fetch from GitHub
      try {
        print('📱 منصة موبايل - محاولة تحميل الإعدادات من: $_configUrl');
        final response = await http.get(
          Uri.parse(_configUrl),
          headers: {
            'Accept': 'application/json',
            'Cache-Control': 'no-cache',
          },
        ).timeout(const Duration(seconds: 10));
        
        print('📡 استجابة الخادم: ${response.statusCode}');
        
        if (response.statusCode == 200) {
          final configData = json.decode(response.body);
          print('✅ تم تحميل الإعدادات بنجاح من GitHub على الموبايل');
          
          // Cache the new config
          await prefs.setString(_cacheKey, response.body);
          await prefs.setInt(_cacheTimeKey, currentTime);
          
          _cachedConfig = configData;
          return configData;
        } else {
          print('❌ فشل تحميل الإعدادات: ${response.statusCode}');
          throw Exception('Failed to load config: ${response.statusCode}');
        }
      } catch (e) {
        print('💥 خطأ في تحميل الإعدادات من GitHub على الموبايل: $e');
        
        // If network fails, try to use cached config even if expired
        if (cachedConfigString != null) {
          try {
            print('🔄 استخدام الإعدادات المحفوظة مؤقتاً');
            _cachedConfig = json.decode(cachedConfigString);
            return _cachedConfig!;
          } catch (e) {
            print('❌ الإعدادات المحفوظة تالفة');
          }
        }
        
        // Fallback to default config if everything fails
        print('🔧 استخدام الإعدادات الافتراضية على الموبايل');
        _cachedConfig = _getFallbackConfig();
        return _cachedConfig!;
      }
    } else {
      // Web platform - use fallback config directly to avoid CORS
      print('🌐 منصة ويب - استخدام الإعدادات المحلية (تجنب مشاكل CORS)');
      _cachedConfig = _getFallbackConfig();
      return _cachedConfig!;
    }
  }

  /// Get specific token by key
  static Future<String> getToken(String tokenKey) async {
    try {
      final config = await getConfig();
      final tokens = config['tokens'] as Map<String, dynamic>?;

      if (tokens != null && tokens.containsKey(tokenKey)) {
        return tokens[tokenKey] as String;
      } else {
        throw Exception('Token $tokenKey not found in config');
      }
    } catch (e) {
      // Return fallback token if available
      final fallbackTokens =
          _getFallbackConfig()['tokens'] as Map<String, dynamic>;
      if (fallbackTokens.containsKey(tokenKey)) {
        return fallbackTokens[tokenKey] as String;
      }
      throw Exception('Token $tokenKey not available: $e');
    }
  }

  /// Get GitHub API configuration
  static Future<Map<String, String>> getGitHubConfig(String configKey) async {
    try {
      final config = await getConfig();
      final githubConfigs = config['github_configs'] as Map<String, dynamic>?;

      if (githubConfigs != null && githubConfigs.containsKey(configKey)) {
        final configData = githubConfigs[configKey] as Map<String, dynamic>;
        return {
          'token': configData['token'] as String,
          'owner': configData['owner'] as String,
          'repo': configData['repo'] as String,
        };
      } else {
        throw Exception('GitHub config $configKey not found');
      }
    } catch (e) {
      // Return fallback config if available
      final fallbackConfigs =
          _getFallbackConfig()['github_configs'] as Map<String, dynamic>;
      if (fallbackConfigs.containsKey(configKey)) {
        final configData = fallbackConfigs[configKey] as Map<String, dynamic>;
        return {
          'token': configData['token'] as String,
          'owner': configData['owner'] as String,
          'repo': configData['repo'] as String,
        };
      }
      throw Exception('GitHub config $configKey not available: $e');
    }
  }

  /// Clear cached config (useful for testing or forcing refresh)
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await prefs.remove(_cacheTimeKey);
    _cachedConfig = null;
  }

  /// Fallback configuration in case remote config is not available
  static Map<String, dynamic> _getFallbackConfig() {
    return {
      'tokens': {
        'users_token':
            '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',
        'app_upload_token':
            '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',
      },
      'github_configs': {
        'users': {
          'token':
              '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',
          'owner': 'mahmoud-gharib',
          'repo': 'app_upload',
        },
        'app_upload': {
          'token':
              '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',
          'owner': 'mahmoud-gharib',
          'repo': 'app_upload',
        },
        'chat': {
          'token':
              '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',
          'owner': 'mahmoud-gharib',
          'repo': 'app_upload',
        },
      },
    };
  }
}
