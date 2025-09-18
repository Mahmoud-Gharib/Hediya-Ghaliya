import 'package:hediya_ghaliya/models/gift.dart';
import 'package:hediya_ghaliya/services/pages_template.dart';

/// توليد صفحات مناسبة "عيد الميلاد"
List<Map<String, dynamic>> generateBirthdayPages(Gift g) {
  final senderName = g.senderName?.trim().isEmpty == true ? 'محبوبك' : (g.senderName ?? 'محبوبك');
  final recipientName = g.recipientName?.trim().isEmpty == true ? 'صاحب العيد' : (g.recipientName ?? 'صاحب العيد');

  return [
    pageSpec(
      id: 'cover_birthday_1',
      type: 'cover',
      title: 'الغلاف',
      blocks: [
        textBlock('عيد ميلاد سعيد', style: const {'align': 'center', 'size': 28, 'weight': 'bold'}),
        textBlock('إلى $recipientName', style: const {'align': 'center', 'size': 20}),
        textBlock('من: $senderName', style: const {'align': 'center', 'size': 14}),
      ],
    ),
    pageSpec(
      id: 'dedication_birthday_1',
      type: 'dedication',
      title: 'الإهداء',
      blocks: [
        quoteBlock('كل عام وأنت بخير وسعادة وتحقيق للأماني!'),
      ],
    ),
    pageSpec(
      id: 'message_birthday_1',
      type: 'message',
      title: 'رسالة',
      blocks: [
        textBlock(
          'في هذا اليوم المميز، أتمنى لك عامًا مليئًا بالفرح والنجاح.\n'
          'شكرًا لوجودك الجميل في حياتي.'
        ),
      ],
    ),
    pageSpec(
      id: 'photos_birthday_1',
      type: 'photos',
      title: 'صور',
      blocks: [
        imageBlock(''),
        imageBlock(''),
      ],
    ),
  ];
}
