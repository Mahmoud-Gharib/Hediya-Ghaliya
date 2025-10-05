enum GiftPackageType {
  free,
  bronze,
  silver,
  gold,
}

class GiftPackage {
  final GiftPackageType type;
  final String name;
  final String nameAr;
  final double price;
  final String currency;
  final List<String> features;
  final List<String> featuresAr;
  final int maxMediaFiles;
  final int maxTextLength;
  final bool hasCustomThemes;
  final bool hasAnimations;
  final bool hasMusic;
  final bool hasVoiceRecording;
  final bool hasVideoRecording;
  final bool hasScheduledDelivery;
  final bool hasReadReceipts;
  final int validityDays;
  final String color;
  final String icon;

  const GiftPackage({
    required this.type,
    required this.name,
    required this.nameAr,
    required this.price,
    required this.currency,
    required this.features,
    required this.featuresAr,
    required this.maxMediaFiles,
    required this.maxTextLength,
    required this.hasCustomThemes,
    required this.hasAnimations,
    required this.hasMusic,
    required this.hasVoiceRecording,
    required this.hasVideoRecording,
    required this.hasScheduledDelivery,
    required this.hasReadReceipts,
    required this.validityDays,
    required this.color,
    required this.icon,
  });

  static const List<GiftPackage> availablePackages = [
    // الباقة المجانية
    GiftPackage(
      type: GiftPackageType.free,
      name: 'Free Gift',
      nameAr: 'هدية مجانية',
      price: 0.0,
      currency: 'EGP',
      features: [
        'Basic text message',
        '1 image attachment',
        'Simple design',
        'Valid for 7 days',
      ],
      featuresAr: [
        'رسالة نصية بسيطة',
        'صورة واحدة فقط',
        'تصميم بسيط',
        'صالحة لمدة 7 أيام',
      ],
      maxMediaFiles: 1,
      maxTextLength: 200,
      hasCustomThemes: false,
      hasAnimations: false,
      hasMusic: false,
      hasVoiceRecording: false,
      hasVideoRecording: false,
      hasScheduledDelivery: false,
      hasReadReceipts: false,
      validityDays: 7,
      color: '0xFF9E9E9E',
      icon: '🎁',
    ),

    // الباقة البرونزية
    GiftPackage(
      type: GiftPackageType.bronze,
      name: 'Bronze Gift',
      nameAr: 'هدية برونزية',
      price: 25.0,
      currency: 'EGP',
      features: [
        'Rich text message',
        'Up to 3 media files',
        'Basic themes',
        'Voice recording',
        'Valid for 30 days',
      ],
      featuresAr: [
        'رسالة نصية غنية',
        'حتى 3 ملفات وسائط',
        'قوالب أساسية',
        'تسجيل صوتي',
        'صالحة لمدة 30 يوم',
      ],
      maxMediaFiles: 3,
      maxTextLength: 500,
      hasCustomThemes: true,
      hasAnimations: false,
      hasMusic: false,
      hasVoiceRecording: true,
      hasVideoRecording: false,
      hasScheduledDelivery: false,
      hasReadReceipts: false,
      validityDays: 30,
      color: '0xFFCD7F32',
      icon: '🥉',
    ),

    // الباقة الفضية
    GiftPackage(
      type: GiftPackageType.silver,
      name: 'Silver Gift',
      nameAr: 'هدية فضية',
      price: 50.0,
      currency: 'EGP',
      features: [
        'Rich multimedia message',
        'Up to 5 media files',
        'Premium themes',
        'Voice & video recording',
        'Background music',
        'Scheduled delivery',
        'Valid for 60 days',
      ],
      featuresAr: [
        'رسالة وسائط متعددة غنية',
        'حتى 5 ملفات وسائط',
        'قوالب مميزة',
        'تسجيل صوتي ومرئي',
        'موسيقى خلفية',
        'توقيت الإرسال',
        'صالحة لمدة 60 يوم',
      ],
      maxMediaFiles: 5,
      maxTextLength: 1000,
      hasCustomThemes: true,
      hasAnimations: true,
      hasMusic: true,
      hasVoiceRecording: true,
      hasVideoRecording: true,
      hasScheduledDelivery: true,
      hasReadReceipts: false,
      validityDays: 60,
      color: '0xFFC0C0C0',
      icon: '🥈',
    ),

    // الباقة الذهبية
    GiftPackage(
      type: GiftPackageType.gold,
      name: 'Gold Gift',
      nameAr: 'هدية ذهبية',
      price: 100.0,
      currency: 'EGP',
      features: [
        'Premium multimedia experience',
        'Unlimited media files',
        'Exclusive themes & animations',
        'Professional voice & video',
        'Custom background music',
        'Advanced scheduling',
        'Read receipts',
        'Valid for 365 days',
        'Priority support',
      ],
      featuresAr: [
        'تجربة وسائط متعددة مميزة',
        'ملفات وسائط غير محدودة',
        'قوالب وتأثيرات حصرية',
        'تسجيل صوتي ومرئي احترافي',
        'موسيقى خلفية مخصصة',
        'جدولة متقدمة',
        'إشعارات القراءة',
        'صالحة لمدة سنة كاملة',
        'دعم فني مميز',
      ],
      maxMediaFiles: -1, // unlimited
      maxTextLength: 5000,
      hasCustomThemes: true,
      hasAnimations: true,
      hasMusic: true,
      hasVoiceRecording: true,
      hasVideoRecording: true,
      hasScheduledDelivery: true,
      hasReadReceipts: true,
      validityDays: 365,
      color: '0xFFFFD700',
      icon: '🥇',
    ),
  ];

  static GiftPackage getPackage(GiftPackageType type) {
    return availablePackages.firstWhere((package) => package.type == type);
  }

  String get displayPrice {
    if (price == 0) return 'مجاناً';
    return '$price $currency';
  }

  String get validityText {
    if (validityDays == 365) return 'سنة كاملة';
    if (validityDays >= 30) return '${(validityDays / 30).round()} شهر';
    return '$validityDays يوم';
  }

  String get mediaFilesText {
    if (maxMediaFiles == -1) return 'غير محدود';
    if (maxMediaFiles == 1) return 'ملف واحد';
    return '$maxMediaFiles ملفات';
  }
}
