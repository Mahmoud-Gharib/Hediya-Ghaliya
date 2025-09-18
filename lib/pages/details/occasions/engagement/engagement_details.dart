import 'package:hediya_ghaliya/models/gift.dart';
import 'package:hediya_ghaliya/services/pages_template.dart';

/// توليد صفحات مناسبة "خطوبة"
List<Map<String, dynamic>> generateEngagementPages(Gift g) {
  final senderName = g.senderName?.trim().isEmpty == true ? 'محبوك/محبتك' : (g.senderName ?? 'محبوك/محبتك');
  final recipientName = g.recipientName?.trim().isEmpty == true ? 'الخطيب/الخطيبة' : (g.recipientName ?? 'الخطيب/الخطيبة');

  return [
    pageSpec(
      id: 'cover_engagement_1',
      type: 'cover',
      title: 'الغلاف',
      blocks: [
        textBlock('مبارك الخطوبة', style: const {'align': 'center', 'size': 26, 'weight': 'bold'}),
        textBlock('إلى $recipientName', style: const {'align': 'center', 'size': 18}),
        textBlock('من: $senderName', style: const {'align': 'center', 'size': 14}),
      ],
    ),
    pageSpec(
      id: 'dedication_engagement_1',
      type: 'dedication',
      title: 'الإهداء',
      blocks: [
        quoteBlock('جعلها الله بداية حياة سعيدة.'),
      ],
    ),
    pageSpec(
      id: 'message_engagement_1',
      type: 'message',
      title: 'رسالة',
      blocks: [
        textBlock('خطوة مباركة نحو بيت عامر بالمودة والرحمة.'),
      ],
    ),
    pageSpec(
      id: 'photos_engagement_1',
      type: 'photos',
      title: 'صور',
      blocks: [
        imageBlock(''),
        imageBlock(''),
      ],
    ),
  ];
}
