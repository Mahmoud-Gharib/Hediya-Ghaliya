import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationItem {
  final String id;
  final String type; // chat | gift | system
  final String title;
  final String body;
  final String createdAt; // ISO8601 UTC
  final String? route; // deep link route
  final Map<String, dynamic>? args; // deep link args

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.route,
    this.args,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'title': title,
        'body': body,
        'created_at': createdAt,
        if (route != null) 'route': route,
        if (args != null) 'args': args,
      };

  static NotificationItem fromJson(Map<String, dynamic> j) => NotificationItem(
        id: (j['id'] ?? '') as String,
        type: (j['type'] ?? 'system') as String,
        title: (j['title'] ?? '') as String,
        body: (j['body'] ?? '') as String,
        createdAt: (j['created_at'] ?? '') as String,
        route: j['route'] as String?,
        args: (j['args'] as Map?)?.cast<String, dynamic>(),
      );
}

class NotificationsData {
  final List<NotificationItem> items;
  final String? sha;
  final String? etag;
  final bool notModified;

  NotificationsData({required this.items, this.sha, this.etag, this.notModified = false});
}

class NotificationsApi {
  // Reuse same GitHub repo settings used in GitHubChatApi
  static const String token = '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';
  static const String owner = 'mahmoud-gharib';
  static const String repo = 'app_upload';

  static Uri _fileUrl(String phone) => Uri.parse(
      'https://api.github.com/repos/$owner/$repo/contents/Notifications/$phone.json');

  static Map<String, String> _headers({String? etag}) {
    final h = <String, String>{
      'Authorization': 'token $token',
      'Accept': 'application/vnd.github+json',
    };
    if (etag != null) h['If-None-Match'] = etag;
    return h;
  }

  static Future<NotificationsData> fetch(String phone, {String? etag}) async {
    final res = await http.get(_fileUrl(phone), headers: _headers(etag: etag));
    if (res.statusCode == 304) {
      return NotificationsData(items: const [], sha: null, etag: etag, notModified: true);
    }
    if (res.statusCode == 404) {
      return NotificationsData(items: const [], sha: null, etag: res.headers['etag']);
    }
    if (res.statusCode != 200) {
      throw Exception('فشل في جلب الإشعارات: ${res.statusCode}');
    }
    final data = json.decode(res.body) as Map<String, dynamic>;
    final String encoded = (data['content'] ?? '').toString().replaceAll('\n', '');
    final decoded = utf8.decode(base64.decode(encoded));
    final parsed = json.decode(decoded) as Map<String, dynamic>;
    final List arr = (parsed['items'] as List?) ?? [];
    final items = arr.whereType<Map<String, dynamic>>().map(NotificationItem.fromJson).toList();
    final sha = (data['sha'] ?? '') as String;
    final newEtag = res.headers['etag'];
    return NotificationsData(items: items, sha: sha, etag: newEtag);
  }

  static Future<String> save(String phone, List<NotificationItem> items, {required String? sha}) async {
    final content = json.encode({'items': items.map((e) => e.toJson()).toList()});
    final b64 = base64.encode(utf8.encode(content));
    final res = await http.put(
      _fileUrl(phone),
      headers: _headers(),
      body: json.encode({
        'message': 'Update notifications for $phone',
        'content': b64,
        if (sha != null) 'sha': sha,
      }),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('فشل حفظ الإشعارات: ${res.body}');
    }
    final body = json.decode(res.body) as Map<String, dynamic>;
    final contentObj = body['content'] as Map<String, dynamic>?;
    return (contentObj?['sha'] as String?) ?? sha ?? '';
  }
}
