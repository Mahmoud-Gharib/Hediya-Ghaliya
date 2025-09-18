import 'package:hediya_ghaliya/models/gift.dart';
import 'package:hediya_ghaliya/services/pages_template.dart';

/// توليد صفحات مناسبة "عيد الأم" وفق علاقة المرسل والمستلم
List<Map<String, dynamic>> generateMothersDayPages(Gift g) {
  final senderName = g.senderName?.trim().isEmpty == true ? 'محبوبك' : (g.senderName ?? 'محبوبك');
  final recipientName = g.recipientName?.trim().isEmpty == true ? 'أمي' : (g.recipientName ?? 'أمي');
  final relation = g.senderRelation ?? '';

  String dedication;
  switch (relation) {
    case 'ابن':
      dedication = 'إلى أمي الغالية، كل عام وأنتِ نور قلبي وسر سعادتي.';
      break;
    case 'ابنة':
      dedication = 'إلى أمي الحنونة، شكراً لحبك الذي لا ينتهي.';
      break;
    case 'زوج':
      dedication = 'إلى حماتي العزيزة، أم زوجتي، كل الامتنان لطيبتك وعطائك.';
      break;
    case 'زوجة':
      dedication = 'إلى حماتي الغالية، أم زوجي، كل عام وأنتِ بخير وبركة.';
      break;
    default:
      dedication = 'كل عام وأنتِ بخير يا أمي.';
  }

  return [
    pageSpec(
      id: 'cover_1',
      type: 'cover',
      title: 'الغلاف',
      blocks: [
        textBlock('عيد الأم', style: const {'align': 'center', 'size': 28, 'weight': 'bold'}),
        textBlock('إلى $recipientName', style: const {'align': 'center', 'size': 20}),
        textBlock('من: $senderName', style: const {'align': 'center', 'size': 14}),
      ],
    ),
    pageSpec(
      id: 'dedication_1',
      type: 'dedication',
      title: 'الإهداء',
      blocks: [
        quoteBlock(dedication),
      ],
    ),
    pageSpec(
      id: 'message_1',
      type: 'message',
      title: 'رسالة',
      blocks: [
        textBlock(
          'أمي العزيزة، في هذا اليوم أحب أن أقول لكِ: أنتِ مصدر الإلهام والقوة في حياتي.\n'
          'شكرًا على كل لحظة حب واهتمام. كل عام وأنتِ الأقرب إلى قلبي.'
        ),
      ],
    ),
    pageSpec(
      id: 'photos_1',
      type: 'photos',
      title: 'صور',
      blocks: [
        imageBlock(''),
        imageBlock(''),
      ],
    ),
  ];
}
