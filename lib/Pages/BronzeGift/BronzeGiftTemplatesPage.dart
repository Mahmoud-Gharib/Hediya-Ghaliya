import 'package:flutter/material.dart';

class BronzeGiftTemplate {
  final String id;
  final String name;
  final String description;
  final Color primaryColor;
  final Color secondaryColor;
  final String backgroundPattern;
  final String icon;
  final List<String> features;

  BronzeGiftTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundPattern,
    required this.icon,
    required this.features,
  });
}

class BronzeGiftTemplatesPage extends StatefulWidget {
  static const routeName = '/bronze-gift-templates';
  const BronzeGiftTemplatesPage({super.key});

  @override
  State<BronzeGiftTemplatesPage> createState() => _BronzeGiftTemplatesPageState();
}

class _BronzeGiftTemplatesPageState extends State<BronzeGiftTemplatesPage>
    with TickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  String? selectedTemplateId;
  
  final List<BronzeGiftTemplate> templates = [
    BronzeGiftTemplate(
      id: 'premium_classic',
      name: 'كلاسيكي مميز',
      description: 'تصميم أنيق مع إطارات ذهبية وتأثيرات متقدمة',
      primaryColor: const Color(0xFFCD7F32),
      secondaryColor: const Color(0xFFD2691E),
      backgroundPattern: 'premium_classic',
      icon: '🎁',
      features: ['إطارات ذهبية', 'تأثيرات متحركة', '3 ملفات وسائط'],
    ),
    BronzeGiftTemplate(
      id: 'birthday_deluxe',
      name: 'عيد ميلاد فاخر',
      description: 'تصميم احتفالي مع موسيقى وتأثيرات خاصة',
      primaryColor: const Color(0xFFFF6347),
      secondaryColor: const Color(0xFFFFD700),
      backgroundPattern: 'birthday_deluxe',
      icon: '🎂',
      features: ['موسيقى خلفية', 'شموع متحركة', 'تسجيل صوتي'],
    ),
    BronzeGiftTemplate(
      id: 'romantic_bronze',
      name: 'رومانسي برونزي',
      description: 'تصميم رومانسي مع قلوب متحركة وألحان هادئة',
      primaryColor: const Color(0xFFDC143C),
      secondaryColor: const Color(0xFFFF1493),
      backgroundPattern: 'romantic_bronze',
      icon: '💖',
      features: ['قلوب متحركة', 'ألحان رومانسية', 'تأثيرات وردية'],
    ),
    BronzeGiftTemplate(
      id: 'friendship_premium',
      name: 'صداقة مميزة',
      description: 'تصميم دافئ للأصدقاء مع رموز الصداقة المتحركة',
      primaryColor: const Color(0xFF32CD32),
      secondaryColor: const Color(0xFF90EE90),
      backgroundPattern: 'friendship_premium',
      icon: '🤝',
      features: ['رموز صداقة متحركة', 'ألوان طبيعية', 'رسائل صوتية'],
    ),
    BronzeGiftTemplate(
      id: 'congratulations_bronze',
      name: 'تهنئة برونزية',
      description: 'تصميم احتفالي للإنجازات مع نجوم وألعاب نارية',
      primaryColor: const Color(0xFFFFD700),
      secondaryColor: const Color(0xFFFFA500),
      backgroundPattern: 'congratulations_bronze',
      icon: '🎉',
      features: ['ألعاب نارية', 'نجوم متحركة', 'أصوات احتفالية'],
    ),
    BronzeGiftTemplate(
      id: 'gratitude_premium',
      name: 'امتنان مميز',
      description: 'تصميم راقي للشكر مع تأثيرات هادئة ومريحة',
      primaryColor: const Color(0xFF708090),
      secondaryColor: const Color(0xFFB0C4DE),
      backgroundPattern: 'gratitude_premium',
      icon: '🙏',
      features: ['تأثيرات هادئة', 'ألوان مريحة', 'موسيقى تأملية'],
    ),
    BronzeGiftTemplate(
      id: 'graduation',
      name: 'تخرج',
      description: 'تصميم خاص للتخرج مع قبعات وشهادات متحركة',
      primaryColor: const Color(0xFF4169E1),
      secondaryColor: const Color(0xFF6495ED),
      backgroundPattern: 'graduation',
      icon: '🎓',
      features: ['قبعات تخرج', 'شهادات متحركة', 'موسيقى احتفالية'],
    ),
    BronzeGiftTemplate(
      id: 'wedding',
      name: 'زفاف',
      description: 'تصميم أنيق للأعراس مع خواتم وورود متحركة',
      primaryColor: const Color(0xFFFFB6C1),
      secondaryColor: const Color(0xFFFFC0CB),
      backgroundPattern: 'wedding',
      icon: '💍',
      features: ['خواتم متحركة', 'ورود متساقطة', 'موسيقى رومانسية'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('قوالب الهدية البرونزية', style: TextStyle(fontWeight: FontWeight.w800)),
          centerTitle: true,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFCD7F32),
                  Color(0xFFD2691E),
                  Color(0xFFFF6347),
                ],
              ),
            ),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFF8DC),
                Colors.white,
              ],
            ),
          ),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildTemplatesList(),
                  ),
                ),
              ),
              if (selectedTemplateId != null) _buildContinueButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFCD7F32).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('🥉', style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 12),
              const Text(
                'اختر القالب المناسب',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFCD7F32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'اختر من بين ${templates.length} قوالب برونزية مميزة',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFCD7F32).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              '25 ج.م • 3 ملفات وسائط • تسجيل صوتي • 30 يوم',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFFCD7F32),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplatesList() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final template = templates[index];
        final isSelected = selectedTemplateId == template.id;
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: GestureDetector(
            onTap: () => _selectTemplate(template.id),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected 
                      ? template.primaryColor 
                      : Colors.grey[300]!,
                  width: isSelected ? 3 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected 
                        ? template.primaryColor.withOpacity(0.2)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: isSelected ? 15 : 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // معاينة القالب
                  Expanded(
                    flex: 3,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            template.primaryColor,
                            template.secondaryColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          // نمط الخلفية
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(0.1),
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.1),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          // الأيقونة
                          Center(
                            child: Text(
                              template.icon,
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                          
                          // شارة البرونز
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('🥉', style: TextStyle(fontSize: 12)),
                            ),
                          ),
                          
                          // تأثير التحديد
                          if (isSelected)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.check,
                                  color: template.primaryColor,
                                  size: 16,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // معلومات القالب
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Text(
                          template.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: template.primaryColor,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          template.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 4,
                          runSpacing: 2,
                          children: template.features.take(2).map((feature) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: template.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              feature,
                              style: TextStyle(
                                fontSize: 10,
                                color: template.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContinueButton() {
    final selectedTemplate = templates.firstWhere(
      (template) => template.id == selectedTemplateId,
    );
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              selectedTemplate.primaryColor,
              selectedTemplate.secondaryColor,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: selectedTemplate.primaryColor.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _continueWithTemplate,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'متابعة مع ${selectedTemplate.name}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectTemplate(String templateId) {
    setState(() {
      selectedTemplateId = templateId;
    });
  }

  void _continueWithTemplate() {
    if (selectedTemplateId != null) {
      final selectedTemplate = templates.firstWhere(
        (template) => template.id == selectedTemplateId,
      );
      
      Navigator.pushNamed(
        context,
        '/bronze-gift-design',
        arguments: {
          'template': selectedTemplate,
        },
      );
    }
  }
}
