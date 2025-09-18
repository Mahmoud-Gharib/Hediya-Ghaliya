import 'package:flutter/material.dart';
import '../models/package.dart';

/// صفحة اختيار باقة "هدية غالية" 📦
class PackageSelectionPage extends StatefulWidget {
  const PackageSelectionPage({super.key});

  @override
  State<PackageSelectionPage> createState() => _PackageSelectionPageState();
}

class _PackageSelectionPageState extends State<PackageSelectionPage> {
  PackageType? selectedPackage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          '📦 باقات هدية غالية',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عنوان رئيسي
            const Center(
              child: Text(
                'اختر الباقة المناسبة لهديتك 🎁',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'كل باقة مصممة خصيصاً لتناسب احتياجاتك',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF718096),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),

            // عرض الباقات
            ...GiftPackage.packages.map((package) => 
              _buildPackageCard(package)).toList(),

            const SizedBox(height: 32),

            // زر المتابعة
            if (selectedPackage != null)
              Container(
                width: double.infinity,
                height: 56,
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
                child: ElevatedButton(
                  onPressed: () => _proceedWithPackage(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'متابعة إنشاء الهدية 🚀',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageCard(GiftPackage package) {
    final isSelected = selectedPackage == package.type;
    final isRecommended = package.type == PackageType.bronze;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Stack(
        children: [
          // الكارت الرئيسي
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected 
                    ? const Color(0xFF6C63FF) 
                    : Colors.grey.shade200,
                width: isSelected ? 3 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected 
                      ? const Color(0xFF6C63FF).withOpacity(0.2)
                      : Colors.grey.withOpacity(0.1),
                  blurRadius: isSelected ? 20 : 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => selectedPackage = package.type),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // رأس الباقة
                      Row(
                        children: [
                          // أيقونة الباقة
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: _getPackageGradient(package.type),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                package.emoji,
                                style: const TextStyle(fontSize: 28),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          
                          // اسم وسعر الباقة
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  package.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2D3748),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  package.goal,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF718096),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // السعر
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (package.price == 0)
                                const Text(
                                  'مجاني',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF48BB78),
                                  ),
                                )
                              else
                                Text(
                                  '${package.price.toInt()}ج',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6C63FF),
                                  ),
                                ),
                              const Text(
                                'مرة واحدة',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF718096),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // المميزات
                      _buildFeaturesList(package.features),
                      
                      // القيود (إن وجدت)
                      if (package.limitations.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildLimitationsList(package.limitations),
                      ],
                      
                      const SizedBox(height: 16),
                      
                      // الاستخدام الأمثل
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getPackageColor(package.type).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '👌 الاستخدام الأمثل:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              package.optimalUse,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF4A5568),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // شارة "الأكثر شعبية"
          if (isRecommended)
            Positioned(
              top: -8,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFED8936), Color(0xFFDD6B20)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFED8936).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  '🔥 الأكثر شعبية',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          
          // علامة الاختيار
          if (isSelected)
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C63FF).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeaturesList(List<String> features) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: features.map((feature) {
        if (feature.isEmpty) return const SizedBox(height: 4);
        
        if (feature.startsWith('✨')) {
          return Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Text(
              feature,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6C63FF),
              ),
            ),
          );
        }
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 4, right: 16),
          child: Text(
            feature,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF4A5568),
              height: 1.4,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLimitationsList(List<String> limitations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'القيود:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE53E3E),
          ),
        ),
        const SizedBox(height: 4),
        ...limitations.map((limitation) => Padding(
          padding: const EdgeInsets.only(bottom: 2, right: 8),
          child: Text(
            limitation,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFFE53E3E),
            ),
          ),
        )).toList(),
      ],
    );
  }

  LinearGradient _getPackageGradient(PackageType type) {
    switch (type) {
      case PackageType.free:
        return const LinearGradient(
          colors: [Color(0xFF48BB78), Color(0xFF38A169)],
        );
      case PackageType.silver:
        return const LinearGradient(
          colors: [Color(0xFF718096), Color(0xFF4A5568)],
        );
      case PackageType.bronze:
        return const LinearGradient(
          colors: [Color(0xFFED8936), Color(0xFFDD6B20)],
        );
      case PackageType.gold:
        return const LinearGradient(
          colors: [Color(0xFFECC94B), Color(0xFFD69E2E)],
        );
    }
  }

  Color _getPackageColor(PackageType type) {
    switch (type) {
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

  void _proceedWithPackage() {
    if (selectedPackage == null) return;
    
    final selectedPkg = GiftPackage.getPackage(selectedPackage!);
    
    // إظهار تأكيد الاختيار
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Text(selectedPkg.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'تأكيد اختيار ${selectedPkg.name}',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'هل أنت متأكد من اختيار ${selectedPkg.name}؟',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            if (selectedPkg.price > 0)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'سيتم تحصيل ${selectedPkg.price.toInt()} جنيه مقابل هذه الباقة',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToGiftCreation(selectedPkg);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'تأكيد',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToGiftCreation(GiftPackage package) {
    // الانتقال لصفحة إنشاء الهدية مع الباقة المختارة
    Navigator.pushNamed(
      context,
      '/create-gift',
      arguments: package,
    );
  }
}
