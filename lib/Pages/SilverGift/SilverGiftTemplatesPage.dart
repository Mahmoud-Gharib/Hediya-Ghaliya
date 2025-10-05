import 'package:flutter/material.dart';

class SilverGiftTemplate {
  final String id;
  final String name;
  final String description;
  final Color primaryColor;
  final Color secondaryColor;
  final String backgroundPattern;
  final String icon;
  final List<String> features;

  SilverGiftTemplate({
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

class SilverGiftTemplatesPage extends StatefulWidget {
  static const routeName = '/silver-gift-templates';
  const SilverGiftTemplatesPage({super.key});

  @override
  State<SilverGiftTemplatesPage> createState() => _SilverGiftTemplatesPageState();
}

class _SilverGiftTemplatesPageState extends State<SilverGiftTemplatesPage>
    with TickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  String? selectedTemplateId;
  
  final List<SilverGiftTemplate> templates = [
    SilverGiftTemplate(
      id: 'luxury_classic',
      name: 'كلاسيكي فاخر',
      description: 'تصميم راقي مع موسيقى كلاسيكية وتأثيرات فضية لامعة',
      primaryColor: const Color(0xFFC0C0C0),
      secondaryColor: const Color(0xFFE5E5E5),
      backgroundPattern: 'luxury_classic',
      icon: '🎁',
      features: ['موسيقى كلاسيكية', 'تأثيرات فضية', '5 ملفات وسائط', 'جدولة الإرسال'],
    ),
    SilverGiftTemplate(
      id: 'birthday_premium',
      name: 'عيد ميلاد راقي',
      description: 'احتفال فاخر مع كعكة ثلاثية الأبعاد وألعاب نارية متحركة',
      primaryColor: const Color(0xFFFF1493),
      secondaryColor: const Color(0xFFFFB6C1),
      backgroundPattern: 'birthday_premium',
      icon: '🎂',
      features: ['كعكة ثلاثية الأبعاد', 'ألعاب نارية', 'أغاني عيد ميلاد', 'تأثيرات متحركة'],
    ),
    SilverGiftTemplate(
      id: 'romantic_silver',
      name: 'رومانسي فضي',
      description: 'تصميم رومانسي فاخر مع قلوب متطايرة وموسيقى هادئة',
      primaryColor: const Color(0xFFDC143C),
      secondaryColor: const Color(0xFFFF69B4),
      backgroundPattern: 'romantic_silver',
      icon: '💖',
      features: ['قلوب متطايرة', 'موسيقى رومانسية', 'ورود متساقطة', 'تأثيرات قمرية'],
    ),
    SilverGiftTemplate(
      id: 'wedding_deluxe',
      name: 'زفاف فاخر',
      description: 'تصميم أنيق للأعراس مع خواتم ذهبية وموسيقى كلاسيكية',
      primaryColor: const Color(0xFFFFD700),
      secondaryColor: const Color(0xFFFFF8DC),
      backgroundPattern: 'wedding_deluxe',
      icon: '💍',
      features: ['خواتم ذهبية', 'موسيقى كلاسيكية', 'ورود بيضاء', 'تأثيرات لؤلؤية'],
    ),
    SilverGiftTemplate(
      id: 'graduation_premium',
      name: 'تخرج مميز',
      description: 'احتفال بالتخرج مع قبعات طائرة وشهادات ذهبية',
      primaryColor: const Color(0xFF4169E1),
      secondaryColor: const Color(0xFF87CEEB),
      backgroundPattern: 'graduation_premium',
      icon: '🎓',
      features: ['قبعات طائرة', 'شهادات ذهبية', 'موسيقى احتفالية', 'نجوم متلألئة'],
    ),
    SilverGiftTemplate(
      id: 'anniversary',
      name: 'ذكرى سنوية',
      description: 'تصميم خاص للذكريات مع ألبوم صور متحرك وموسيقى حالمة',
      primaryColor: const Color(0xFF9370DB),
      secondaryColor: const Color(0xFFDDA0DD),
      backgroundPattern: 'anniversary',
      icon: '💕',
      features: ['ألبوم صور متحرك', 'موسيقى حالمة', 'تأثيرات ذهبية', 'ذكريات متحركة'],
    ),
    SilverGiftTemplate(
      id: 'achievement',
      name: 'إنجاز',
      description: 'تصميم للاحتفال بالإنجازات مع كؤوس وميداليات ذهبية',
      primaryColor: const Color(0xFFFFD700),
      secondaryColor: const Color(0xFFFFA500),
      backgroundPattern: 'achievement',
      icon: '🏆',
      features: ['كؤوس ذهبية', 'ميداليات', 'تأثيرات نجوم', 'موسيقى انتصار'],
    ),
    SilverGiftTemplate(
      id: 'new_year',
      name: 'رأس السنة',
      description: 'احتفال برأس السنة مع ألعاب نارية وعد تنازلي متحرك',
      primaryColor: const Color(0xFFFF6347),
      secondaryColor: const Color(0xFFFFD700),
      backgroundPattern: 'new_year',
      icon: '🎊',
      features: ['ألعاب نارية', 'عد تنازلي', 'كونفيتي متحرك', 'موسيقى احتفالية'],
    ),
    SilverGiftTemplate(
      id: 'mothers_day',
      name: 'عيد الأم',
      description: 'تصميم خاص لعيد الأم مع ورود وقلوب وموسيقى هادئة',
      primaryColor: const Color(0xFFFF69B4),
      secondaryColor: const Color(0xFFFFC0CB),
      backgroundPattern: 'mothers_day',
      icon: '🌹',
      features: ['ورود متفتحة', 'قلوب دافئة', 'موسيقى هادئة', 'رسائل حب'],
    ),
    SilverGiftTemplate(
      id: 'fathers_day',
      name: 'عيد الأب',
      description: 'تصميم أنيق لعيد الأب مع ربطات عنق وساعات كلاسيكية',
      primaryColor: const Color(0xFF2F4F4F),
      secondaryColor: const Color(0xFF708090),
      backgroundPattern: 'fathers_day',
      icon: '👔',
      features: ['ربطات عنق', 'ساعات كلاسيكية', 'تأثيرات أنيقة', 'موسيقى هادئة'],
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
          title: const Text('قوالب الهدية الفضية', style: TextStyle(fontWeight: FontWeight.w800)),
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
                  Color(0xFFC0C0C0),
                  Color(0xFFE5E5E5),
                  Color(0xFFB0C4DE),
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
                Color(0xFFF8F8FF),
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
                  color: const Color(0xFFC0C0C0).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('🥈', style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 12),
              const Text(
                'اختر القالب المناسب',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF708090),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'اختر من بين ${templates.length} قوالب فضية فاخرة',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFC0C0C0).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              '50 ج.م • 5 ملفات وسائط • موسيقى • جدولة • 60 يوم',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF708090),
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
        childAspectRatio: 0.75,
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
                          // نمط الخلفية الفضية
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(0.3),
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
                          
                          // شارة الفضة
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('🥈', style: TextStyle(fontSize: 12)),
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
        '/silver-gift-design',
        arguments: {
          'template': selectedTemplate,
        },
      );
    }
  }
}
