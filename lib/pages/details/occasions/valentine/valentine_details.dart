import 'package:hediya_ghaliya/models/gift.dart';
import 'package:hediya_ghaliya/services/pages_template.dart';

/// توليد صفحات مناسبة "عيد الحب"
List<Map<String, dynamic>> generateValentinePages(Gift g) {
  final senderName = g.senderName?.trim().isEmpty == true ? 'محبوبك' : (g.senderName ?? 'محبوبك');
  final recipientName = g.recipientName?.trim().isEmpty == true ? 'حبيبي/حبيبتي' : (g.recipientName ?? 'حبيبي/حبيبتي');

  return [
    pageSpec(
      id: 'cover_valentine_1',
      type: 'cover',
      title: 'الغلاف',
      blocks: [
        textBlock('عيد حب سعيد', style: const {'align': 'center', 'size': 28, 'weight': 'bold'}),
        textBlock('إلى $recipientName', style: const {'align': 'center', 'size': 20}),
        textBlock('من: $senderName', style: const {'align': 'center', 'size': 14}),
      ],
    ),
    pageSpec(
      id: 'dedication_valentine_1',
      type: 'dedication',
      title: 'الإهداء',
      blocks: [
        quoteBlock('أحبك اليوم وغدًا وكل حين.'),
      ],
    ),
    pageSpec(
      id: 'message_valentine_1',
      type: 'message',
      title: 'رسالة',
      blocks: [
        textBlock('قلباي يجتمعان على نبض واحد، كل عام وأنت نبضي.'),
      ],
    ),
    pageSpec(
      id: 'photos_valentine_1',
      type: 'photos',
      title: 'صور',
      blocks: [
        imageBlock(''),
        imageBlock(''),
      ],
    ),
  ];
}
