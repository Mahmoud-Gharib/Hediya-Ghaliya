# إعداد نظام GitHub Token الآمن

## نظرة عامة
تم تحديث التطبيق ليستخدم نظام آمن لإدارة GitHub tokens بدلاً من تضمينها مباشرة في الكود المصدري.

## كيفية العمل
- يتم جلب الـ token من ملف `.txt` موجود في GitHub repository منفصل
- يتم حفظ الـ token في ذاكرة مؤقتة لمدة 30 دقيقة لتحسين الأداء
- في حالة فشل جلب الـ token، يتم استخدام token احتياطي

## خطوات الإعداد

### 1. إنشاء Repository عام للـ Token
```bash
# إنشاء repository جديد في GitHub
# اسم مقترح: token-storage
# تأكد من جعله عام (Public) ليكون قابل للقراءة بدون access token
```

### 2. إنشاء ملف الـ Token
```bash
# إنشاء ملف github_token.txt في الـ repository
# ضع الـ GitHub token الخاص بك في هذا الملف
```

### 3. تحديث إعدادات الخدمة
في ملف `lib/services/github_token_service.dart`:

```dart
// تحديث هذه المتغيرات حسب الـ repository الخاص بك
static const String _tokenRepoOwner = 'mahmoud-gharib';
static const String _tokenRepoName = 'token-storage'; // اسم الـ repo الجديد
static const String _tokenFilePath = 'github_token.txt'; // مسار ملف الـ token
```

## الملفات المحدثة
- ✅ `lib/services/github_token_service.dart` - خدمة جلب الـ token
- ✅ `lib/pages/profile_page.dart` - تحديث لاستخدام الخدمة الجديدة
- ✅ `lib/pages/sign_in_page.dart` - تحديث لاستخدام الخدمة الجديدة  
- ✅ `lib/pages/sign_up_page.dart` - تحديث لاستخدام الخدمة الجديدة

## المزايا الأمنية
1. **عدم تضمين Tokens في الكود**: لا توجد tokens مكشوفة في الكود المصدري
2. **إدارة مركزية**: يمكن تحديث الـ token من مكان واحد
3. **Caching ذكي**: تقليل عدد الطلبات لـ GitHub API
4. **Fallback آمن**: في حالة فشل جلب الـ token، يتم استخدام آلية احتياطية

## استكشاف الأخطاء
- تأكد من صحة اسم الـ repository ومسار الملف
- تأكد من أن الـ repository عام (Public) وقابل للقراءة
- تحقق من اتصال الإنترنت
- راجع console logs للحصول على تفاصيل الأخطاء

## الاختبار
```bash
flutter pub get
flutter analyze
flutter run
```

## ملاحظات مهمة
- يجب أن يكون الـ repository الذي يحتوي على الـ token عام (Public) ليكون قابل للقراءة بدون access token
- تأكد من عدم وضع tokens حساسة جداً في repository عام
- راجع الـ tokens بانتظام وقم بتجديدها حسب الحاجة
- فكر في استخدام tokens محدودة الصلاحيات للأمان الإضافي
