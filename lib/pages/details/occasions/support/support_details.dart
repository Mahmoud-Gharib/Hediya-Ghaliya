import 'package:hediya_ghaliya/models/gift.dart';
import 'package:hediya_ghaliya/services/pages_template.dart';

/// توليد صفحات مناسبة "دعم نفسي"
List<Map<String, dynamic>> generateSupportPages(Gift g) {
  final senderName = g.senderName?.trim().isEmpty == true ? 'محبك' : (g.senderName ?? 'محبك');
  final recipientName = g.recipientName?.trim().isEmpty == true ? 'عزيزي/عزيزتي' : (g.recipientName ?? 'عزيزي/عزيزتي');

  return [
    pageSpec(
      id: 'cover_support_1',
      type: 'cover',
      title: 'الغلاف',
      blocks: [
        textBlock('قلبي معك', style: const {'align': 'center', 'size': 26, 'weight': 'bold'}),
        textBlock('إلى $recipientName', style: const {'align': 'center', 'size': 18}),
        textBlock('من: $senderName', style: const {'align': 'center', 'size': 14}),
      ],
    ),
    pageSpec(
      id: 'dedication_support_1',
      type: 'dedication',
      title: 'الإهداء',
      blocks: [
        quoteBlock('أنا هنا من أجلك، لست وحدك.'),
      ],
    ),
    pageSpec(
      id: 'message_support_1',
      type: 'message',
      title: 'رسالة',
      blocks: [
        textBlock('كل عثرة تليها نهضة. أثق بقوتك وقدرتك على تجاوز الصعاب.'),
      ],
    ),
    pageSpec(
      id: 'photos_support_1',
      type: 'photos',
      title: 'صور',
      blocks: [
        imageBlock(''),
        imageBlock(''),
      ],
    ),
  ];
}
