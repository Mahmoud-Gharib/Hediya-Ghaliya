import 'package:shared_preferences/shared_preferences.dart';
import '../models/package.dart';

/// خدمة إدارة باقات "هدية غالية" 📦
class PackageService {
  static const String _packageKey = 'user_package';
  static const String _packageExpiryKey = 'package_expiry';
  static const String _packagePurchaseHistoryKey = 'package_history';
  static const String _freeEditUsedKey = 'free_edit_used';

  /// الحصول على الباقة الحالية للمستخدم
  static Future<PackageType> getCurrentPackage() async {
    final prefs = await SharedPreferences.getInstance();
    final packageString = prefs.getString(_packageKey);
    final expiry = prefs.getInt(_packageExpiryKey);
    
    // التحقق من انتهاء صلاحية الباقة
    if (expiry != null && DateTime.now().millisecondsSinceEpoch > expiry) {
      // انتهت صلاحية الباقة، العودة للمجانية
      await setPackage(PackageType.free);
      return PackageType.free;
    }
    
    if (packageString == null) return PackageType.free;
    
    switch (packageString) {
      case 'bronze':
        return PackageType.bronze;
      case 'silver':
        return PackageType.silver;
      case 'gold':
        return PackageType.gold;
      default:
        return PackageType.free;
    }
  }

  /// تعيين باقة جديدة للمستخدم
  static Future<void> setPackage(PackageType packageType, {int? durationDays}) async {
    final prefs = await SharedPreferences.getInstance();
    
    String packageString;
    int defaultDuration;
    
    switch (packageType) {
      case PackageType.bronze:
        packageString = 'bronze';
        defaultDuration = 90; // 3 أشهر
        break;
      case PackageType.silver:
        packageString = 'silver';
        defaultDuration = 60; // شهرين
        break;
      case PackageType.gold:
        packageString = 'gold';
        defaultDuration = 365; // سنة كاملة
        break;
      case PackageType.free:
      default:
        packageString = 'free';
        defaultDuration = 30; // شهر واحد
        break;
    }
    
    await prefs.setString(_packageKey, packageString);
    
    // تعيين تاريخ انتهاء الصلاحية
    if (packageType != PackageType.free) {
      final duration = durationDays ?? defaultDuration;
      final expiry = DateTime.now().add(Duration(days: duration));
      await prefs.setInt(_packageExpiryKey, expiry.millisecondsSinceEpoch);
      
      // حفظ تاريخ الشراء في السجل
      await _addPurchaseToHistory(packageType, expiry);
    } else {
      await prefs.remove(_packageExpiryKey);
    }
  }

  /// إضافة عملية شراء لسجل المشتريات
  static Future<void> _addPurchaseToHistory(PackageType packageType, DateTime expiry) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_packagePurchaseHistoryKey) ?? [];
    
    final purchase = {
      'package': packageType.toString(),
      'purchaseDate': DateTime.now().toIso8601String(),
      'expiryDate': expiry.toIso8601String(),
    };
    
    history.add(purchase.toString());
    await prefs.setStringList(_packagePurchaseHistoryKey, history);
  }

  /// التحقق من انتهاء صلاحية الباقة
  static Future<DateTime?> getPackageExpiry() async {
    final prefs = await SharedPreferences.getInstance();
    final expiry = prefs.getInt(_packageExpiryKey);
    if (expiry == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(expiry);
  }

  /// التحقق من إمكانية الترقية للباقة المطلوبة
  static Future<bool> canUpgradeTo(PackageType targetPackage) async {
    final currentPackage = await getCurrentPackage();
    final currentIndex = _getPackageIndex(currentPackage);
    final targetIndex = _getPackageIndex(targetPackage);
    
    return targetIndex > currentIndex;
  }

  /// التحقق من إمكانية التخفيض للباقة المطلوبة
  static Future<bool> canDowngradeTo(PackageType targetPackage) async {
    final currentPackage = await getCurrentPackage();
    final currentIndex = _getPackageIndex(currentPackage);
    final targetIndex = _getPackageIndex(targetPackage);
    
    return targetIndex < currentIndex;
  }

  /// الحصول على فهرس الباقة للمقارنة
  static int _getPackageIndex(PackageType packageType) {
    switch (packageType) {
      case PackageType.free:
        return 0;
      case PackageType.silver:
        return 1;
      case PackageType.bronze:
        return 2;
      case PackageType.gold:
        return 3;
    }
  }

  /// حساب سعر الترقية
  static Future<double> calculateUpgradePrice(PackageType targetPackage) async {
    final currentPackage = await getCurrentPackage();
    final currentPkg = GiftPackage.getPackage(currentPackage);
    final targetPkg = GiftPackage.getPackage(targetPackage);
    
    // حساب الفرق في السعر مع خصم نسبي للوقت المتبقي
    final expiry = await getPackageExpiry();
    double discount = 0;
    
    if (expiry != null && currentPackage != PackageType.free) {
      final daysRemaining = expiry.difference(DateTime.now()).inDays;
      final totalDays = currentPkg.limits.expiryDays;
      discount = (daysRemaining / totalDays) * currentPkg.price * 0.5; // خصم 50% من القيمة المتبقية
    }
    
    return (targetPkg.price - discount).clamp(0, targetPkg.price);
  }

  /// محاكاة عملية الدفع
  static Future<PaymentResult> processPayment(PackageType packageType, {double? customPrice}) async {
    try {
      // محاكاة تأخير الشبكة
      await Future.delayed(const Duration(seconds: 2));
      
      final package = GiftPackage.getPackage(packageType);
      final price = customPrice ?? package.price;
      
      // محاكاة نجاح الدفع (في التطبيق الحقيقي ستكون عملية دفع فعلية)
      final success = true; // يمكن تغييرها لمحاكاة فشل الدفع
      
      if (success) {
        await setPackage(packageType);
        return PaymentResult(
          success: true,
          packageType: packageType,
          price: price,
          transactionId: 'TXN_${DateTime.now().millisecondsSinceEpoch}',
          message: 'تم تفعيل ${package.name} بنجاح! 🎉',
        );
      } else {
        return PaymentResult(
          success: false,
          message: 'فشل في عملية الدفع. يرجى المحاولة مرة أخرى.',
        );
      }
    } catch (e) {
      return PaymentResult(
        success: false,
        message: 'حدث خطأ أثناء عملية الدفع: $e',
      );
    }
  }

  /// التحقق من استخدام التعديل المجاني (للباقة الذهبية)
  static Future<bool> hasFreeEditBeenUsed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_freeEditUsedKey) ?? false;
  }

  /// استخدام التعديل المجاني
  static Future<void> useFreeEdit() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_freeEditUsedKey, true);
  }

  /// إعادة تعيين التعديل المجاني (عند تجديد الباقة الذهبية)
  static Future<void> resetFreeEdit() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_freeEditUsedKey);
  }

  /// الحصول على معلومات الباقة الحالية مع تاريخ الانتهاء
  static Future<PackageInfo> getPackageInfo() async {
    final currentPackage = await getCurrentPackage();
    final expiry = await getPackageExpiry();
    final package = GiftPackage.getPackage(currentPackage);
    final freeEditUsed = await hasFreeEditBeenUsed();
    
    int? daysRemaining;
    if (expiry != null) {
      daysRemaining = expiry.difference(DateTime.now()).inDays;
      if (daysRemaining < 0) daysRemaining = 0;
    }
    
    return PackageInfo(
      package: package,
      expiry: expiry,
      isActive: expiry == null || DateTime.now().isBefore(expiry),
      daysRemaining: daysRemaining,
      freeEditUsed: freeEditUsed,
      canUseFreeEdit: currentPackage == PackageType.gold && !freeEditUsed,
    );
  }

  /// الحصول على الباقات المتاحة للترقية
  static Future<List<GiftPackage>> getAvailableUpgrades() async {
    final currentPackage = await getCurrentPackage();
    final currentIndex = _getPackageIndex(currentPackage);
    
    return GiftPackage.packages
        .where((pkg) => _getPackageIndex(pkg.type) > currentIndex)
        .toList();
  }

  /// التحقق من صحة الحدود للباقة الحالية
  static Future<bool> validateLimits({
    int? textLength,
    int? imageCount,
    int? videoCount,
    int? audioLength,
  }) async {
    final currentPackage = await getCurrentPackage();
    final limits = GiftPackage.getPackage(currentPackage).limits;
    
    if (textLength != null && limits.maxTextLength > 0 && textLength > limits.maxTextLength) {
      return false;
    }
    
    if (imageCount != null && limits.maxImages > 0 && imageCount > limits.maxImages) {
      return false;
    }
    
    if (videoCount != null && limits.maxVideos > 0 && videoCount > limits.maxVideos) {
      return false;
    }
    
    if (audioLength != null && limits.maxAudioLengthSeconds > 0 && audioLength > limits.maxAudioLengthSeconds) {
      return false;
    }
    
    return true;
  }
}

/// نتيجة عملية الدفع
class PaymentResult {
  final bool success;
  final PackageType? packageType;
  final double? price;
  final String? transactionId;
  final String message;

  PaymentResult({
    required this.success,
    this.packageType,
    this.price,
    this.transactionId,
    required this.message,
  });
}

/// معلومات الباقة الحالية
class PackageInfo {
  final GiftPackage package;
  final DateTime? expiry;
  final bool isActive;
  final int? daysRemaining;
  final bool freeEditUsed;
  final bool canUseFreeEdit;

  PackageInfo({
    required this.package,
    this.expiry,
    required this.isActive,
    this.daysRemaining,
    required this.freeEditUsed,
    required this.canUseFreeEdit,
  });
}
