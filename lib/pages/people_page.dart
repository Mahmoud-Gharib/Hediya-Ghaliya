import 'package:flutter/material.dart';

class PeoplePage extends StatefulWidget {
  final String occasion;
  final String? initialSenderName;
  final String? initialSenderPhone;
  final String? initialSenderRelation;
  final String? initialRecipientName;
  final String? initialRecipientPhone;
  final String? initialRecipientRelation;

  const PeoplePage({
    super.key,
    required this.occasion,
    this.initialSenderName,
    this.initialSenderPhone,
    this.initialSenderRelation,
    this.initialRecipientName,
    this.initialRecipientPhone,
    this.initialRecipientRelation,
  });

  @override
  State<PeoplePage> createState() => _PeoplePageState();
}

class _PeoplePageState extends State<PeoplePage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _senderName;
  late final TextEditingController _senderPhone;
  String? _senderRelation;

  late final TextEditingController _recipientName;
  late final TextEditingController _recipientPhone;
  String? _recipientRelation;

  List<String> get _recipientRoleOptions => _rolesForOccasion(widget.occasion);

  // Accent color to match app style
  static const Color _accent = Color(0xFFFF6F61);

  // Compute allowed recipient roles based on sender relation
  List<String> get _recipientOptions {
    final base = _recipientRoleOptions;
    if (_senderRelation == null || _senderRelation!.isEmpty) return base;
    final allowed = _allowedBySender(_senderRelation!);
    final filtered = _intersect(base, allowed);
    return filtered.isEmpty ? base : filtered; // fallback to base if intersection empty
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
        return ['صديق', 'صديقة'];
      case 'صديقة':
        return ['صديق', 'صديقة'];
      case 'جد':
        return ['حفيد', 'حفيدة'];
      case 'جدة':
        return ['حفيد', 'حفيدة'];
      case 'حفيد':
        return ['جد', 'جدة'];
      case 'حفيدة':
        return ['جد', 'جدة'];
      case 'عم':
      case 'عمة':
      case 'خال':
      case 'خالة':
        return ['ابن أخ','ابنة أخ','ابن أخت','ابنة أخت'];
      case 'ابن':
        return ['أب','أم'];
      case 'ابنة':
        return ['أب','أم'];
      case 'جار':
      case 'جارة':
        return ['جار','جارة'];
      case 'حما':
        return ['زوج','زوجة'];
      case 'حماة':
        return ['زوج','زوجة'];
      default:
        // افتراضيًا: لا نقيّد بشكل صارم ونسمح بالأقرب شيوعًا
        return _commonRelations;
    }
  }

  static List<String> _intersect(List<String> a, List<String> b) {
    final sb = b.toSet();
    return a.where((e) => sb.contains(e)).toList();
  }

  static const List<String> _commonRelations = [
    'أب','أم','أخ','أخت','زوج','زوجة','صديق','صديقة','ابن','ابنة','جار','جارة',
    'عم','عمة','خال','خالة','ابن عم','ابنة عم','ابن خال','ابنة خال','ابن خالة','ابنة خالة','حما','حماة','جد','جدة','حفيد','حفيدة',
    'ابن أخ','ابنة أخ','ابن أخت','ابنة أخت'
  ];

  static List<String> _rolesForOccasion(String o) {
    switch (o) {
      case 'عيد ميلاد':
        // أي شخص ممكن يكون صاحب المناسبة
        return _commonRelations;
      case 'زواج':
        return ['زوج', 'زوجة'];
      case 'خطوبة':
        return ['خطيب', 'خطيبة'];
      case 'عيد الأم':
        return ['الأم'];
      case 'رأس السنة':
        return ['صديق','صديقة','قريب','قريبة'];
      case 'تخرج':
        return ['الخريج', 'الخريجة'];
      case 'عيد الحب':
        return ['حبيب', 'حبيبة'];
      case 'حج':
        return ['حاج', 'حاجة'];
      case 'عمرة':
        return ['معتمر', 'معتمرة'];
      case 'عيد الأضحى':
      case 'عيد الفطر':
      case 'رمضان':
      case 'المولد النبوي':
        return ['قريب','قريبة','جار','جارة','صديق','صديقة'];
      case 'دعم نفسي':
      case 'تشجيع':
        return ['المستفيد'];
      default:
        return _commonRelations;
    }
  }

  @override
  void initState() {
    super.initState();
    _senderName = TextEditingController(text: widget.initialSenderName ?? '');
    _senderPhone = TextEditingController(text: widget.initialSenderPhone ?? '');
    _senderRelation = widget.initialSenderRelation;

    _recipientName = TextEditingController(text: widget.initialRecipientName ?? '');
    _recipientPhone = TextEditingController(text: widget.initialRecipientPhone ?? '');
    _recipientRelation = widget.initialRecipientRelation ?? (_recipientOptions.isNotEmpty ? _recipientOptions.first : null);
  }

  @override
  void dispose() {
    _senderName.dispose();
    _senderPhone.dispose();
    _recipientName.dispose();
    _recipientPhone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('بيانات الأشخاص', style: TextStyle(fontWeight: FontWeight.w800)),
          centerTitle: true,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF3E2F75), Color(0xFF5B2C83), Color(0xFF6A2D91)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.18)),
                  ),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        Text('المناسبة', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.9))),
                        const SizedBox(height: 6),
                        Text('اخترت: ${widget.occasion}', style: const TextStyle(color: Colors.white70)),
                        const SizedBox(height: 16),
                        _card(
                          title: 'المرسل',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text('اختر العلاقة (اختياري)', style: TextStyle(fontSize: 12, color: Colors.white70)),
                              const SizedBox(height: 8),
                              _relationsGrid(
                                options: _commonRelations,
                                selected: _senderRelation,
                                onPick: (v) => setState(() {
                                  _senderRelation = v;
                                  final opts = _recipientOptions;
                                  if (!opts.contains(_recipientRelation)) {
                                    _recipientRelation = opts.isNotEmpty ? opts.first : null;
                                  }
                                }),
                              ),
                              const SizedBox(height: 12),
                              _darkField(
                                controller: _senderName,
                                label: 'اسم المرسل',
                                validator: (v) => v == null || v.trim().isEmpty ? 'ادخل اسم المرسل' : null,
                              ),
                              const SizedBox(height: 8),
                              _darkField(
                                controller: _senderPhone,
                                label: 'هاتف المرسل (اختياري)',
                                keyboardType: TextInputType.phone,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _card(
                          title: 'المُرسل إليه',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text('اختر الدور حسب المناسبة', style: TextStyle(fontSize: 12, color: Colors.white70)),
                              const SizedBox(height: 8),
                              _relationsGrid(
                                options: _recipientOptions,
                                selected: _recipientRelation,
                                onPick: (v) => setState(() => _recipientRelation = v),
                              ),
                              const SizedBox(height: 12),
                              _darkField(
                                controller: _recipientName,
                                label: 'اسم المُرسل إليه',
                                validator: (v) => v == null || v.trim().isEmpty ? 'ادخل اسم المُرسل إليه' : null,
                              ),
                              const SizedBox(height: 8),
                              _darkField(
                                controller: _recipientPhone,
                                label: 'هاتف المُرسل إليه (اختياري)',
                                keyboardType: TextInputType.phone,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text('بعد اختيار البيانات اضغط التالي لإكمال تفاصيل الهدية', style: const TextStyle(color: Colors.white60, fontSize: 12)),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _accent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: _submit,
                            icon: const Icon(Icons.arrow_back_ios_new_rounded),
                            label: const Text('حفظ والعودة'),
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
      ),
    );
  }

  Widget _card({required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }

  Widget _relationsGrid({
    required List<String> options,
    required String? selected,
    required ValueChanged<String> onPick,
  }) {
    return LayoutBuilder(
      builder: (context, c) {
        final maxW = c.maxWidth;
        final crossAxisCount = maxW > 700 ? 4 : 3; // مطابقة شاشة المناسبة
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.8,
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

  Widget _selectCard({required String label, bool selected = false, IconData? icon, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: selected ? _accent : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(selected ? 0.0 : 0.35)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _darkField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.06),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.22)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _accent, width: 1.6),
        ),
      ),
    );
  }

  IconData _iconForRelation(String r) {
    switch (r) {
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

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    if (_recipientRelation == null || _recipientRelation!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار دور المُرسل إليه')),
      );
      return;
    }
    Navigator.pop(context, {
      'senderName': _senderName.text.trim(),
      'senderPhone': _senderPhone.text.trim(),
      'senderRelation': _senderRelation,
      'recipientName': _recipientName.text.trim(),
      'recipientPhone': _recipientPhone.text.trim(),
      'recipientRelation': _recipientRelation,
    });
  }
}
