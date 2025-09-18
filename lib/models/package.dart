/// نموذج شامل لباقات "هدية غالية" 📦
class GiftPackage {
  final String id;
  final String name;
  final String emoji;
  final double price;
  final String description;
  final String goal;
  final List<String> features;
  final List<String> limitations;
  final String optimalUse;
  final PackageType type;

  const GiftPackage({
    required this.id,
    required this.name,
    required this.emoji,
    required this.price,
    required this.description,
    required this.goal,
    required this.features,
    required this.limitations,
    required this.optimalUse,
    required this.type,
  });

  static const List<GiftPackage> packages = [
    // 🆓 الباقة المجانية (Free Plan)
    GiftPackage(
      id: 'free',
      name: 'الباقة المجانية',
      emoji: '🆓',
      price: 0,
      description: 'Free Plan',
      goal: 'تجربة التطبيق بشكل مبسط جدًا من غير أي تكاليف',
      type: PackageType.free,
      features: [
        '✨ النصوص:',
        '• كتابة رسالة واحدة (حد أقصى 200 كلمة)',
        '• خط افتراضي فقط',
        '• لون واحد للنص (أسود)',
        '',
        '✨ الخلفية:',
        '• خلفية ثابتة (صورة واحدة افتراضية جاهزة)',
        '• لا يمكن تغيير الخلفية أو رفع صورة',
        '',
        '✨ المعاينة:',
        '• معاينة مباشرة داخل التطبيق',
        '• لا يوجد توليد APK',
      ],
      limitations: [
        '❌ لا صور',
        '❌ لا موسيقى',
        '❌ لا فيديو',
        '❌ لا أنيميشن',
        '❌ لا تخصيص',
      ],
      optimalUse: 'إهداء رسالة قصيرة / تجربة قبل الترقية',
    ),

    // 🥈 الباقة الفضية (Silver Plan)
    GiftPackage(
      id: 'silver',
      name: 'الباقة الفضية',
      emoji: '🥈',
      price: 25,
      description: 'Silver Plan',
      goal: 'هدية بسيطة برسالة وصورة وخلفية مخصصة',
      type: PackageType.silver,
      features: [
        '✨ النصوص:',
        '• رسائل متعددة (حد أقصى 3 رسائل × 200 كلمة لكل رسالة)',
        '• خط إضافي (اختيار بين خطين)',
        '• إمكانية تغيير ألوان النص (3 ألوان أساسية)',
        '',
        '✨ الخلفية:',
        '• إمكانية تغيير لون الخلفية (3 خيارات: أزرق، وردي، بنفسجي)',
        '• رفع صورة واحدة فقط كخلفية',
        '',
        '✨ الصور:',
        '• صورة واحدة إضافية غير الخلفية (يتم عرضها في الصفحة الثانية)',
        '',
        '✨ المعاينة والبناء:',
        '• معاينة المحتوى داخل التطبيق',
        '• توليد APK مع علامة مائية (Watermark) "هدية غالية"',
      ],
      limitations: [
        '❌ لا موسيقى',
        '❌ لا فيديو',
        '❌ لا أنيميشن',
        '❌ لا تخصيص للأيقونة أو اسم التطبيق',
      ],
      optimalUse: 'هدية فيها رسالة + صورة رمزية بسيطة',
    ),

    // 🥉 الباقة البرونزية (Bronze Plan)
    GiftPackage(
      id: 'bronze',
      name: 'الباقة البرونزية',
      emoji: '🥉',
      price: 45,
      description: 'Bronze Plan',
      goal: 'هدية مؤثرة مع صور وموسيقى وأنيميشن بسيط',
      type: PackageType.bronze,
      features: [
        '✨ النصوص:',
        '• حتى 5 رسائل × 500 كلمة لكل رسالة',
        '• اختيار من 5 خطوط مختلفة',
        '• ألوان غير محدودة للنصوص (Color Picker)',
        '',
        '✨ الخلفية:',
        '• 10 ألوان + خلفيات جاهزة متنوعة',
        '• رفع حتى 2 خلفية مخصصة',
        '',
        '✨ الصور:',
        '• إضافة حتى 3 صور شخصية (يتم عرضها في Carousel أو Gallery)',
        '',
        '✨ الموسيقى:',
        '• إضافة ملف موسيقى MP3 واحد (حتى 3 دقائق)',
        '• الموسيقى تعمل أوتوماتيكياً عند فتح الهدية',
        '',
        '✨ الأنيميشن:',
        '• نصوص متحركة (Fade In, Slide, Zoom)',
        '• صور تدخل بحركة بسيطة',
        '',
        '✨ المعاينة والبناء:',
        '• توليد APK كامل بدون Watermark',
        '• إرسال رابط التحميل عبر البريد أو نسخ الرابط',
        '',
        '✨ الإضافات:',
        '• ملصقات Stickers بسيطة (قلوب، ورود)',
        '• مشاركة عبر WhatsApp مباشرة',
      ],
      limitations: [
        '❌ لا فيديو',
        '❌ لا تخصيص الأيقونة أو اسم التطبيق',
        '❌ لا جدولة زمنية',
      ],
      optimalUse: 'هدية شخصية غنية فيها صور + رسالة + موسيقى تعبيرية',
    ),

    // 🥇 الباقة الذهبية (Gold Plan)
    GiftPackage(
      id: 'gold',
      name: 'الباقة الذهبية',
      emoji: '🥇',
      price: 75,
      description: 'Gold Plan',
      goal: 'هدية احترافية وكاملة بكل المميزات بدون قيود',
      type: PackageType.gold,
      features: [
        '✨ النصوص:',
        '• عدد غير محدود من الرسائل (كل رسالة حتى 1000 كلمة)',
        '• مكتبة خطوط كاملة (20+ خط)',
        '• ألوان حرة + Gradient + تأثيرات على النص',
        '',
        '✨ الخلفية:',
        '• مكتبة خلفيات جاهزة (50+)',
        '• رفع عدد غير محدود من الخلفيات',
        '• إمكانية عمل خلفية متحركة (GIF / فيديو قصير)',
        '',
        '✨ الصور:',
        '• عدد غير محدود من الصور',
        '• دعم إنشاء معرض صور (Gallery) + عرض شرائح (Slideshow)',
        '',
        '✨ الموسيقى والصوت:',
        '• عدد غير محدود من ملفات الموسيقى',
        '• مؤثرات صوتية إضافية (تصفيق، ألعاب نارية، جرس)',
        '• تسجيل صوتي شخصي (Voice Note) مدمج',
        '',
        '✨ الفيديو:',
        '• إضافة فيديو واحد على الأقل (حتى 30 ثانية)',
        '• دعم رفع فيديو من رابط YouTube / Vimeo',
        '',
        '✨ الأنيميشن:',
        '• أنيميشن احترافي (Gift Box Animation, Balloons, Fireworks)',
        '• انتقالات صفحات متقدمة (Flip, Cube, Flow)',
        '',
        '✨ الأمان والخصوصية:',
        '• قفل الهدية بكلمة سر أو PIN',
        '• ميزة الهدية السرية (تفتح بكود خاص)',
        '',
        '✨ الوقت:',
        '• جدولة فتح الهدية في يوم/ساعة محددة',
        '• مؤقت عد تنازلي داخل الهدية',
        '',
        '✨ المعاينة والبناء:',
        '• توليد APK + AAB (Android)',
        '• خيار بناء iOS (IPA)',
        '• إشعارات مباشرة عند اكتمال الرفع والبناء',
        '• تخصيص اسم التطبيق + أيقونة التطبيق',
        '',
        '✨ الإضافات المميزة:',
        '• مكتبة إهداءات جاهزة (Templates) حسب المناسبة',
        '• QR Code لمشاركة الهدية',
        '• حفظ الهدايا في الحساب الشخصي وإعادة تنزيلها',
      ],
      limitations: [],
      optimalUse: 'هدايا احترافية كاملة لجميع المناسبات الخاصة',
    ),
  ];

  // الحصول على الباقة حسب النوع
  static GiftPackage getPackage(PackageType type) {
    return packages.firstWhere((p) => p.type == type);
  }

  // التحقق من توفر ميزة معينة في الباقة
  bool hasFeature(PackageFeature feature) {
    switch (type) {
      case PackageType.free:
        return _freeFeatures.contains(feature);
      case PackageType.bronze:
        return _freeFeatures.contains(feature) || _bronzeFeatures.contains(feature);
      case PackageType.silver:
        return _freeFeatures.contains(feature) || 
               _bronzeFeatures.contains(feature) || 
               _silverFeatures.contains(feature);
      case PackageType.gold:
        return true; // الباقة الذهبية تشمل كل الميزات
    }
  }

  // الحصول على القيود التفصيلية لكل باقة
  PackageLimits get limits {
    switch (type) {
      case PackageType.free:
        return PackageLimits.free();
      case PackageType.bronze:
        return PackageLimits.bronze();
      case PackageType.silver:
        return PackageLimits.silver();
      case PackageType.gold:
        return PackageLimits.gold();
    }
  }

  // ميزات كل باقة
  static const Set<PackageFeature> _freeFeatures = {
    PackageFeature.basicOccasions,
    PackageFeature.basicPersonInfo,
    PackageFeature.fixedColor,
    PackageFeature.singleTextPage,
    PackageFeature.defaultIcon,
    PackageFeature.inAppLink,
  };

  static const Set<PackageFeature> _bronzeFeatures = {
    PackageFeature.allOccasions,
    PackageFeature.fullPersonInfo,
    PackageFeature.colorSelection,
    PackageFeature.basicPages,
    PackageFeature.shareableLink,
  };

  static const Set<PackageFeature> _silverFeatures = {
    PackageFeature.extraPages,
    PackageFeature.photoAlbum,
    PackageFeature.backgroundMusic,
    PackageFeature.basicAnimations,
    PackageFeature.fontCustomization,
    PackageFeature.apkDownload,
  };

}

enum PackageType {
  free,
  bronze,
  silver,
  gold,
}

enum PackageFeature {
  // الباقة المجانية
  basicOccasions,
  basicPersonInfo,
  fixedColor,
  singleTextPage,
  defaultIcon,
  inAppLink,
  
  // الباقة البرونزية
  allOccasions,
  fullPersonInfo,
  colorSelection,
  basicPages,
  shareableLink,
  
  // الباقة الفضية
  extraPages,
  photoAlbum,
  backgroundMusic,
  basicAnimations,
  fontCustomization,
  apkDownload,
  
  // الباقة الذهبية
  personalVideo,
  voiceMessage,
  specialEffects,
  memoriesPages,
  customThemes,
  crossPlatform,
  prioritySupport,
}

class PackageLimits {
  final int maxTextLength;
  final int maxSpecialTextLength;
  final int maxPages;
  final int maxImages;
  final int maxImageSizeMB;
  final int maxVideos;
  final int maxVideoLengthSeconds;
  final int maxVideoSizeMB;
  final int maxAudioLengthSeconds;
  final int maxAudioSizeMB;
  final int colorOptions;
  final int musicOptions;
  final int animationTypes;
  final int fontOptions;
  final int themeOptions;
  final int expiryDays;
  final bool allowPhoneNumbers;
  final bool allowColorSelection;
  final bool allowImageUpload;
  final bool allowVideoUpload;
  final bool allowAudioUpload;
  final bool allowBackgroundMusic;
  final bool allowBasicAnimations;
  final bool allowAllEffects;
  final bool allowAPKDownload;
  final bool allowCrossPlatform;
  final bool prioritySupport;
  final bool freeEditOnce;

  const PackageLimits({
    required this.maxTextLength,
    required this.maxSpecialTextLength,
    required this.maxPages,
    required this.maxImages,
    required this.maxImageSizeMB,
    required this.maxVideos,
    required this.maxVideoLengthSeconds,
    required this.maxVideoSizeMB,
    required this.maxAudioLengthSeconds,
    required this.maxAudioSizeMB,
    required this.colorOptions,
    required this.musicOptions,
    required this.animationTypes,
    required this.fontOptions,
    required this.themeOptions,
    required this.expiryDays,
    required this.allowPhoneNumbers,
    required this.allowColorSelection,
    required this.allowImageUpload,
    required this.allowVideoUpload,
    required this.allowAudioUpload,
    required this.allowBackgroundMusic,
    required this.allowBasicAnimations,
    required this.allowAllEffects,
    required this.allowAPKDownload,
    required this.allowCrossPlatform,
    required this.prioritySupport,
    required this.freeEditOnce,
  });

  // 🆓 الباقة المجانية (Free Plan)
  factory PackageLimits.free() => const PackageLimits(
    maxTextLength: 200,        // رسالة واحدة حد أقصى 200 كلمة
    maxSpecialTextLength: 0,
    maxPages: 1,               // صفحة واحدة فقط
    maxImages: 0,              // لا صور
    maxImageSizeMB: 0,
    maxVideos: 0,              // لا فيديو
    maxVideoLengthSeconds: 0,
    maxVideoSizeMB: 0,
    maxAudioLengthSeconds: 0,  // لا موسيقى
    maxAudioSizeMB: 0,
    colorOptions: 1,           // لون واحد (أسود)
    musicOptions: 0,           // لا موسيقى
    animationTypes: 0,         // لا أنيميشن
    fontOptions: 1,            // خط افتراضي فقط
    themeOptions: 1,           // خلفية افتراضية واحدة
    expiryDays: 30,
    allowPhoneNumbers: false,
    allowColorSelection: false,
    allowImageUpload: false,
    allowVideoUpload: false,
    allowAudioUpload: false,
    allowBackgroundMusic: false,
    allowBasicAnimations: false,
    allowAllEffects: false,
    allowAPKDownload: false,   // لا توليد APK
    allowCrossPlatform: false,
    prioritySupport: false,
    freeEditOnce: false,
  );

  // 🥈 الباقة الفضية (Silver Plan)
  factory PackageLimits.silver() => const PackageLimits(
    maxTextLength: 600,        // 3 رسائل × 200 كلمة = 600 كلمة إجمالي
    maxSpecialTextLength: 0,
    maxPages: 3,               // صفحات متعددة
    maxImages: 2,              // صورة خلفية + صورة إضافية واحدة
    maxImageSizeMB: 5,
    maxVideos: 0,              // لا فيديو
    maxVideoLengthSeconds: 0,
    maxVideoSizeMB: 0,
    maxAudioLengthSeconds: 0,  // لا موسيقى
    maxAudioSizeMB: 0,
    colorOptions: 3,           // 3 ألوان أساسية
    musicOptions: 0,           // لا موسيقى
    animationTypes: 0,         // لا أنيميشن
    fontOptions: 2,            // خطين
    themeOptions: 3,           // 3 خيارات ألوان خلفية
    expiryDays: 60,
    allowPhoneNumbers: true,
    allowColorSelection: true,
    allowImageUpload: true,
    allowVideoUpload: false,
    allowAudioUpload: false,
    allowBackgroundMusic: false,
    allowBasicAnimations: false,
    allowAllEffects: false,
    allowAPKDownload: true,    // APK مع علامة مائية
    allowCrossPlatform: false,
    prioritySupport: false,
    freeEditOnce: false,
  );

  // 🥉 الباقة البرونزية (Bronze Plan)
  factory PackageLimits.bronze() => const PackageLimits(
    maxTextLength: 2500,       // 5 رسائل × 500 كلمة = 2500 كلمة
    maxSpecialTextLength: 0,
    maxPages: 5,               // صفحات متعددة
    maxImages: 5,              // 2 خلفية + 3 صور شخصية
    maxImageSizeMB: 10,
    maxVideos: 0,              // لا فيديو
    maxVideoLengthSeconds: 0,
    maxVideoSizeMB: 0,
    maxAudioLengthSeconds: 180, // 3 دقائق موسيقى
    maxAudioSizeMB: 10,
    colorOptions: -1,          // ألوان غير محدودة (Color Picker)
    musicOptions: 1,           // ملف موسيقى واحد
    animationTypes: 3,         // Fade In, Slide, Zoom
    fontOptions: 5,            // 5 خطوط مختلفة
    themeOptions: 12,          // 10 ألوان + خلفيات جاهزة
    expiryDays: 90,
    allowPhoneNumbers: true,
    allowColorSelection: true,
    allowImageUpload: true,
    allowVideoUpload: false,
    allowAudioUpload: true,
    allowBackgroundMusic: true,
    allowBasicAnimations: true,
    allowAllEffects: false,
    allowAPKDownload: true,    // APK كامل بدون Watermark
    allowCrossPlatform: false,
    prioritySupport: false,
    freeEditOnce: false,
  );

  // 🥇 الباقة الذهبية (Gold Plan)
  factory PackageLimits.gold() => const PackageLimits(
    maxTextLength: -1,         // عدد غير محدود من الرسائل
    maxSpecialTextLength: 1000, // كل رسالة حتى 1000 كلمة
    maxPages: -1,              // صفحات غير محدودة
    maxImages: -1,             // صور غير محدودة
    maxImageSizeMB: 50,
    maxVideos: -1,             // فيديوهات غير محدودة
    maxVideoLengthSeconds: 30, // حتى 30 ثانية لكل فيديو
    maxVideoSizeMB: 100,
    maxAudioLengthSeconds: -1, // موسيقى غير محدودة
    maxAudioSizeMB: 50,
    colorOptions: -1,          // ألوان حرة + Gradient
    musicOptions: -1,          // موسيقى غير محدودة
    animationTypes: -1,        // أنيميشن احترافي
    fontOptions: 20,           // 20+ خط
    themeOptions: 50,          // 50+ خلفية جاهزة
    expiryDays: 365,
    allowPhoneNumbers: true,
    allowColorSelection: true,
    allowImageUpload: true,
    allowVideoUpload: true,
    allowAudioUpload: true,
    allowBackgroundMusic: true,
    allowBasicAnimations: true,
    allowAllEffects: true,     // كل المؤثرات
    allowAPKDownload: true,    // APK + AAB + iOS
    allowCrossPlatform: true,  // أندرويد + آيفون
    prioritySupport: true,     // دعم فوري
    freeEditOnce: true,        // تعديل مجاني لمرة واحدة
  );
}
