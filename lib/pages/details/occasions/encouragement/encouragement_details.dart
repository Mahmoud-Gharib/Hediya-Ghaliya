import 'package:hediya_ghaliya/models/gift.dart';
import 'package:hediya_ghaliya/services/pages_template.dart';

/// توليد صفحات مناسبة "تشجيع"
List<Map<String, dynamic>> generateEncouragementPages(Gift g) {
  final senderName = g.senderName?.trim().isEmpty == true ? 'محبك' : (g.senderName ?? 'محبك');
  final recipientName = g.recipientName?.trim().isEmpty == true ? 'عزيزي/عزيزتي' : (g.recipientName ?? 'عزيزي/عزيزتي');

  return [
    pageSpec(
      id: 'cover_encouragement_1',
      type: 'cover',
      title: 'الغلاف',
      blocks: [
        textBlock('أنت قدها', style: const {'align': 'center', 'size': 26, 'weight': 'bold'}),
        textBlock('إلى $recipientName', style: const {'align': 'center', 'size': 18}),
        textBlock('من: $senderName', style: const {'align': 'center', 'size': 14}),
      ],
    ),
    pageSpec(
      id: 'dedication_encouragement_1',
      type: 'dedication',
      title: 'الإهداء',
      blocks: [
        quoteBlock('خطوة بخطوة ستصل.'),
      ],
    ),
    pageSpec(
      id: 'message_encouragement_1',
      type: 'message',
      title: 'رسالة',
      blocks: [
        textBlock('كل مجهود تبذله يقربك من هدفك، استمر!'),
      ],
    ),
    pageSpec(
      id: 'photos_encouragement_1',
      type: 'photos',
      title: 'صور',
      blocks: [
        imageBlock(''),
        imageBlock(''),
      ],
    ),
  ];
}
