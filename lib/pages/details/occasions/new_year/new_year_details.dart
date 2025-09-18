import 'package:hediya_ghaliya/models/gift.dart';
import 'package:hediya_ghaliya/services/pages_template.dart';

/// توليد صفحات مناسبة "رأس السنة"
List<Map<String, dynamic>> generateNewYearPages(Gift g) {
  final senderName = g.senderName?.trim().isEmpty == true ? 'محبوبك' : (g.senderName ?? 'محبوبك');
  final recipientName = g.recipientName?.trim().isEmpty == true ? 'صديقي/صديقتي' : (g.recipientName ?? 'صديقي/صديقتي');

  return [
    pageSpec(
      id: 'cover_new_year_1',
      type: 'cover',
      title: 'الغلاف',
      blocks: [
        textBlock('سنة جديدة سعيدة', style: const {'align': 'center', 'size': 26, 'weight': 'bold'}),
        textBlock('إلى $recipientName', style: const {'align': 'center', 'size': 20}),
        textBlock('من: $senderName', style: const {'align': 'center', 'size': 14}),
      ],
    ),
    pageSpec(
      id: 'dedication_new_year_1',
      type: 'dedication',
      title: 'الإهداء',
      blocks: [
        quoteBlock('عام جديد يملؤه الأمل والتفاؤل.'),
      ],
    ),
    pageSpec(
      id: 'message_new_year_1',
      type: 'message',
      title: 'رسالة',
      blocks: [
        textBlock('أتمنى لك عامًا مليئًا بالإنجازات والسعادة.'),
      ],
    ),
    pageSpec(
      id: 'photos_new_year_1',
      type: 'photos',
      title: 'صور',
      blocks: [
        imageBlock(''),
        imageBlock(''),
      ],
    ),
  ];
}
