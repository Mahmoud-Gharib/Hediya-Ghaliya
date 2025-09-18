import 'dart:convert';

class Gift {
  String? id; // يمكن استخدامه لاحقاً للمسودات/المشاركة

  // الأطراف
  String? senderName;
  String? senderPhone;
  String? senderRelation; // أب، أم، ...

  String? recipientName;
  String? recipientPhone;
  String? recipientRelation; // ابن، زوجة، ...

  // المناسبة والتفاصيل
  String? occasion; // عيد ميلاد، تخرج، ...
  DateTime? deliveryAt; // اختياري

  String? title; // عنوان قصير
  String? message; // الرسالة

  // التنسيق
  String? themeId; // قالب
  int? accentColor; // لون رئيسي
  // تفاصيل ديناميكية بحسب المناسبة والأشخاص
  Map<String, dynamic>? details;

  Gift({
    this.id,
    this.senderName,
    this.senderPhone,
    this.senderRelation,
    this.recipientName,
    this.recipientPhone,
    this.recipientRelation,
    this.occasion,
    this.deliveryAt,
    this.title,
    this.message,
    this.themeId,
    this.accentColor,
    this.details,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'senderName': senderName,
        'senderPhone': senderPhone,
        'senderRelation': senderRelation,
        'recipientName': recipientName,
        'recipientPhone': recipientPhone,
        'recipientRelation': recipientRelation,
        'occasion': occasion,
        'deliveryAt': deliveryAt?.toIso8601String(),
        'title': title,
        'message': message,
        'themeId': themeId,
        'accentColor': accentColor,
        'details': details,
      };

  factory Gift.fromMap(Map<String, dynamic> map) => Gift(
        id: map['id'] as String?,
        senderName: map['senderName'] as String?,
        senderPhone: map['senderPhone'] as String?,
        senderRelation: map['senderRelation'] as String?,
        recipientName: map['recipientName'] as String?,
        recipientPhone: map['recipientPhone'] as String?,
        recipientRelation: map['recipientRelation'] as String?,
        occasion: map['occasion'] as String?,
        deliveryAt: map['deliveryAt'] != null ? DateTime.tryParse(map['deliveryAt'] as String) : null,
        title: map['title'] as String?,
        message: map['message'] as String?,
        themeId: map['themeId'] as String?,
        accentColor: map['accentColor'] as int?,
        details: (map['details'] as Map?)?.cast<String, dynamic>(),
      );

  String toJson() => json.encode(toMap());
  factory Gift.fromJson(String s) => Gift.fromMap(json.decode(s) as Map<String, dynamic>);
}
