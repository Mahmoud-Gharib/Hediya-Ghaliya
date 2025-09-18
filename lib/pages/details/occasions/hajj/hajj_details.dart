import 'package:hediya_ghaliya/models/gift.dart';
import 'package:hediya_ghaliya/services/pages_template.dart';

/// توليد صفحات مناسبة "حج"
List<Map<String, dynamic>> generateHajjPages(Gift g) {
  final senderName = g.senderName?.trim().isEmpty == true ? 'محبكم' : (g.senderName ?? 'محبكم');
  final recipientName = g.recipientName?.trim().isEmpty == true ? 'الحاج/الحاجة' : (g.recipientName ?? 'الحاج/الحاجة');

  return [
    pageSpec(
      id: 'cover_hajj_1',
      type: 'cover',
      title: 'الغلاف',
      blocks: [
        textBlock('حج مبرور وسعي مشكور', style: const {'align': 'center', 'size': 24, 'weight': 'bold'}),
        textBlock('إلى $recipientName', style: const {'align': 'center', 'size': 18}),
        textBlock('من: $senderName', style: const {'align': 'center', 'size': 14}),
      ],
    ),
    pageSpec(
      id: 'dedication_hajj_1',
      type: 'dedication',
      title: 'الإهداء',
      blocks: [
        quoteBlock('تقبل الله طاعتكم وأعادكم سالمين غانمين.'),
      ],
    ),
    pageSpec(
      id: 'message_hajj_1',
      type: 'message',
      title: 'رسالة',
      blocks: [
        textBlock('نسأل الله لكم القبول والرضا.'),
      ],
    ),
    pageSpec(
      id: 'photos_hajj_1',
      type: 'photos',
      title: 'صور',
      blocks: [
        imageBlock(''),
        imageBlock(''),
      ],
    ),
  ];
}
