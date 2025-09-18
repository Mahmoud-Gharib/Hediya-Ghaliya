import 'package:hediya_ghaliya/models/gift.dart';
import 'package:hediya_ghaliya/services/pages_template.dart';

/// توليد صفحات مناسبة "رمضان"
List<Map<String, dynamic>> generateRamadanPages(Gift g) {
  final senderName = g.senderName?.trim().isEmpty == true ? 'محبكم' : (g.senderName ?? 'محبكم');
  final recipientName = g.recipientName?.trim().isEmpty == true ? 'أحبتنا' : (g.recipientName ?? 'أحبتنا');

  return [
    pageSpec(
      id: 'cover_ramadan_1',
      type: 'cover',
      title: 'الغلاف',
      blocks: [
        textBlock('رمضان كريم', style: const {'align': 'center', 'size': 28, 'weight': 'bold'}),
        textBlock('إلى $recipientName', style: const {'align': 'center', 'size': 20}),
        textBlock('من: $senderName', style: const {'align': 'center', 'size': 14}),
      ],
    ),
    pageSpec(
      id: 'dedication_ramadan_1',
      type: 'dedication',
      title: 'الإهداء',
      blocks: [
        quoteBlock('بلغنا الله وإياكم رمضان أعوامًا عديدة وأزمنة مديدة.'),
      ],
    ),
    pageSpec(
      id: 'message_ramadan_1',
      type: 'message',
      title: 'رسالة',
      blocks: [
        textBlock('نسأل الله لكم صيامًا مقبولًا وذنبًا مغفورًا.'),
      ],
    ),
    pageSpec(
      id: 'photos_ramadan_1',
      type: 'photos',
      title: 'صور',
      blocks: [
        imageBlock(''),
        imageBlock(''),
      ],
    ),
  ];
}
