import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ConfigService {
  static const String _configUrl = 'https://raw.githubusercontent.com/mahmoud-gharib/app-config/main/config.json';
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
    
    // Use fallback config directly for Flutter Web to avoid CORS issues
    // TODO: Implement proper CORS handling or use a proxy for production
    print('🔧 استخدام الإعدادات المحلية (تجنب مشاكل CORS في Flutter Web)');
    _cachedConfig = _getFallbackConfig();
    return _cachedConfig!;
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
      final fallbackTokens = _getFallbackConfig()['tokens'] as Map<String, dynamic>;
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
      final fallbackConfigs = _getFallbackConfig()['github_configs'] as Map<String, dynamic>;
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
        'users_token': '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',
        'app_upload_token': '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',
      },
      'github_configs': {
        'users': {
          'token': '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',
          'owner': 'Gharib-Elshazly',
          'repo': 'Users'
        },
        'app_upload': {
          'token': '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',
          'owner': 'mahmoud-gharib',
          'repo': 'app_upload'
        },
        'chat': {
          'token': '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',
          'owner': 'mahmoud-gharib',
          'repo': 'app_upload'
        }
      }
    };
  }
}
