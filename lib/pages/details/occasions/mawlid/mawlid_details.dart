import 'package:hediya_ghaliya/models/gift.dart';
import 'package:hediya_ghaliya/services/pages_template.dart';

/// توليد صفحات مناسبة "المولد النبوي"
List<Map<String, dynamic>> generateMawlidPages(Gift g) {
  final senderName = g.senderName?.trim().isEmpty == true ? 'محبكم' : (g.senderName ?? 'محبكم');
  final recipientName = g.recipientName?.trim().isEmpty == true ? 'أحبتنا' : (g.recipientName ?? 'أحبتنا');

  return [
    pageSpec(
      id: 'cover_mawlid_1',
      type: 'cover',
      title: 'الغلاف',
      blocks: [
        textBlock('المولد النبوي الشريف', style: const {'align': 'center', 'size': 24, 'weight': 'bold'}),
        textBlock('إلى $recipientName', style: const {'align': 'center', 'size': 18}),
        textBlock('من: $senderName', style: const {'align': 'center', 'size': 14}),
      ],
    ),
    pageSpec(
      id: 'dedication_mawlid_1',
      type: 'dedication',
      title: 'الإهداء',
      blocks: [
        quoteBlock('صلِّ على النبي محمد وآله وصحبه وسلم.'),
      ],
    ),
    pageSpec(
      id: 'message_mawlid_1',
      type: 'message',
      title: 'رسالة',
      blocks: [
        textBlock('نهنئكم بهذه المناسبة العطرة، ونسأل الله لكم الخير.'),
      ],
    ),
    pageSpec(
      id: 'photos_mawlid_1',
      type: 'photos',
      title: 'صور',
      blocks: [
        imageBlock(''),
        imageBlock(''),
      ],
    ),
  ];
}
