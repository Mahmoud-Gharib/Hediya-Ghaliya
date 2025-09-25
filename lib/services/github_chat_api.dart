import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hediya_ghaliya/Services/GithubToken.dart';

enum MessageType {
  text,
  image,
  video,
  file,
  voice,
}

class MessageAttachment {
  final String fileName;
  final String fileUrl;
  final String? mimeType;
  final int? fileSize;
  final String? thumbnailUrl;
  final int? duration; // for voice messages in seconds

  MessageAttachment({
    required this.fileName,
    required this.fileUrl,
    this.mimeType,
    this.fileSize,
    this.thumbnailUrl,
    this.duration,
  });

  Map<String, dynamic> toJson() => {
        'file_name': fileName,
        'file_url': fileUrl,
        if (mimeType != null) 'mime_type': mimeType,
        if (fileSize != null) 'file_size': fileSize,
        if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
        if (duration != null) 'duration': duration,
      };

  static MessageAttachment fromJson(Map<String, dynamic> j) {
    print('🔄 تحويل مرفق من JSON: ${j.toString()}');
    final fileName = (j['file_name'] ?? j['fileName'] ?? '') as String;
    final fileUrl = (j['file_url'] ?? j['fileUrl'] ?? '') as String;
    final mimeType = (j['mime_type'] ?? j['mimeType']) as String?;
    final fileSize = (j['file_size'] ?? j['fileSize']) as int?;
    final thumbnailUrl = (j['thumbnail_url'] ?? j['thumbnailUrl']) as String?;
    final duration = (j['duration']) as int?;
    final attachment = MessageAttachment(
      fileName: fileName,
      fileUrl: fileUrl,
      mimeType: mimeType,
      fileSize: fileSize,
      thumbnailUrl: thumbnailUrl,
      duration: duration,
    );
    print('✅ مرفق محول: ${attachment.fileName} - ${attachment.fileUrl}');
    return attachment;
  }
}

class Message {
  final String id;
  final String senderName;
  final String senderPhone;
  final String text;
  final String timestamp; // ISO8601 UTC
  final MessageType type;
  final MessageAttachment? attachment;

  Message({
    required this.id,
    required this.senderName,
    required this.senderPhone,
    required this.text,
    required this.timestamp,
    this.type = MessageType.text,
    this.attachment,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'sender_name': senderName,
        'sender_phone': senderPhone,
        'text': text,
        'timestamp': timestamp,
        'type': type.name,
        if (attachment != null) 'attachment': attachment!.toJson(),
      };

  static Message fromJson(Map<String, dynamic> j) {
    MessageType type = MessageType.text;
    try {
      final typeStr = j['type'] as String?;
      print('🔄 تحويل رسالة من JSON - النوع: $typeStr');
      if (typeStr != null) {
        type = MessageType.values.firstWhere(
          (e) => e.name == typeStr,
          orElse: () => MessageType.text,
        );
      }
    } catch (e) {
      print('❌ خطأ في تحديد نوع الرسالة: $e');
    }

    MessageAttachment? attachment;
    if (j['attachment'] != null) {
      try {
        attachment = MessageAttachment.fromJson(j['attachment'] as Map<String, dynamic>);
        print('📎 تم تحميل مرفق: ${attachment.fileName}');
      } catch (e) {
        print('❌ خطأ في تحميل المرفق: $e');
      }
    }

    final message = Message(
      id: (j['id'] ?? '') as String,
      senderName: (j['sender_name'] ?? '') as String,
      senderPhone: (j['sender_phone'] ?? '') as String,
      text: (j['text'] ?? '') as String,
      timestamp: (j['timestamp'] ?? '') as String,
      type: type,
      attachment: attachment,
    );
    
    print('✅ رسالة محولة: ${message.type.name} - "${message.text}" - مرفق: ${message.attachment?.fileName}');
    return message;
  }
}

class ChatData {
  final List<Message> messages;
  final String? sha; // null if file not found yet
  final String? etag; // for caching
  final bool notModified; // true if 304

  ChatData({
    required this.messages,
    required this.sha,
    required this.etag,
    this.notModified = false,
  });
}

class UserRef {
  final String name;
  final String phone;
  UserRef(this.name, this.phone);
}

class GitHubChatApi {
  static const String owner = 'mahmoud-gharib';
  static const String repo = 'app_upload';

  static Uri _fileUrl(String phone) => Uri.parse(
      'https://api.github.com/repos/$owner/$repo/contents/Users/$phone/$phone.json');

  static Uri _usersUrl() => Uri.parse(
      'https://api.github.com/repos/$owner/$repo/contents/users.json');

  static Future<Map<String, String>> _headers({String? etag}) async {
    final token = await GitHubTokenService.getUserToken();
    final h = <String, String>{
      'Authorization': 'token $token',
      'Accept': 'application/vnd.github+json',
      'Content-Type': 'application/json',
      'User-Agent': 'hediya-ghaliya-app',
    };
    if (etag != null) h['If-None-Match'] = etag;
    return h;
  }

  static Future<ChatData> fetchChat(String phone, {String? etag}) async {
    print('📥 جلب المحادثة للرقم: $phone');
    final res = await http.get(_fileUrl(phone), headers: await _headers(etag: etag));
    
    if (res.statusCode == 304) {
      print('📄 لا توجد تحديثات جديدة (304)');
      return ChatData(messages: const [], sha: null, etag: etag, notModified: true);
    }
    if (res.statusCode == 404) {
      print('📄 ملف المحادثة غير موجود (404)');
      return ChatData(messages: const [], sha: null, etag: res.headers['etag']);
    }
    if (res.statusCode != 200) {
      print('❌ خطأ في جلب المحادثة: ${res.statusCode}');
      throw Exception('فشل في جلب المحادثة: ${res.statusCode}');
    }
    
    final data = json.decode(res.body) as Map<String, dynamic>;
    final String encoded = (data['content'] ?? '').toString().replaceAll('\n', '');
    print('📄 محتوى مشفر بطول: ${encoded.length}');
    
    final decoded = utf8.decode(base64.decode(encoded));
    print('📄 محتوى مفكوك: ${decoded.substring(0, decoded.length > 200 ? 200 : decoded.length)}...');
    
    final parsed = json.decode(decoded) as Map<String, dynamic>;
    final List msgs = (parsed['messages'] as List?) ?? [];
    print('📨 عدد الرسائل الخام: ${msgs.length}');
    
    final messages = msgs
        .whereType<Map<String, dynamic>>()
        .map(Message.fromJson)
        .toList();
    
    print('📨 عدد الرسائل المحولة: ${messages.length}');
    for (var msg in messages) {
      print('📨 رسالة: ${msg.type.name} - "${msg.text}" - مرفق: ${msg.attachment?.fileName}');
    }
    
    final sha = (data['sha'] ?? '') as String;
    final newEtag = res.headers['etag'];
    return ChatData(messages: messages, sha: sha, etag: newEtag);
  }

  static Future<String> saveChat(String phone, List<Message> messages, {required String? sha}) async {
    final content = json.encode({
      'messages': messages.map((e) => e.toJson()).toList(),
    });
    final b64 = base64.encode(utf8.encode(content));
    final res = await http.put(
      _fileUrl(phone),
      headers: await _headers(),
      body: json.encode({
        'message': 'Update chat for $phone',
        'content': b64,
        if (sha != null) 'sha': sha,
      }),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('فشل حفظ المحادثة: ${res.body}');
    }
    final body = json.decode(res.body) as Map<String, dynamic>;
    final contentObj = body['content'] as Map<String, dynamic>?;
    return (contentObj?['sha'] as String?) ?? sha ?? '';
  }

  static Future<List<UserRef>> listUsers() async {
    final res = await http.get(_usersUrl(), headers: await _headers());
    if (res.statusCode != 200) return [];
    final data = json.decode(res.body) as Map<String, dynamic>;
    final String encoded = (data['content'] ?? '').toString().replaceAll('\n', '');
    final decoded = utf8.decode(base64.decode(encoded));
    final parsed = json.decode(decoded) as Map<String, dynamic>;
    final List users = (parsed['users'] as List?) ?? [];
    return users
        .whereType<Map<String, dynamic>>()
        .map((u) => UserRef((u['name'] ?? '').toString(), (u['phone'] ?? '').toString()))
        .toList();
  }

  // Upload file to GitHub and return the download URL
  static Future<String> uploadFile(String phone, String fileName, List<int> fileBytes) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileExtension = fileName.split('.').last;
      final uniqueFileName = '${timestamp}_$fileName';
      final filePath = 'Users/$phone/files/$uniqueFileName';
      
      final url = Uri.parse('https://api.github.com/repos/$owner/$repo/contents/$filePath');
      final b64Content = base64.encode(fileBytes);
      
      print('🔄 رفع ملف إلى GitHub: $filePath');
      
      final res = await http.put(
        url,
        headers: await _headers(),
        body: json.encode({
          'message': 'Upload file: $fileName',
          'content': b64Content,
        }),
      );
      
      print('📡 GitHub Response: ${res.statusCode}');
      
      if (res.statusCode != 201) {
        print('❌ GitHub Error: ${res.body}');
        throw Exception('فشل رفع الملف: ${res.statusCode} - ${res.body}');
      }
      
      final body = json.decode(res.body) as Map<String, dynamic>;
      final content = body['content'] as Map<String, dynamic>;
      final downloadUrl = content['download_url'] as String;
      
      print('✅ تم رفع الملف بنجاح: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('💥 خطأ في رفع الملف: $e');
      rethrow;
    }
  }

  // Upload image with thumbnail generation
  static Future<Map<String, String>> uploadImage(String phone, String fileName, List<int> imageBytes) async {
    final fileUrl = await uploadFile(phone, fileName, imageBytes);
    
    // For now, we'll use the same URL for thumbnail
    // In a real implementation, you might want to generate a smaller thumbnail
    return {
      'fileUrl': fileUrl,
      'thumbnailUrl': fileUrl,
    };
  }
}
