import 'package:hediya_ghaliya/models/gift.dart';
import 'package:hediya_ghaliya/services/pages_template.dart';

/// توليد صفحات مناسبة "عمرة"
List<Map<String, dynamic>> generateUmrahPages(Gift g) {
  final senderName = g.senderName?.trim().isEmpty == true ? 'محبكم' : (g.senderName ?? 'محبكم');
  final recipientName = g.recipientName?.trim().isEmpty == true ? 'المعتمر/المعتمرة' : (g.recipientName ?? 'المعتمر/المعتمرة');

  return [
    pageSpec(
      id: 'cover_umrah_1',
      type: 'cover',
      title: 'الغلاف',
      blocks: [
        textBlock('عمرة مقبولة وذنب مغفور', style: const {'align': 'center', 'size': 24, 'weight': 'bold'}),
        textBlock('إلى $recipientName', style: const {'align': 'center', 'size': 18}),
        textBlock('من: $senderName', style: const {'align': 'center', 'size': 14}),
      ],
    ),
    pageSpec(
      id: 'dedication_umrah_1',
      type: 'dedication',
      title: 'الإهداء',
      blocks: [
        quoteBlock('زادكم الله قربًا وطاعة.'),
      ],
    ),
    pageSpec(
      id: 'message_umrah_1',
      type: 'message',
      title: 'رسالة',
      blocks: [
        textBlock('نسأل الله لكم القبول والتيسير.'),
      ],
    ),
    pageSpec(
      id: 'photos_umrah_1',
      type: 'photos',
      title: 'صور',
      blocks: [
        imageBlock(''),
        imageBlock(''),
      ],
    ),
  ];
}
