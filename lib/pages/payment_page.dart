import 'package:flutter/material.dart';
import '../models/package.dart';
import '../services/package_service.dart';

class PaymentPage extends StatefulWidget {
  final PackageType selectedPackage;
  
  const PaymentPage({super.key, required this.selectedPackage});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _isProcessing = false;
  String _selectedPaymentMethod = 'card';

  @override
  Widget build(BuildContext context) {
    final package = GiftPackage.getPackage(widget.selectedPackage);
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إتمام الدفع', style: TextStyle(fontWeight: FontWeight.w800)),
          centerTitle: true,
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // معلومات الباقة
                  _buildPackageInfo(package),
                  const SizedBox(height: 24),
                  
                  // طرق الدفع
                  _buildPaymentMethods(),
                  const SizedBox(height: 24),
                  
                  // ملخص الدفع
                  _buildPaymentSummary(package),
                  
                  const Spacer(),
                  
                  // زر الدفع
                  _buildPaymentButton(package),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPackageInfo(GiftPackage package) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                package.emoji,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      package.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      package.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${package.price.toInt()} جنيه',
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: package.features.take(5).map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feature,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'طريقة الدفع',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildPaymentMethodOption(
            'card',
            'بطاقة ائتمان/خصم',
            Icons.credit_card,
          ),
          _buildPaymentMethodOption(
            'wallet',
            'محفظة إلكترونية',
            Icons.account_balance_wallet,
          ),
          _buildPaymentMethodOption(
            'bank',
            'تحويل بنكي',
            Icons.account_balance,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodOption(String value, String title, IconData icon) {
    return RadioListTile<String>(
      value: value,
      groupValue: _selectedPaymentMethod,
      onChanged: (v) => setState(() => _selectedPaymentMethod = v!),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      secondary: Icon(icon, color: Colors.white70),
      activeColor: Colors.amber,
    );
  }

  Widget _buildPaymentSummary(GiftPackage package) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('سعر الباقة:', style: TextStyle(color: Colors.white70)),
              Text('${package.price.toInt()} جنيه', style: const TextStyle(color: Colors.white)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('مدة الاشتراك:', style: TextStyle(color: Colors.white70)),
              const Text('30 يوم', style: TextStyle(color: Colors.white)),
            ],
          ),
          const Divider(color: Colors.white24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('المجموع:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text('${package.price.toInt()} جنيه', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentButton(GiftPackage package) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : () => _processPayment(package),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isProcessing
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  ),
                  SizedBox(width: 12),
                  Text('جاري المعالجة...', style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              )
            : Text(
                'ادفع ${package.price.toInt()} جنيه',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Future<void> _processPayment(GiftPackage package) async {
    setState(() => _isProcessing = true);
    
    try {
      // محاكاة عملية الدفع
      final result = await PackageService.processPayment(package.type);
      
      if (result.success && mounted) {
        // إظهار رسالة نجاح
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 32),
                  SizedBox(width: 12),
                  Text('تم الدفع بنجاح!'),
                ],
              ),
              content: Text(result.message),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // إغلاق الحوار
                    Navigator.pop(context, true); // العودة مع نتيجة النجاح
                  },
                  child: const Text('متابعة'),
                ),
              ],
            ),
          ),
        );
      } else if (mounted) {
        // إظهار رسالة فشل
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في عملية الدفع: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}
