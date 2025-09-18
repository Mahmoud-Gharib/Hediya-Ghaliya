import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/gift.dart';

class GiftSummaryPage extends StatelessWidget {
  final Gift gift;
  const GiftSummaryPage({super.key, required this.gift});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ملخص الهدية', style: TextStyle(fontWeight: FontWeight.w800)),
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
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _glass(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(gift.title?.isNotEmpty == true ? gift.title! : 'بدون عنوان',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                      const SizedBox(height: 6),
                      Text(gift.message?.isNotEmpty == true ? gift.message! : '— لا توجد رسالة —',
                          style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _chip('المناسبة: ${gift.occasion ?? '-'}'),
                          _chip('المرسل: ${gift.senderName ?? '-'}${gift.senderRelation != null ? ' (${gift.senderRelation})' : ''}') ,
                          _chip('المُرسل إليه: ${gift.recipientName ?? '-'}${gift.recipientRelation != null ? ' (${gift.recipientRelation})' : ''}'),
                          if (gift.deliveryAt != null) _chip('التاريخ: ${gift.deliveryAt!.toLocal().toString().split(' ').first}'),
                          _chip('الثيم: ${gift.themeId ?? 'classic'}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (gift.details != null && gift.details!.isNotEmpty)
                        _chip('تفاصيل: ${gift.details!['type'] ?? '—'}'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _glass(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('الإجراءات', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final json = gift.toJson();
                          await Clipboard.setData(ClipboardData(text: json));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('تم نسخ JSON إلى الحافظة')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8E24AA)),
                        icon: const Icon(Icons.copy, color: Colors.white),
                        label: const Text('نسخ بيانات الهدية JSON', style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.edit, color: Colors.white),
                        label: const Text('رجوع للتعديل', style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/home');
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6F61)),
                        icon: const Icon(Icons.check_circle, color: Colors.white),
                        label: const Text('إنهاء والرجوع للرئيسية', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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

  Widget _chip(String text) {
    return Chip(
      label: Text(text),
      backgroundColor: Colors.white24,
      side: BorderSide.none,
      labelStyle: const TextStyle(color: Colors.white),
    );
  }
}
