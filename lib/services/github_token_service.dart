import 'dart:convert';
import 'package:http/http.dart' as http;

/// خدمة لجلب الـ GitHub token من ملف .txt في repository
class GitHubTokenService {
  static String? _cachedToken;
  static DateTime? _lastFetch;
  static const Duration _cacheValidDuration = Duration(minutes: 30);

  // معلومات الـ repository العام الذي يحتوي على ملف الـ token
  static const String _tokenRepoOwner = 'mahmoud-gharib';
  static const String _tokenRepoName =
      'token-storage'; // يجب تغيير هذا لاسم الـ repo الصحيح
  static const String _tokenFilePath =
      'user_token.txt'; // يجب تغيير هذا لمسار الملف الصحيح

  /// جلب الـ token من GitHub repository
  static Future<String> getToken() async {
    // التحقق من وجود token محفوظ في الذاكرة المؤقتة
    if (_cachedToken != null &&
        _lastFetch != null &&
        DateTime.now().difference(_lastFetch!) < _cacheValidDuration) {
      return _cachedToken!;
    }

    try {
      final url = Uri.parse(
        'https://api.github.com/repos/$_tokenRepoOwner/$_tokenRepoName/contents/$_tokenFilePath',
      );

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/vnd.github+json',
          'User-Agent': 'Hediya-Ghaliya-App',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        final String encodedContent = jsonResponse['content'];

        // فك تشفير المحتوى من base64
        final decodedBytes = base64.decode(encodedContent.replaceAll('\n', ''));
        final rawToken = utf8.decode(decodedBytes).trim();
        
        // تنظيف الـ token من أي أرقام أو رموز غير مرغوب فيها في البداية
        final token = _cleanToken(rawToken);

        // حفظ في الذاكرة المؤقتة
        _cachedToken = token;
        _lastFetch = DateTime.now();

        return token;
      } else {
        throw Exception('فشل في جلب الـ token: ${response.statusCode}');
      }
    } catch (e) {
      // في حالة الفشل، استخدم الـ token الاحتياطي
      print('خطأ في جلب الـ token من GitHub: $e');
      return _getFallbackToken();
    }
  }

  /// تنظيف الـ token من أي أرقام أو رموز غير مرغوب فيها في البداية
  static String _cleanToken(String rawToken) {
    print('🧹 تنظيف الـ token الأصلي: ${rawToken.substring(0, rawToken.length > 20 ? 20 : rawToken.length)}...');
    
    // إزالة أي مسافات أو أسطر جديدة
    String cleanedToken = rawToken.trim();
    
    // إزالة أي أرقام من بداية الـ token
    // GitHub tokens تبدأ دائماً بـ "github_pat_" أو "ghp_"
    while (cleanedToken.isNotEmpty && RegExp(r'^\d').hasMatch(cleanedToken)) {
      print('🔢 إزالة رقم من البداية: ${cleanedToken[0]}');
      cleanedToken = cleanedToken.substring(1);
    }
    
    // إزالة أي رموز غير مرغوب فيها من البداية (ما عدا الأحرف والشرطة السفلية)
    final beforeClean = cleanedToken;
    cleanedToken = cleanedToken.replaceFirst(RegExp(r'^[^a-zA-Z_]+'), '');
    
    if (beforeClean != cleanedToken) {
      print('🧽 تم إزالة رموز إضافية من البداية');
    }
    
    final finalToken = cleanedToken.trim();
    print('✨ الـ token النظيف: ${finalToken.substring(0, finalToken.length > 20 ? 20 : finalToken.length)}...');
    
    return finalToken;
  }

  /// الحصول على token احتياطي في حالة فشل جلب الـ token من GitHub
  static String _getFallbackToken() {
    // يمكن هنا إضافة منطق للحصول على token احتياطي
    // مثل قراءة من ملف محلي أو إعدادات التطبيق
    return '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';
  }

  /// مسح الذاكرة المؤقتة لإجبار إعادة جلب الـ token
  static void clearCache() {
    _cachedToken = null;
    _lastFetch = null;
  }

  /// التحقق من صحة الـ token
  static Future<bool> validateToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.github.com/user'),
        headers: {
          'Authorization': 'token $token',
          'Accept': 'application/vnd.github+json',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// اختبار دالة تنظيف الـ token
  static void testTokenCleaning() {
    print('🧪 اختبار تنظيف الـ tokens...');
    
    // اختبار مع token فيه رقم في البداية
    final testToken1 = '1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';
    final cleaned1 = _cleanToken(testToken1);
    print('✅ اختبار 1 - النتيجة: ${cleaned1.substring(0, 20)}...');
    
    // اختبار مع token عادي
    final testToken2 = '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';
    final cleaned2 = _cleanToken(testToken2);
    print('✅ اختبار 2 - النتيجة: ${cleaned2.substring(0, 20)}...');
    
    // اختبار مع token فيه أرقام ورموز متعددة
    final testToken3 = '123!@#github_pat_11AO4EDBI0ggh0JSP8Ryil';
    final cleaned3 = _cleanToken(testToken3);
    print('✅ اختبار 3 - النتيجة: ${cleaned3.substring(0, 20)}...');
  }
}
