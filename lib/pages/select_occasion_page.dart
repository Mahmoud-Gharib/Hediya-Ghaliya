import 'package:flutter/material.dart';
import '../models/package.dart';

/// صفحة اختيار المناسبة مع دعم قيود الباقات 🎉
class SelectOccasionPage extends StatefulWidget {
  final PackageType packageType;
  
  const SelectOccasionPage({
    super.key,
    this.packageType = PackageType.free,
  });

  @override
  State<SelectOccasionPage> createState() => _SelectOccasionPageState();
}

class _SelectOccasionPageState extends State<SelectOccasionPage> {
  String? selectedOccasion;
  final TextEditingController otherController = TextEditingController();
  late PackageLimits packageLimits;

  // المناسبات المتاحة للباقة المجانية (محدودة)
  final List<Map<String, String>> freeOccasions = [
    {"icon": "🎂", "name": "عيد ميلاد"},
    {"icon": "💖", "name": "عيد الحب"},
    {"icon": "🎓", "name": "تخرج"},
    {"icon": "🧕", "name": "شكر وتقدير"},
  ];

  // المناسبات الكاملة للباقات المدفوعة
  final List<Map<String, String>> allOccasions = [
    {"icon": "🎂", "name": "عيد ميلاد"},
    {"icon": "🎓", "name": "تخرج"},
    {"icon": "👩‍👧‍👦", "name": "عيد الأم"},
    {"icon": "👨‍👧‍👦", "name": "عيد الأب"},
    {"icon": "💖", "name": "عيد الحب"},
    {"icon": "🎄", "name": "رأس السنة"},
    {"icon": "🕌", "name": "عيد الفطر"},
    {"icon": "🐑", "name": "عيد الأضحى"},
    {"icon": "🌙", "name": "رمضان كريم"},
    {"icon": "👫", "name": "خطوبة"},
    {"icon": "💍", "name": "زواج"},
    {"icon": "👶", "name": "مولود جديد"},
    {"icon": "🏠", "name": "بيت جديد"},
    {"icon": "🚗", "name": "سيارة جديدة"},
    {"icon": "💼", "name": "وظيفة جديدة"},
    {"icon": "🧕", "name": "شكر وتقدير"},
    {"icon": "🤲", "name": "دعاء ومباركة"},
    {"icon": "💪", "name": "دعم نفسي"},
  ];

  @override
  void initState() {
    super.initState();
    packageLimits = GiftPackage.getPackage(widget.packageType).limits;
  }

  @override
  void dispose() {
    otherController.dispose();
    super.dispose();
  }

  List<Map<String, String>> get availableOccasions {
    return widget.packageType == PackageType.free ? freeOccasions : allOccasions;
  }

  bool get canAddCustomOccasion {
    return widget.packageType != PackageType.free;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          '🎉 اختيار المناسبة',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: _getPackageColor(),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // معلومات الباقة الحالية
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getPackageColor().withOpacity(0.1),
              border: Border(
                bottom: BorderSide(
                  color: _getPackageColor().withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getPackageIcon(),
                  color: _getPackageColor(),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  _getPackageTitle(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getPackageColor(),
                  ),
                ),
                const Spacer(),
                if (widget.packageType == PackageType.free)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'مناسبات محدودة',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // عنوان
                  const Text(
                    'اختر مناسبتك المميزة',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.packageType == PackageType.free
                        ? 'المناسبات المتاحة في الباقة المجانية'
                        : 'جميع المناسبات متاحة في باقتك',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF718096),
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  
                  const SizedBox(height: 24),

                  // شبكة المناسبات
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.1,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: availableOccasions.length + (canAddCustomOccasion ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < availableOccasions.length) {
                        return _buildOccasionCard(availableOccasions[index]);
                      } else {
                        return _buildCustomOccasionCard();
                      }
                    },
                  ),

                  // رسالة ترقية للباقة المجانية
                  if (widget.packageType == PackageType.free) ...[
                    const SizedBox(height: 24),
                    _buildUpgradePrompt(),
                  ],
                ],
              ),
            ),
          ),

          // أزرار التنقل
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('السابق'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade400,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _canProceed() ? _proceedToNext : null,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('التالي'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getPackageColor(),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOccasionCard(Map<String, String> occasion) {
    final isSelected = selectedOccasion == occasion["name"];
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              selectedOccasion = occasion["name"];
              otherController.clear();
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? _getPackageColor() : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected 
                    ? _getPackageColor() 
                    : Colors.grey.shade300,
                width: isSelected ? 3 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected 
                      ? _getPackageColor().withOpacity(0.3)
                      : Colors.grey.withOpacity(0.1),
                  blurRadius: isSelected ? 12 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  occasion["icon"]!,
                  style: const TextStyle(fontSize: 40),
                ),
                const SizedBox(height: 12),
                Text(
                  occasion["name"]!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF2D3748),
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
                if (isSelected)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomOccasionCard() {
    final isSelected = selectedOccasion == 'مناسبة أخرى';
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              selectedOccasion = 'مناسبة أخرى';
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? _getPackageColor() : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected 
                    ? _getPackageColor() 
                    : Colors.grey.shade300,
                width: isSelected ? 3 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected 
                      ? _getPackageColor().withOpacity(0.3)
                      : Colors.grey.withOpacity(0.1),
                  blurRadius: isSelected ? 12 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.edit,
                  color: isSelected ? Colors.white : _getPackageColor(),
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  'مناسبة أخرى',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF2D3748),
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
                if (isSelected) ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: otherController,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'اكتب المناسبة',
                      hintStyle: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white70),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 4),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpgradePrompt() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF9F7AEA)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.star, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(
                'احصل على مناسبات أكثر!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'ترقي للباقة الفضية أو أعلى للحصول على:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '✨ جميع المناسبات (18+ مناسبة)\n'
            '✨ إضافة مناسبة مخصصة\n'
            '✨ مناسبات دينية ومواسم خاصة\n'
            '✨ مناسبات عائلية ومهنية',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/package-selection'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF6C63FF),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '⬆️ ترقية الباقة الآن',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPackageColor() {
    switch (widget.packageType) {
      case PackageType.free:
        return const Color(0xFF48BB78);
      case PackageType.silver:
        return const Color(0xFF718096);
      case PackageType.bronze:
        return const Color(0xFFED8936);
      case PackageType.gold:
        return const Color(0xFFECC94B);
    }
  }

  IconData _getPackageIcon() {
    switch (widget.packageType) {
      case PackageType.free:
        return Icons.free_breakfast;
      case PackageType.silver:
        return Icons.workspace_premium;
      case PackageType.bronze:
        return Icons.military_tech;
      case PackageType.gold:
        return Icons.diamond;
    }
  }

  String _getPackageTitle() {
    switch (widget.packageType) {
      case PackageType.free:
        return 'الباقة المجانية';
      case PackageType.silver:
        return 'الباقة الفضية';
      case PackageType.bronze:
        return 'الباقة البرونزية';
      case PackageType.gold:
        return 'الباقة الذهبية';
    }
  }

  bool _canProceed() {
    if (selectedOccasion == null) return false;
    
    if (selectedOccasion == 'مناسبة أخرى') {
      return otherController.text.trim().isNotEmpty;
    }
    
    return true;
  }

  void _proceedToNext() {
    String finalOccasion = selectedOccasion == 'مناسبة أخرى'
        ? otherController.text.trim()
        : selectedOccasion!;

    if (finalOccasion.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار أو إدخال مناسبة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // الانتقال للخطوة التالية حسب نوع الباقة
    if (widget.packageType == PackageType.free) {
      // للباقة المجانية: الانتقال لاختيار العلاقة
      Navigator.pushNamed(
        context,
        '/select-relationship',
        arguments: {
          'occasionType': finalOccasion,
        },
      );
    } else {
      // للباقات المدفوعة: الانتقال لصفحة اختيار العلاقة
      Navigator.pushNamed(
        context,
        '/select-relationship',
        arguments: {
          'occasion': finalOccasion,
          'packageType': widget.packageType,
        },
      );
    }
  }
}
