# دليل إعداد نظام الهدايا 🎁

## نظرة عامة
نظام شامل لإنشاء وإدارة الهدايا الرقمية مع باقات متدرجة (مجانية، برونزية، فضية، ذهبية) وميزات متقدمة.

## الباقات المتاحة 📦

### 🆓 الباقة المجانية
- **السعر**: مجاناً
- **المميزات**:
  - رسالة نصية بسيطة (200 حرف)
  - صورة واحدة فقط
  - تصميم بسيط
  - صالحة لمدة 7 أيام
- **الاستخدام**: مثالي للتجربة والرسائل البسيطة

### 🥉 الباقة البرونزية
- **السعر**: 25 جنيه مصري
- **المميزات**:
  - رسالة نصية غنية (500 حرف)
  - حتى 3 ملفات وسائط
  - قوالب أساسية
  - تسجيل صوتي
  - صالحة لمدة 30 يوم
- **الاستخدام**: للرسائل الشخصية والمناسبات البسيطة

### 🥈 الباقة الفضية
- **السعر**: 50 جنيه مصري
- **المميزات**:
  - رسالة وسائط متعددة غنية (1000 حرف)
  - حتى 5 ملفات وسائط
  - قوالب مميزة مع تأثيرات
  - تسجيل صوتي ومرئي
  - موسيقى خلفية
  - جدولة الإرسال
  - صالحة لمدة 60 يوم
- **الاستخدام**: للمناسبات المهمة والهدايا المميزة

### 🥇 الباقة الذهبية
- **السعر**: 100 جنيه مصري
- **المميزات**:
  - تجربة وسائط متعددة مميزة (5000 حرف)
  - ملفات وسائط غير محدودة
  - قوالب وتأثيرات حصرية
  - تسجيل صوتي ومرئي احترافي
  - موسيقى خلفية مخصصة
  - جدولة متقدمة
  - إشعارات القراءة
  - صالحة لمدة سنة كاملة
  - دعم فني مميز
- **الاستخدام**: للمناسبات الخاصة والهدايا الفاخرة

## بنية النظام 🏗️

### نماذج البيانات
```dart
// GiftPackage.dart
enum GiftPackageType { free, bronze, silver, gold }

class GiftPackage {
  final GiftPackageType type;
  final String nameAr;
  final double price;
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
}
```

### خدمة الهدايا
```dart
// GiftService.dart
class Gift {
  final String id;
  final String creatorPhone;
  final String recipientPhone;
  final GiftPackageType packageType;
  final String title;
  final String message;
  final List<String> mediaUrls;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isDelivered;
  final bool isOpened;
}

class GiftService {
  static Future<String> createGift({...});
  static Future<List<Gift>> getAllGifts();
  static Future<List<Gift>> getUserGifts(String phone);
  static Future<Gift?> getGiftById(String giftId);
  static Future<void> updateGiftStatus(String giftId, {...});
}
```

## الصفحات الرئيسية 📱

### 1. صفحة إنشاء الهدية (CreateGiftPage)
- **المسار**: `/create-gift`
- **الوظيفة**: اختيار الباقة وتصميم الهدية
- **المميزات**:
  - عرض تفاعلي للباقات
  - مقارنة المميزات
  - أنيميشن انتقال سلس
  - واجهة تصميم الهدية (قريباً)

### 2. صفحة هداياي (MyGiftsPage)
- **المسار**: `/my-gifts`
- **الوظيفة**: عرض الهدايا المُرسلة والمُستلمة
- **المميزات**:
  - تبويب منفصل للهدايا المُرسلة والمُستلمة
  - عرض حالة الهدية (في الانتظار، تم التسليم، تم الفتح، منتهية)
  - إمكانية مشاركة الهدايا
  - عرض تفاصيل كل هدية

## التكامل مع النظام الحالي 🔗

### GitHub Token Service
```dart
// يدعم النظام بالفعل مستودع 'Hediya-Ghaliya'
static const Map<String, String> _tokenFiles = {
  'Users': 'user_token.txt',
  'app_upload': 'app_upload_token.txt', 
  'Hediya-Ghaliya': 'hediya_ghaliya_token.txt',
};
```

### التنقل والروابط
- الصفحة الرئيسية: زر "إنشاء هدية" → `/create-gift`
- الـ Drawer: "إنشاء هدية" → `/create-gift`
- الـ Drawer: "هداياي" → `/my-gifts`
- Dashboard Cards: "هداياي" → `/my-gifts`

## خطوات الإعداد 🚀

### 1. إعداد GitHub Repository
```bash
# تأكد من وجود مستودع 'Hediya-Ghaliya' في GitHub
# تأكد من وجود token في 'hediya_ghaliya_token.txt'
```

### 2. إعداد ملف الهدايا
سيتم إنشاء ملف `gifts.json` تلقائياً في مستودع 'Hediya-Ghaliya' عند إنشاء أول هدية.

### 3. اختبار النظام
```bash
flutter pub get
flutter analyze
flutter run
```

## استخدام النظام 📖

### إنشاء هدية جديدة
1. اضغط على "إنشاء هدية" من الصفحة الرئيسية
2. اختر الباقة المناسبة
3. صمم الهدية (قريباً)
4. أدخل بيانات المستلم
5. اختر موعد الإرسال (للباقات المدفوعة)
6. أكمل عملية الدفع (للباقات المدفوعة)

### عرض الهدايا
1. اذهب إلى "هداياي" من القائمة الجانبية
2. تصفح الهدايا المُرسلة أو المُستلمة
3. اضغط على "عرض التفاصيل" لمزيد من المعلومات
4. شارك الهدية مع الآخرين

## الميزات المستقبلية 🔮

### المرحلة التالية
- [ ] واجهة تصميم الهدية الكاملة
- [ ] نظام الدفع المتكامل
- [ ] قوالب جاهزة للهدايا
- [ ] تحميل الوسائط المتعددة
- [ ] نظام الإشعارات للهدايا

### المراحل المتقدمة
- [ ] مشاركة الهدايا عبر الشبكات الاجتماعية
- [ ] نظام التقييم والمراجعات
- [ ] إحصائيات مفصلة للمستخدمين
- [ ] نظام الخصومات والعروض
- [ ] تطبيق الويب المصاحب

## استكشاف الأخطاء 🔧

### مشاكل شائعة
1. **خطأ في جلب الهدايا**: تأكد من صحة GitHub token
2. **فشل في إنشاء هدية**: تحقق من اتصال الإنترنت
3. **عدم ظهور الهدايا**: تأكد من صحة رقم الهاتف

### حلول سريعة
```dart
// مسح cache الـ tokens
GitHubTokenService.clearCache();

// إعادة تحميل الهدايا
await GiftService.getAllGifts();
```

## الدعم والمساعدة 📞

للحصول على المساعدة:
- راجع ملف `README.md` للتعليمات العامة
- راجع ملف `GITHUB_TOKEN_SETUP.md` لإعداد الـ tokens
- تواصل مع فريق التطوير عبر GitHub Issues

---

**نظام الهدايا جاهز للاستخدام! 🎉**
