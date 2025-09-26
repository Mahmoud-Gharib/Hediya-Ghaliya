import '../models/gift.dart';

/// صفحة ككائن خفيف (نستخدم الخرائط لتسهيل التخزين داخل Gift.details)
Map<String, dynamic> pageSpec({
  required String id,
  required String type,
  required String title,
  required List<Map<String, dynamic>> blocks,
}) => {
  'id': id,
  'type': type,
  'title': title,
  'blocks': blocks,
};

Map<String, dynamic> textBlock(String content, {Map<String, dynamic>? style}) => {
  'type': 'text',
  'content': content,
  'style': style ?? const {'align': 'center', 'size': 18, 'weight': 'normal'},
};

Map<String, dynamic> quoteBlock(String content, {Map<String, dynamic>? style}) => {
  'type': 'quote',
  'content': content,
  'style': style ?? const {'align': 'center', 'size': 16},
};

Map<String, dynamic> imageBlock(String urlOrPath, {Map<String, dynamic>? style}) => {
  'type': 'image',
  'content': urlOrPath,
  'style': style ?? const {'fit': 'cover'},
};

/// قالب افتراضي ثابت لجميع المناسبات (مؤقتًا)
List<Map<String, dynamic>> generateDefaultPages(Gift g) {
  final senderName = g.senderName?.trim().isEmpty == true ? 'محبوبك' : (g.senderName ?? 'محبوبك');
  final recipientName = g.recipientName?.trim().isEmpty == true ? 'عزيزتي/عزيزي' : (g.recipientName ?? 'عزيزتي/عزيزي');
  final occ = g.occasion ?? 'مناسبة سعيدة';

  return [
    pageSpec(
      id: 'cover_1',
      type: 'cover',
      title: 'الغلاف',
      blocks: [
        textBlock(occ, style: const {'align': 'center', 'size': 28, 'weight': 'bold'}),
        textBlock('إلى $recipientName', style: const {'align': 'center', 'size': 20}),
        textBlock('من: $senderName', style: const {'align': 'center', 'size': 14}),
      ],
    ),
    pageSpec(
      id: 'dedication_1',
      type: 'dedication',
      title: 'الإهداء',
      blocks: [
        quoteBlock('كل عام وأنت بخير.. أهديك هذه الكلمات محبة وتقديرًا.'),
      ],
    ),
    pageSpec(
      id: 'message_1',
      type: 'message',
      title: 'رسالة',
      blocks: [
        textBlock(
          'في هذه المناسبة الجميلة، أتمنى لك أيامًا سعيدة مليئة بالمحبة والنجاح.\n'
          'وجودك في حياتي نعمة كبيرة.'
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

/// مولّد عام يختار القالب حسب المناسبة كما في create_gift_page.dart
List<Map<String, dynamic>> generatePagesForGift(Gift g) {
  switch (g.occasion) {
    case 'عيد الأم':
    case 'عيد ميلاد':
    case 'تخرج':
    case 'عيد الحب':
    case 'عيد الأضحى':
    case 'عيد الفطر':
    case 'رمضان':
    case 'المولد النبوي':
    case 'حج':
    case 'عمرة':
    case 'زواج':
    case 'خطوبة':
    case 'رأس السنة':
    case 'دعم نفسي':
    case 'تشجيع':
    case 'أخرى':
      return generateDefaultPages(g);
    default:
      return generateDefaultPages(g);
  }
}
