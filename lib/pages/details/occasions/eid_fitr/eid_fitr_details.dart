import 'package:hediya_ghaliya/models/gift.dart';
import 'package:hediya_ghaliya/services/pages_template.dart';

/// توليد صفحات مناسبة "عيد الفطر"
List<Map<String, dynamic>> generateEidFitrPages(Gift g) {
  final senderName = g.senderName?.trim().isEmpty == true ? 'محبكم' : (g.senderName ?? 'محبكم');
  final recipientName = g.recipientName?.trim().isEmpty == true ? 'أحبتنا' : (g.recipientName ?? 'أحبتنا');

  return [
    pageSpec(
      id: 'cover_eid_fitr_1',
      type: 'cover',
      title: 'الغلاف',
      blocks: [
        textBlock('عيد فطر سعيد', style: const {'align': 'center', 'size': 28, 'weight': 'bold'}),
        textBlock('إلى $recipientName', style: const {'align': 'center', 'size': 20}),
        textBlock('من: $senderName', style: const {'align': 'center', 'size': 14}),
      ],
    ),
    pageSpec(
      id: 'dedication_eid_fitr_1',
      type: 'dedication',
      title: 'الإهداء',
      blocks: [
        quoteBlock('تقبل الله منا ومنكم، وكل عام وأنتم بخير.'),
      ],
    ),
    pageSpec(
      id: 'message_eid_fitr_1',
      type: 'message',
      title: 'رسالة',
      blocks: [
        textBlock('أسعد الله أيامكم بالخير والبركات.'),
      ],
    ),
    pageSpec(
      id: 'photos_eid_fitr_1',
      type: 'photos',
      title: 'صور',
      blocks: [
        imageBlock(''),
        imageBlock(''),
      ],
    ),
  ];
}
