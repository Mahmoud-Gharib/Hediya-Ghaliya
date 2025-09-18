import 'package:hediya_ghaliya/models/gift.dart';
import 'package:hediya_ghaliya/services/pages_template.dart';

/// توليد صفحات مناسبة "التخرج"
List<Map<String, dynamic>> generateGraduationPages(Gift g) {
  final senderName = g.senderName?.trim().isEmpty == true ? 'محبوك' : (g.senderName ?? 'محبوك');
  final recipientName = g.recipientName?.trim().isEmpty == true ? 'الخريج/الخريجة' : (g.recipientName ?? 'الخريج/الخريجة');

  return [
    pageSpec(
      id: 'cover_graduation_1',
      type: 'cover',
      title: 'الغلاف',
      blocks: [
        textBlock('مبارك التخرج', style: const {'align': 'center', 'size': 28, 'weight': 'bold'}),
        textBlock('إلى $recipientName', style: const {'align': 'center', 'size': 20}),
        textBlock('من: $senderName', style: const {'align': 'center', 'size': 14}),
      ],
    ),
    pageSpec(
      id: 'dedication_graduation_1',
      type: 'dedication',
      title: 'الإهداء',
      blocks: [
        quoteBlock('جهدك أثمر نجاحًا يليق بك، فخورون بك دائمًا!'),
      ],
    ),
    pageSpec(
      id: 'message_graduation_1',
      type: 'message',
      title: 'رسالة',
      blocks: [
        textBlock(
          'بداية مرحلة جديدة مليئة بالفرص.\n'
          'أمنياتي لك بالمزيد من التقدم والتميز.'
        ),
      ],
    ),
    pageSpec(
      id: 'photos_graduation_1',
      type: 'photos',
      title: 'صور',
      blocks: [
        imageBlock(''),
        imageBlock(''),
      ],
    ),
  ];
}
