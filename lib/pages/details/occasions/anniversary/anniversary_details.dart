import 'package:hediya_ghaliya/models/gift.dart';
import 'package:hediya_ghaliya/services/pages_template.dart';

/// توليد صفحات مناسبة "عيد الزواج"
List<Map<String, dynamic>> generateAnniversaryPages(Gift g) {
  final senderName = g.senderName?.trim().isEmpty == true ? 'محبوبك' : (g.senderName ?? 'محبوبك');
  final recipientName = g.recipientName?.trim().isEmpty == true ? 'حبيبي/حبيبتي' : (g.recipientName ?? 'حبيبي/حبيبتي');

  return [
    pageSpec(
      id: 'cover_anniversary_1',
      type: 'cover',
      title: 'الغلاف',
      blocks: [
        textBlock('عيد زواج سعيد', style: const {'align': 'center', 'size': 28, 'weight': 'bold'}),
        textBlock('إلى $recipientName', style: const {'align': 'center', 'size': 20}),
        textBlock('من: $senderName', style: const {'align': 'center', 'size': 14}),
      ],
    ),
    pageSpec(
      id: 'dedication_anniversary_1',
      type: 'dedication',
      title: 'الإهداء',
      blocks: [
        quoteBlock('معك يكتمل العمر حبًا ودفئًا، كل عام ونحن أقرب.'),
      ],
    ),
    pageSpec(
      id: 'message_anniversary_1',
      type: 'message',
      title: 'رسالة',
      blocks: [
        textBlock(
          'سنوات من الحب والمشاركة تجعلني ممتنًا لكل لحظة معك.\n'
          'لأيامنا القادمة مزيد من الفرح والسكينة.'
        ),
      ],
    ),
    pageSpec(
      id: 'photos_anniversary_1',
      type: 'photos',
      title: 'صور',
      blocks: [
        imageBlock(''),
        imageBlock(''),
      ],
    ),
  ];
}
