import 'package:hediya_ghaliya/models/gift.dart';
import 'package:hediya_ghaliya/services/pages_template.dart';

/// توليد صفحات مناسبة "أخرى" (قالب عام)
List<Map<String, dynamic>> generateOtherPages(Gift g) {
  final senderName = g.senderName?.trim().isEmpty == true ? 'محبك' : (g.senderName ?? 'محبك');
  final recipientName = g.recipientName?.trim().isEmpty == true ? 'عزيزي/عزيزتي' : (g.recipientName ?? 'عزيزي/عزيزتي');

  return [
    pageSpec(
      id: 'cover_other_1',
      type: 'cover',
      title: 'الغلاف',
      blocks: [
        textBlock('إهداء خاص', style: const {'align': 'center', 'size': 24, 'weight': 'bold'}),
        textBlock('إلى $recipientName', style: const {'align': 'center', 'size': 18}),
        textBlock('من: $senderName', style: const {'align': 'center', 'size': 14}),
      ],
    ),
    pageSpec(
      id: 'dedication_other_1',
      type: 'dedication',
      title: 'الإهداء',
      blocks: [
        quoteBlock('لك مكانة خاصة في القلب.'),
      ],
    ),
    pageSpec(
      id: 'message_other_1',
      type: 'message',
      title: 'رسالة',
      blocks: [
        textBlock('رسالة من القلب تناسب هذه المناسبة الخاصة.'),
      ],
    ),
    pageSpec(
      id: 'photos_other_1',
      type: 'photos',
      title: 'صور',
      blocks: [
        imageBlock(''),
        imageBlock(''),
      ],
    ),
  ];
}
