import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hediya_ghaliya/Services/GithubToken.dart';
import 'package:hediya_ghaliya/Models/GiftPackage.dart';

class Gift {
  final String id;
  final String creatorPhone;
  final String creatorName;
  final String recipientPhone;
  final String recipientName;
  final GiftPackageType packageType;
  final String title;
  final String message;
  final List<String> mediaUrls;
  final String? scheduledDelivery;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isDelivered;
  final bool isOpened;
  final DateTime? openedAt;
  final Map<String, dynamic> customization;

  Gift({
    required this.id,
    required this.creatorPhone,
    required this.creatorName,
    required this.recipientPhone,
    required this.recipientName,
    required this.packageType,
    required this.title,
    required this.message,
    required this.mediaUrls,
    this.scheduledDelivery,
    required this.createdAt,
    required this.expiresAt,
    this.isDelivered = false,
    this.isOpened = false,
    this.openedAt,
    required this.customization,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'creator_phone': creatorPhone,
        'creator_name': creatorName,
        'recipient_phone': recipientPhone,
        'recipient_name': recipientName,
        'package_type': packageType.name,
        'title': title,
        'message': message,
        'media_urls': mediaUrls,
        'scheduled_delivery': scheduledDelivery,
        'created_at': createdAt.toIso8601String(),
        'expires_at': expiresAt.toIso8601String(),
        'is_delivered': isDelivered,
        'is_opened': isOpened,
        'opened_at': openedAt?.toIso8601String(),
        'customization': customization,
      };

  static Gift fromJson(Map<String, dynamic> json) {
    return Gift(
      id: json['id'],
      creatorPhone: json['creator_phone'],
      creatorName: json['creator_name'],
      recipientPhone: json['recipient_phone'],
      recipientName: json['recipient_name'],
      packageType: GiftPackageType.values.firstWhere(
        (e) => e.name == json['package_type'],
        orElse: () => GiftPackageType.free,
      ),
      title: json['title'],
      message: json['message'],
      mediaUrls: List<String>.from(json['media_urls'] ?? []),
      scheduledDelivery: json['scheduled_delivery'],
      createdAt: DateTime.parse(json['created_at']),
      expiresAt: DateTime.parse(json['expires_at']),
      isDelivered: json['is_delivered'] ?? false,
      isOpened: json['is_opened'] ?? false,
      openedAt: json['opened_at'] != null ? DateTime.parse(json['opened_at']) : null,
      customization: Map<String, dynamic>.from(json['customization'] ?? {}),
    );
  }
}

class GiftService {
  static const String _owner = 'mahmoud-gharib';
  static const String _repo = 'Hediya-Ghaliya';
  static const String _giftsPath = 'gifts.json';

  /// إنشاء هدية جديدة
  static Future<String> createGift({
    required String creatorPhone,
    required String creatorName,
    required String recipientPhone,
    required String recipientName,
    required GiftPackageType packageType,
    required String title,
    required String message,
    List<String> mediaUrls = const [],
    String? scheduledDelivery,
    Map<String, dynamic> customization = const {},
  }) async {
    try {
      final token = await GitHubTokenService.getTokenForRepository('Hediya-Ghaliya');
      final giftId = _generateGiftId();
      final package = GiftPackage.getPackage(packageType);
      
      final gift = Gift(
        id: giftId,
        creatorPhone: creatorPhone,
        creatorName: creatorName,
        recipientPhone: recipientPhone,
        recipientName: recipientName,
        packageType: packageType,
        title: title,
        message: message,
        mediaUrls: mediaUrls,
        scheduledDelivery: scheduledDelivery,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(Duration(days: package.validityDays)),
        customization: customization,
      );

      await _saveGiftToGitHub(gift, token);
      return giftId;
    } catch (e) {
      throw Exception('فشل في إنشاء الهدية: $e');
    }
  }

  /// جلب جميع الهدايا
  static Future<List<Gift>> getAllGifts() async {
    try {
      final token = await GitHubTokenService.getTokenForRepository('Hediya-Ghaliya');
      final url = Uri.parse('https://api.github.com/repos/$_owner/$_repo/contents/$_giftsPath');
      
      final response = await http.get(url, headers: {
        'Authorization': 'token $token',
        'Accept': 'application/vnd.github+json',
      });

      if (response.statusCode == 404) {
        // الملف غير موجود، إنشاء ملف جديد
        await _createEmptyGiftsFile(token);
        return [];
      }

      if (response.statusCode != 200) {
        throw Exception('فشل في جلب الهدايا: ${response.statusCode}');
      }

      final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
      final encodedContent = jsonResponse['content'] as String;
      final decodedContent = utf8.decode(base64.decode(encodedContent.replaceAll('\n', '')));
      final data = json.decode(decodedContent) as Map<String, dynamic>;
      
      final giftsList = data['gifts'] as List? ?? [];
      return giftsList.map((giftJson) => Gift.fromJson(giftJson)).toList();
    } catch (e) {
      throw Exception('فشل في جلب الهدايا: $e');
    }
  }

  /// جلب الهدايا الخاصة بمستخدم معين
  static Future<List<Gift>> getUserGifts(String phone, {bool asCreator = true}) async {
    final allGifts = await getAllGifts();
    return allGifts.where((gift) {
      return asCreator ? gift.creatorPhone == phone : gift.recipientPhone == phone;
    }).toList();
  }

  /// جلب هدية بواسطة ID
  static Future<Gift?> getGiftById(String giftId) async {
    final allGifts = await getAllGifts();
    try {
      return allGifts.firstWhere((gift) => gift.id == giftId);
    } catch (e) {
      return null;
    }
  }

  /// تحديث حالة الهدية (تم التسليم، تم الفتح)
  static Future<void> updateGiftStatus(String giftId, {bool? isDelivered, bool? isOpened}) async {
    try {
      final token = await GitHubTokenService.getTokenForRepository('Hediya-Ghaliya');
      final allGifts = await getAllGifts();
      
      final giftIndex = allGifts.indexWhere((gift) => gift.id == giftId);
      if (giftIndex == -1) {
        throw Exception('الهدية غير موجودة');
      }

      final gift = allGifts[giftIndex];
      final updatedGift = Gift(
        id: gift.id,
        creatorPhone: gift.creatorPhone,
        creatorName: gift.creatorName,
        recipientPhone: gift.recipientPhone,
        recipientName: gift.recipientName,
        packageType: gift.packageType,
        title: gift.title,
        message: gift.message,
        mediaUrls: gift.mediaUrls,
        scheduledDelivery: gift.scheduledDelivery,
        createdAt: gift.createdAt,
        expiresAt: gift.expiresAt,
        isDelivered: isDelivered ?? gift.isDelivered,
        isOpened: isOpened ?? gift.isOpened,
        openedAt: isOpened == true ? DateTime.now() : gift.openedAt,
        customization: gift.customization,
      );

      allGifts[giftIndex] = updatedGift;
      await _saveAllGiftsToGitHub(allGifts, token);
    } catch (e) {
      throw Exception('فشل في تحديث حالة الهدية: $e');
    }
  }

  /// حذف هدية
  static Future<void> deleteGift(String giftId) async {
    try {
      final token = await GitHubTokenService.getTokenForRepository('Hediya-Ghaliya');
      final allGifts = await getAllGifts();
      
      allGifts.removeWhere((gift) => gift.id == giftId);
      await _saveAllGiftsToGitHub(allGifts, token);
    } catch (e) {
      throw Exception('فشل في حذف الهدية: $e');
    }
  }

  /// إحصائيات الهدايا
  static Future<Map<String, int>> getGiftStatistics() async {
    try {
      final allGifts = await getAllGifts();
      final now = DateTime.now();
      
      return {
        'total': allGifts.length,
        'delivered': allGifts.where((g) => g.isDelivered).length,
        'opened': allGifts.where((g) => g.isOpened).length,
        'expired': allGifts.where((g) => g.expiresAt.isBefore(now)).length,
        'active': allGifts.where((g) => g.expiresAt.isAfter(now) && !g.isOpened).length,
      };
    } catch (e) {
      return {
        'total': 0,
        'delivered': 0,
        'opened': 0,
        'expired': 0,
        'active': 0,
      };
    }
  }

  // Helper methods
  static String _generateGiftId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'gift_${timestamp}_$random';
  }

  static Future<void> _saveGiftToGitHub(Gift gift, String token) async {
    final allGifts = await getAllGifts();
    allGifts.add(gift);
    await _saveAllGiftsToGitHub(allGifts, token);
  }

  static Future<void> _saveAllGiftsToGitHub(List<Gift> gifts, String token) async {
    final url = Uri.parse('https://api.github.com/repos/$_owner/$_repo/contents/$_giftsPath');
    
    // جلب SHA الحالي للملف
    String? sha;
    try {
      final getResponse = await http.get(url, headers: {
        'Authorization': 'token $token',
        'Accept': 'application/vnd.github+json',
      });
      if (getResponse.statusCode == 200) {
        final getJson = json.decode(getResponse.body) as Map<String, dynamic>;
        sha = getJson['sha'];
      }
    } catch (e) {
      // الملف غير موجود، سيتم إنشاؤه
    }

    final giftsData = {
      'gifts': gifts.map((gift) => gift.toJson()).toList(),
      'last_updated': DateTime.now().toIso8601String(),
    };

    final content = json.encode(giftsData);
    final base64Content = base64.encode(utf8.encode(content));

    final body = {
      'message': 'Update gifts data',
      'content': base64Content,
      if (sha != null) 'sha': sha,
    };

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'token $token',
        'Accept': 'application/vnd.github+json',
      },
      body: json.encode(body),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('فشل في حفظ الهدايا: ${response.statusCode}');
    }
  }

  static Future<void> _createEmptyGiftsFile(String token) async {
    final url = Uri.parse('https://api.github.com/repos/$_owner/$_repo/contents/$_giftsPath');
    
    final emptyData = {
      'gifts': [],
      'created_at': DateTime.now().toIso8601String(),
    };

    final content = json.encode(emptyData);
    final base64Content = base64.encode(utf8.encode(content));

    final body = {
      'message': 'Create gifts file',
      'content': base64Content,
    };

    await http.put(
      url,
      headers: {
        'Authorization': 'token $token',
        'Accept': 'application/vnd.github+json',
      },
      body: json.encode(body),
    );
  }
}
