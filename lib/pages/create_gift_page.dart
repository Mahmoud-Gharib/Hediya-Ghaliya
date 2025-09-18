import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/gift.dart';
import '../models/package.dart';
import '../services/pages_template.dart';
import '../services/package_service.dart';
import 'payment_page.dart';

// خيار قالب صفحة (top-level)
class _PageTemplateOption {
  final String type; // cover | dedication | message | photos
  final String label;
  final IconData icon;
  const _PageTemplateOption(this.type, this.label, this.icon);
}

class CreateGiftPage extends StatefulWidget {
  static const routeName = '/create';
  const CreateGiftPage({super.key});

  @override
  State<CreateGiftPage> createState() => _CreateGiftPageState();
}

class _CreateGiftPageState extends State<CreateGiftPage> {
  final _formPeople = GlobalKey<FormState>();

  int _step = 0;
  PackageType _selectedPackage = PackageType.free;

  // Controllers
  final _senderName = TextEditingController();
  final _senderPhone = TextEditingController();
  String? _senderRelation;

  final _recipientName = TextEditingController();
  final _recipientPhone = TextEditingController();
  String? _recipientRelation;

  String? _occasion;
  DateTime? _deliveryAt;

  final _title = TextEditingController();
  final _message = TextEditingController();

  String _themeId = 'classic';
  Color _accent = const Color(0xFFFF6F61);

  bool _saving = false;
  Map<String, dynamic>? _details; // تفاصيل ديناميكية حسب المناسبة

  // خطوة الصفحات: مسودات مبسطة لتحرير كل صفحة قبل الإنشاء
  final Map<String, Map<String, dynamic>> _pageDrafts = {};

  // ثابت: المناسبات والعلاقات
  static const occasions = [
    'عيد ميلاد', 'تخرج', 'عيد الحب', 'عيد الأضحى', 'عيد الفطر', 'رمضان', 'المولد النبوي', 'عيد الأم',
    'حج', 'عمرة', 'زواج', 'خطوبة', 'رأس السنة', 'دعم نفسي', 'تشجيع', 'أخرى'
  ];

  // المناسبات المحدودة للباقة المجانية
  static const freeOccasions = [
    'عيد ميلاد', 'عيد الأم', 'تشجيع'
  ];

  // الحصول على المناسبات المتاحة حسب الباقة
  List<String> get _availableOccasions {
    final package = GiftPackage.getPackage(_selectedPackage);
    if (package.hasFeature(PackageFeature.allOccasions)) {
      return occasions;
    } else {
      return freeOccasions;
    }
  }

  // Icon helpers
  IconData _iconForOccasion(String o) {
    switch (o) {
      case 'عيد ميلاد':
        return Icons.cake_outlined;
      case 'تخرج':
        return Icons.school_outlined;
      case 'عيد الحب':
        return Icons.favorite_border;
      case 'عيد الأضحى':
      case 'عيد الفطر':
      case 'رمضان':
      case 'المولد النبوي':
        return Icons.star_half;
      case 'عيد الأم':
        return Icons.volunteer_activism_outlined;
      case 'حج':
      case 'عمرة':
        return Icons.mosque_outlined;
      case 'زواج':
      case 'خطوبة':
        return Icons.ring_volume;
      case 'رأس السنة':
        return Icons.celebration_outlined;
      case 'دعم نفسي':
        return Icons.self_improvement_outlined;
      case 'تشجيع':
        return Icons.thumb_up_off_alt;
      default:
        return Icons.card_giftcard;
    }
  }

  

  @override
  void initState() {
    super.initState();
    _loadDraft();
    _loadUserPackage();
  }

  Future<void> _loadUserPackage() async {
    final currentPackage = await PackageService.getCurrentPackage();
    setState(() {
      _selectedPackage = currentPackage;
    });
  }

  @override
  void dispose() {
    _senderName.dispose();
    _senderPhone.dispose();
    _recipientName.dispose();
    _recipientPhone.dispose();
    _title.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString('draft_gift');
    if (s == null) return;
    try {
      final g = Gift.fromJson(s);
      setState(() {
        _senderName.text = g.senderName ?? '';
        _senderPhone.text = g.senderPhone ?? '';
        _senderRelation = g.senderRelation;
        _recipientName.text = g.recipientName ?? '';
        _recipientPhone.text = g.recipientPhone ?? '';
        _recipientRelation = g.recipientRelation;
        _occasion = g.occasion;
        _deliveryAt = g.deliveryAt;
        _title.text = g.title ?? '';
        _message.text = g.message ?? '';
        _themeId = g.themeId ?? 'classic';
        if (g.accentColor != null) _accent = Color(g.accentColor!);
        _details = g.details;
      });
    } catch (_) {}
  }

  Future<void> _saveDraft() async {
    setState(() => _saving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final g = _toGift();
      await prefs.setString('draft_gift', g.toJson());
      if (!mounted) return;
      _snack('تم حفظ المسودة');
    } catch (e) {
      _snack('تعذر حفظ المسودة: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Gift _toGift() => Gift(
        senderName: _senderName.text.trim(),
        senderPhone: _senderPhone.text.trim(),
        senderRelation: _senderRelation,
        recipientName: _recipientName.text.trim(),
        recipientPhone: _recipientPhone.text.trim(),
        recipientRelation: _recipientRelation,
        occasion: _occasion,
        deliveryAt: _deliveryAt,
        title: _title.text.trim(),
        message: _message.text.trim(),
        themeId: _themeId,
        accentColor: _accent.value,
        details: _details,
      );

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }



  // لم نعد نفتح صفحة الأشخاص كمسار منفصل

  Future<void> _processPaymentAndBuild() async {
    // للباقة المجانية، انتقل مباشرة لبناء الهدية
    if (_selectedPackage == PackageType.free) {
      setState(() => _step = 6);
      return;
    }
    
    // للباقات المدفوعة، تحقق من التفعيل
    final currentPackage = await PackageService.getCurrentPackage();
    
    if (currentPackage == _selectedPackage) {
      // الباقة مفعلة، انتقل لبناء الهدية
      setState(() => _step = 6);
    } else {
      // الباقة غير مفعلة، اذهب للدفع
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentPage(selectedPackage: _selectedPackage),
        ),
      ).then((success) {
        if (success == true) {
          setState(() => _step = 6);
        }
      });
    }
  }



  Future<void> _finalizeGift() async {
    // حفظ كمسودة أولاً
    try { await _saveDraft(); } catch (_) {}
    if (!mounted) return;
    
    // جهّز الهدية والصفحات (ولّد تلقائياً لعيد الأم إن لزم)
    var gift = _toGift();
    final details = (gift.details ?? <String, dynamic>{});
    final existing = (details['pages'] as List?)?.cast<Map>().map((e) => e.cast<String, dynamic>()).toList();
    if (existing == null || existing.isEmpty) {
      var pages = generatePagesForGift(gift);
      // تطبيق مسودات التحرير المبسطة إن وُجدت
      pages = _applyPageDraftsToPages(pages);
      details['pages'] = pages;
      gift.details = details;
    }
    
    // حفظ الهدية النهائية وإنهاء العملية
    try { 
      await _saveDraft(); 
      if (mounted) {
        _snack('تم إنشاء الهدية بنجاح!');
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) _snack('حدث خطأ في حفظ الهدية');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إنشاء هدية', style: TextStyle(fontWeight: FontWeight.w800)),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: _saving ? null : _saveDraft,
              tooltip: 'حفظ المسودة',
              icon: _saving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.save_outlined),
            ),
          ],
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF311B92), Color(0xFF8E24AA), Color(0xFFFF6F61)],
              ),
            ),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF311B92), Color(0xFF8E24AA), Color(0xFFFF6F61)],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: _glass(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.card_giftcard,
                        size: 80,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'إنشاء هدية جديدة',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'ابدأ رحلة إنشاء هديتك الرقمية المميزة',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/select-occasion');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6F61),
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          'ابدأ الآن',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  



  // People logic and UI (مأخوذ من PeoplePage مع تعديلات طفيفة)

  static const List<String> _commonRelations = [
    'أب','أم','أخ','أخت','زوج','زوجة','صديق','صديقة','ابن','ابنة','جار','جارة',
    'عم','عمة','خال','خالة','ابن عم','ابنة عم','ابن خال','ابنة خال','ابن خالة','ابنة خالة','حما','حماة','جد','جدة','حفيد','حفيدة',
    'ابن أخ','ابنة أخ','ابن أخت','ابنة أخت'
  ];

  List<String> get _recipientOptions {
    final occ = _occasion ?? '';
    final sender = _senderRelation ?? '';
    // منطق خاص بالخطوبة
    if (occ == 'خطوبة') {
      switch (sender) {
        case 'أب':
        case 'أم':
          return ['ابن (العريس)', 'ابنة (العروسة)'];
        case 'أخ':
        case 'أخت':
          return ['أخ (العريس)', 'أخت (العروسة)'];
        case 'جد':
        case 'جدة':
          return ['حفيد (العريس)', 'حفيدة (العروسة)'];
        case 'صديق':
        case 'صديقة':
          return ['صديق (العريس)', 'صديقة (العروسة)'];
        case 'جار':
        case 'جارة':
          return ['جار (العريس)', 'جارة (العروسة)'];
        case 'عم':
        case 'عمة':
          return ['ابن أخ (العريس)', 'ابنة أخ (العروسة)'];
        case 'خال':
        case 'خالة':
          return ['ابن أخت (العريس)', 'ابنة أخت (العروسة)'];
        case 'ابن عم':
          return ['ابن عم (العريس)', 'ابنة عم (العروسة)'];
        case 'ابنة عم':
          return ['ابن عم (العريس)', 'ابنة عم (العروسة)'];
        case 'ابن خال':
          return ['ابن خال (العريس)', 'ابنة خال (العروسة)'];
        case 'ابنة خال':
          return ['ابن خال (العريس)', 'ابنة خال (العروسة)'];
        default:
          // إن لم يُحدد المرسل بعد، لا نعرض شيء لحين الاختيار
          return [];
      }
    }
    // منطق خاص بعيد الأم
    if (occ == 'عيد الأم') {
      switch (sender) {
        case 'ابن':
          return ['أم'];
        case 'ابنة':
          return ['أم'];
        case 'زوج':
          return ['حماة (أم الزوجة)'];
        case 'زوجة':
          return ['حماة (أم الزوج)'];
        default:
          return [];
      }
    }
    // باقي المناسبات: تقاطع القوائم العامة
    final base = _rolesForOccasion(occ);
    if (sender.isEmpty) return base;
    final allowed = _allowedBySender(sender);
    final filtered = base.where((e) => allowed.toSet().contains(e)).toList();
    return filtered.isEmpty ? base : filtered;
  }

  static List<String> _allowedBySender(String senderRelation) {
    switch (senderRelation) {
      case 'أب':
      case 'أم':
        return ['ابن', 'ابنة'];
      case 'أخ':
      case 'أخت':
        return ['أخ', 'أخت'];
      case 'زوج':
        return ['زوجة'];
      case 'زوجة':
        return ['زوج'];
      case 'صديق':
      case 'صديقة':
        return ['صديق', 'صديقة'];
      case 'جد':
      case 'جدة':
        return ['حفيد', 'حفيدة'];
      case 'حفيد':
      case 'حفيدة':
        return ['جد', 'جدة'];
      case 'عم':
      case 'عمة':
      case 'خال':
      case 'خالة':
        return ['ابن أخ','ابنة أخ','ابن أخت','ابنة أخت'];
      case 'ابن':
      case 'ابنة':
        return ['أب','أم'];
      case 'جار':
      case 'جارة':
        return ['جار','جارة'];
      case 'حما':
      case 'حماة':
        return ['زوج','زوجة'];
      default:
        return _commonRelations;
    }
  }

  static List<String> _rolesForOccasion(String o) {
    switch (o) {
      case 'عيد ميلاد':
        return _commonRelations;
      case 'زواج':
        return ['زوج', 'زوجة'];
      case 'خطوبة':
        // في الخطوبة: سنضبط المستلمين لاحقًا حسب المرسل، وهنا نعيد مجموعة عامة لتفادي إفراغ كامل القيم
        return _commonRelations;
      case 'عيد الأم':
        return ['أم'];
      case 'حج':
      case 'عمرة':
        return _commonRelations;
      default:
        return _commonRelations;
    }
  }

  List<String> _senderOptionsForOccasion(String o) {
    switch (o) {
      case 'خطوبة':
        return [
          'أب','أم','أخ','أخت','جد','جدة','صديق','صديقة','جار','جارة','عم','عمة','خال','خالة','ابن عم','ابنة عم','ابن خال','ابنة خال'
        ];
      case 'عيد الأم':
        return ['ابن','ابنة','زوج','زوجة'];
      default:
        return _commonRelations;
    }
  }

  IconData _iconForRelation(String r) {
    // تجاهل أي لاحقات مثل (العريس)/(العروسة) عند تحديد الأيقونة
    final base = r.split(' (').first.trim();
    switch (base) {
      case 'أب':
      case 'ابن':
      case 'أخ':
      case 'عم':
      case 'خال':
      case 'جد':
      case 'حما':
      case 'حفيد':
      case 'ابن عم':
      case 'ابن خال':
      case 'ابن خالة':
      case 'ابن أخ':
      case 'ابن أخت':
        return Icons.male;
      case 'أم':
      case 'ابنة':
      case 'أخت':
      case 'عمة':
      case 'خالة':
      case 'جدة':
      case 'حماة':
      case 'حفيدة':
      case 'ابنة عم':
      case 'ابنة خال':
      case 'ابنة خالة':
      case 'ابنة أخ':
      case 'ابنة أخت':
        return Icons.female;
      case 'زوج':
      case 'زوجة':
        return Icons.favorite_outline;
      case 'صديق':
      case 'صديقة':
        return Icons.handshake_outlined;
      case 'جار':
      case 'جارة':
        return Icons.home_outlined;
      default:
        return Icons.person_outline;
    }
  }

  Widget _peopleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // المرسل
        _peopleCard(
          title: 'المرسل',
          relationGrid: _relationsGrid(
            options: _senderOptionsForOccasion(_occasion ?? ''),
            selected: _senderRelation,
            onPick: (v) => setState(() {
              _senderRelation = v;
              final opts = _recipientOptions;
              if (!opts.contains(_recipientRelation)) {
                _recipientRelation = opts.isNotEmpty ? opts.first : null;
              }
            }),
          ),
          nameField: TextFormField(
            controller: _senderName,
            decoration: _inputDecoration('اسم المرسل'),
            validator: (v) => v == null || v.trim().isEmpty ? 'ادخل اسم المرسل' : null,
          ),
          phoneField: GiftPackage.getPackage(_selectedPackage).limits.allowPhoneNumbers
              ? TextFormField(
                  controller: _senderPhone,
                  keyboardType: TextInputType.phone,
                  decoration: _inputDecoration('هاتف المرسل'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'ادخل هاتف المرسل' : null,
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 12),
        // المرسل إليه
        _peopleCard(
          title: 'المُرسل إليه',
          relationGrid: _relationsGrid(
            options: _recipientOptions,
            selected: _recipientRelation,
            onPick: (v) => setState(() => _recipientRelation = v),
          ),
          nameField: TextFormField(
            controller: _recipientName,
            decoration: _inputDecoration('اسم المُرسل إليه'),
            validator: (v) => v == null || v.trim().isEmpty ? 'ادخل اسم المُرسل إليه' : null,
          ),
          phoneField: GiftPackage.getPackage(_selectedPackage).limits.allowPhoneNumbers
              ? TextFormField(
                  controller: _recipientPhone,
                  keyboardType: TextInputType.phone,
                  decoration: _inputDecoration('هاتف المُرسل إليه'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'ادخل هاتف المُرسل إليه' : null,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _peopleCard({
    required String title,
    required Widget relationGrid,
    required Widget nameField,
    required Widget phoneField,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        relationGrid,
        const SizedBox(height: 12),
        nameField,
        const SizedBox(height: 8),
        phoneField,
      ],
    );
  }

  Widget _relationsGrid({
    required List<String> options,
    required String? selected,
    required ValueChanged<String> onPick,
  }) {
    // إذا كانت القائمة فارغة، نعرض رسالة
    if (options.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'اختر المرسل أولاً لعرض الخيارات المتاحة',
          style: TextStyle(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, c) {
        final cross = c.maxWidth > 520 ? 4 : 3;
        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cross,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.6,
          ),
          itemCount: options.length,
          itemBuilder: (context, i) {
            final r = options[i];
            return _selectCard(
              label: r,
              selected: r == selected,
              icon: _iconForRelation(r),
              onTap: () => onPick(r),
            );
          },
        );
      },
    );
  }

  Widget _packageCard({required GiftPackage package, bool selected = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? _accent.withOpacity(0.2) : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? _accent : Colors.white.withOpacity(0.18),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  package.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        package.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        package.description,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      package.price == 0 ? 'مجاناً' : '${package.price.toInt()} جنيه',
                      style: TextStyle(
                        color: package.price == 0 ? Colors.green : Colors.amber,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (selected)
                      const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 20,
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              package.features.take(3).join(' • '),
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 11,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _selectCard({required String label, bool selected = false, IconData? icon, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: (selected ? _accent : Colors.white.withOpacity(0.08)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(selected ? 0.0 : 0.18)),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(color: selected ? Colors.white : Colors.white, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // لم تعد مستخدمة بعد اعتماد PeoplePage

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: Colors.white.withOpacity(0.06),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.25)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white),
      ),
    );
  }

  Widget _glass({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: DefaultTextStyle.merge(
        style: const TextStyle(color: Colors.white),
        child: child,
      ),
    );
  }

  // صفحات الهدية: شبكة بطاقات بنفس تصميم المناسبات (تفتح محرر مبسط عند الضغط)
  Widget _pagesTemplatesGrid() {
    final options = _pageTemplateOptionsForOccasion(_occasion ?? '');
    return LayoutBuilder(
      builder: (context, c) {
        final cross = c.maxWidth > 520 ? 4 : 3;
        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cross,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.6,
          ),
          itemCount: options.length,
          itemBuilder: (context, i) {
            final t = options[i];
            final selected = _pageDrafts.containsKey(t.type); // مميز إذا تم تحريره
            return _selectCard(
              label: t.label,
              selected: selected,
              icon: t.icon,
              onTap: () => _openSimpleEditor(t.type),
            );
          },
        );
      },
    );
  }

  List<_PageTemplateOption> _pageTemplateOptionsForOccasion(String o) {
    final package = GiftPackage.getPackage(_selectedPackage);
    List<_PageTemplateOption> options = [];
    
    // الباقة المجانية: صفحة رسالة واحدة فقط
    if (package.type == PackageType.free) {
      return const [
        _PageTemplateOption('message', 'رسالة نصية قصيرة', Icons.edit_note_outlined),
      ];
    }
    
    // الباقة البرونزية: صفحات أساسية
    if (package.type == PackageType.bronze) {
      return const [
        _PageTemplateOption('cover', 'صفحة ترحيب', Icons.login),
        _PageTemplateOption('message', 'رسالة نصية', Icons.edit_note_outlined),
        _PageTemplateOption('photos', 'صورة واحدة', Icons.image_outlined),
      ];
    }
    
    // الباقة الفضية: صفحات إضافية
    if (package.type == PackageType.silver) {
      return const [
        _PageTemplateOption('cover', 'صفحة ترحيب', Icons.login),
        _PageTemplateOption('dedication', 'إهداء', Icons.menu_book_outlined),
        _PageTemplateOption('message', 'رسالة نصية', Icons.edit_note_outlined),
        _PageTemplateOption('special', 'رسالة خاصة/دعاء', Icons.favorite_outlined),
        _PageTemplateOption('photos', 'ألبوم صور (5 صور)', Icons.image_outlined),
      ];
    }
    
    // الباقة الذهبية: كل الصفحات
    return const [
      _PageTemplateOption('cover', 'صفحة ترحيب', Icons.login),
      _PageTemplateOption('dedication', 'إهداء', Icons.menu_book_outlined),
      _PageTemplateOption('message', 'رسالة نصية', Icons.edit_note_outlined),
      _PageTemplateOption('special', 'رسالة خاصة/دعاء', Icons.favorite_outlined),
      _PageTemplateOption('photos', 'ألبوم صور', Icons.image_outlined),
      _PageTemplateOption('video', 'فيديو شخصي', Icons.video_camera_back_outlined),
      _PageTemplateOption('voice', 'رسالة صوتية', Icons.mic_outlined),
      _PageTemplateOption('memories', 'ذكرياتنا', Icons.photo_album_outlined),
      _PageTemplateOption('wishes', 'أمنيات المستقبل', Icons.star_outlined),
    ];
  }

  // محررات مبسطة لكل نوع صفحة
  Future<void> _openSimpleEditor(String type) async {
    final package = GiftPackage.getPackage(_selectedPackage);
    
    switch (type) {
      case 'cover':
        await _editCoverSimple();
        break;
      case 'dedication':
        await _editDedicationSimple();
        break;
      case 'message':
        await _editMessageSimple();
        break;
      case 'special':
        await _editSpecialSimple();
        break;
      case 'photos':
        await _editPhotosSimple();
        break;
      case 'video':
        if (package.limits.allowVideoUpload) {
          await _editVideoSimple();
        } else {
          _showUpgradeDialog('فيديو شخصي');
        }
        break;
      case 'voice':
        if (package.limits.allowAudioUpload) {
          await _editVoiceSimple();
        } else {
          _showUpgradeDialog('رسالة صوتية');
        }
        break;
      case 'memories':
        if (package.limits.maxPages >= 8) {
          await _editMemoriesSimple();
        } else {
          _showUpgradeDialog('صفحة الذكريات');
        }
        break;
      case 'wishes':
        if (package.limits.maxPages >= 9) {
          await _editWishesSimple();
        } else {
          _showUpgradeDialog('صفحة أمنيات المستقبل');
        }
        break;
      default:
        _snack('قريبًا سيتم دعم هذا النوع');
    }
    if (mounted) setState(() {});
  }

  Future<void> _editCoverSimple() async {
    _snack('تحرير الغلاف غير متاح حاليًا. سيتم دعمه لاحقًا.');
  }

  Future<void> _editDedicationSimple() async {
    _snack('تحرير صفحة الإهداء غير متاح حاليًا. سيتم دعمه لاحقًا.');
  }

  Future<void> _editMessageSimple() async {
    final package = GiftPackage.getPackage(_selectedPackage);
    final limits = package.limits;
    
    String message = 'تحرير صفحة الرسالة غير متاح حاليًا. سيتم دعمه لاحقًا.\n';
    message += 'في ${package.name} يمكنك كتابة حتى ${limits.maxTextLength} حرف.';
    
    _snack(message);
  }

  Future<void> _editSpecialSimple() async {
    final package = GiftPackage.getPackage(_selectedPackage);
    final limits = package.limits;
    
    if (limits.maxSpecialTextLength == 0) {
      _snack('الرسالة الخاصة/الدعاء غير متاحة في ${package.name}. قم بالترقية للباقة الفضية أو أعلى.');
      return;
    }
    
    String message = 'تحرير الرسالة الخاصة/الدعاء غير متاح حاليًا. سيتم دعمه لاحقًا.\n';
    message += 'في ${package.name} يمكنك كتابة حتى ${limits.maxSpecialTextLength} حرف للرسالة الخاصة.';
    
    _snack(message);
  }

  Future<void> _editPhotosSimple() async {
    final package = GiftPackage.getPackage(_selectedPackage);
    final limits = package.limits;
    
    if (!limits.allowImageUpload) {
      _snack('الصور غير متاحة في ${package.name}. قم بالترقية للباقة البرونزية أو أعلى.');
      return;
    }
    
    String message = 'تحرير الصور غير متاح حاليًا. سيتم دعمه لاحقًا.\n';
    message += 'في ${package.name} يمكنك إضافة حتى ${limits.maxImages} ';
    message += limits.maxImages == 1 ? 'صورة' : 'صور';
    message += ' (حد أقصى ${limits.maxImageSizeMB}MB لكل صورة).';
    
    _snack(message);
  }

  Future<void> _editVideoSimple() async {
    final package = GiftPackage.getPackage(_selectedPackage);
    final limits = package.limits;
    
    String message = 'تحرير الفيديو الشخصي غير متاح حاليًا. سيتم دعمه لاحقًا.\n';
    message += 'في ${package.name} يمكنك إضافة فيديو حتى ${limits.maxVideoLengthSeconds} ثانية ';
    message += '(حد أقصى ${limits.maxVideoSizeMB}MB).';
    
    _snack(message);
  }

  Future<void> _editVoiceSimple() async {
    final package = GiftPackage.getPackage(_selectedPackage);
    final limits = package.limits;
    
    String message = 'تحرير الرسالة الصوتية غير متاح حاليًا. سيتم دعمه لاحقًا.\n';
    message += 'في ${package.name} يمكنك تسجيل صوت حتى ${limits.maxAudioLengthSeconds} ثانية ';
    message += '(حد أقصى ${limits.maxAudioSizeMB}MB).';
    
    _snack(message);
  }

  Future<void> _editMemoriesSimple() async {
    _snack('تحرير صفحة الذكريات غير متاح حاليًا. سيتم دعمه لاحقًا.');
  }

  Future<void> _editWishesSimple() async {
    _snack('تحرير صفحة أمنيات المستقبل غير متاح حاليًا. سيتم دعمه لاحقًا.');
  }

  void _showUpgradeDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text('ترقية الباقة مطلوبة'),
          content: Text('ميزة "$feature" متاحة فقط في الباقات المدفوعة. هل تريد ترقية باقتك؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('لاحقاً'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showPackageUpgradeDialog();
              },
              child: const Text('ترقية الآن'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPackageUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('اختر الباقة الجديدة'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: ListView.builder(
              itemCount: GiftPackage.packages.where((p) => p.type != _selectedPackage).length,
              itemBuilder: (context, index) {
                final availablePackages = GiftPackage.packages.where((p) => p.type != _selectedPackage).toList();
                final package = availablePackages[index];
                return Card(
                  child: ListTile(
                    leading: Text(package.emoji, style: const TextStyle(fontSize: 24)),
                    title: Text(package.name),
                    subtitle: Text('${package.price.toInt()} جنيه - ${package.description}'),
                    onTap: () async {
                      Navigator.pop(context);
                      if (package.price > 0) {
                        // فتح صفحة الدفع للباقات المدفوعة
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentPage(selectedPackage: package.type),
                          ),
                        );
                        if (result == true) {
                          // تم الدفع بنجاح، تحديث الباقة
                          final newPackage = await PackageService.getCurrentPackage();
                          setState(() {
                            _selectedPackage = newPackage;
                          });
                          _snack('تم تفعيل ${package.name} بنجاح!');
                        }
                      } else {
                        // الباقة المجانية
                        await PackageService.setPackage(package.type);
                        setState(() {
                          _selectedPackage = package.type;
                        });
                        _snack('تم تحديث الباقة إلى ${package.name}');
                      }
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _applyPageDraftsToPages(List<Map<String, dynamic>> pages) {
    // يُعدل محتوى القوالب حسب مسودات المستخدم
    List<Map<String, dynamic>> result = pages.map((e) => Map<String, dynamic>.from(e)).toList();
    for (final p in result) {
      final type = (p['type'] ?? '').toString();
      final blocks = (p['blocks'] as List?)?.cast<Map>().map((e) => Map<String, dynamic>.from(e)).toList() ?? [];
      final draft = _pageDrafts[type];
      if (draft == null) continue;
      if (type == 'cover') {
        // نعرض بيانات الوضع التجريبي على الغلاف بشكل مبسط
        for (int i = 0; i < blocks.length; i++) {
          final b = blocks[i];
          if (i == 1 && draft['username'] != null && (draft['username'] as String).isNotEmpty) {
            b['content'] = 'User: ${draft['username']}';
          }
          if (i == 2 && draft['password'] != null && (draft['password'] as String).isNotEmpty) {
            final masked = '*' * (draft['password']?.toString().length ?? 0);
            b['content'] = 'Password: $masked';
          }
        }
      } else if (type == 'dedication') {
        // أول بلوك اقتباس
        if (blocks.isNotEmpty && draft['text'] != null) {
          blocks[0]['content'] = draft['text'];
        }
      } else if (type == 'message') {
        if (blocks.isNotEmpty && draft['text'] != null) {
          blocks[0]['content'] = draft['text'];
        }
      } else if (type == 'photos') {
        // لا صور فعلية الآن، فقط تعليقات اختيارية (يمكن وضعها كبلوكات نص بعد الصور)
        if (draft['caption1'] != null && blocks.isNotEmpty) {
          blocks.add({'type': 'text', 'content': draft['caption1'], 'style': const {'align': 'center', 'size': 14}});
        }
        if (draft['caption2'] != null && blocks.isNotEmpty) {
          blocks.add({'type': 'text', 'content': draft['caption2'], 'style': const {'align': 'center', 'size': 14}});
        }
      }
      p['blocks'] = blocks;
    }
    return result;
  }
}
