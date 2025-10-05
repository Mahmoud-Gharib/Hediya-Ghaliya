import 'dart:convert';
import 'package:http/http.dart' as http;

class GitHubTokenService 
{
  static String? _cachedToken;
  static DateTime? _lastFetch;
  static const Duration _cacheValidDuration = Duration(minutes: 30);

  static const String _tokenRepoOwner = 'Hed-Mahmoud-iya-Gha-Gharib-liya';
  static const String _tokenRepoName  = 'token-storage'; 

  static const Map<String, String> _tokenFiles = 
  {
    'Users'         : 'user_token.txt', 
    'app_upload'    : 'app_upload_token.txt', 
    'Hediya-Ghaliya': 'hediya_ghaliya_token.txt',
  };

  static Future<String> getUserToken() async 
  {
    return getTokenForRepository('Users');
  }

  static Future<String> getTokenForRepository(String repositoryName) async 
  {
    if (_cachedToken != null && _lastFetch != null && DateTime.now().difference(_lastFetch!) < _cacheValidDuration) 
	{
      return _cachedToken!;
    }

    final tokenFilePath = _tokenFiles[repositoryName];
    if (tokenFilePath == null) 
    {
      throw Exception('لا يوجد token محدد للـ repository: $repositoryName');
    }

    final url = Uri.parse
	(
      'https://api.github.com/repos/$_tokenRepoOwner/$_tokenRepoName/contents/$tokenFilePath',
    );

    final response = await http.get
	(
      url,
      headers: 
      {
        'Accept': 'application/vnd.github+json',
        'User-Agent': 'Hediya-Ghaliya-App',
      },
    );

    if (response.statusCode == 200) 
    {
      final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
      final String encodedContent = jsonResponse['content'];

      final decodedBytes = base64.decode(encodedContent.replaceAll('\n', ''));
      final rawToken = utf8.decode(decodedBytes).trim();

      final token = _cleanToken(rawToken);

      _cachedToken = token;
      _lastFetch = DateTime.now();

      return token;
    } 
    else 
    {
      if (response.statusCode == 404) 
      {
        throw Exception('ملف الـ token غير موجود: $tokenFilePath');
      }
      throw Exception('فشل في جلب الـ token لـ $repositoryName: ${response.statusCode}');
    }
  }

  static String _cleanToken(String rawToken) 
  {
    String cleanedToken = rawToken.trim();
    while (cleanedToken.isNotEmpty && RegExp(r'^\d').hasMatch(cleanedToken)) 
	{
      cleanedToken = cleanedToken.substring(1);
    }
    cleanedToken = cleanedToken.replaceFirst(RegExp(r'^[^a-zA-Z_]+'), '');
    return cleanedToken.trim();
  }
  
  static void clearCache() 
  {
    _cachedToken = null;
    _lastFetch = null;
  }
}
