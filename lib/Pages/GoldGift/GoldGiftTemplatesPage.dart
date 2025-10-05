import 'package:flutter/material.dart';
import 'package:hediya_ghaliya/Pages/GoldGift/GoldGiftTemplatesPage.dart';

class GoldGiftTemplate {
  final String id;
  final String name;
  final String description;
  final Color primaryColor;
  final Color secondaryColor;
  final String backgroundPattern;
  final String icon;
  final List<String> features;

  GoldGiftTemplate({
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

class GoldGiftTemplatesPage extends StatefulWidget {
  static const routeName = '/gold-gift-templates';
  const GoldGiftTemplatesPage({super.key});

  @override
  State<GoldGiftTemplatesPage> createState() => _GoldGiftTemplatesPageState();
}

class _GoldGiftTemplatesPageState extends State<GoldGiftTemplatesPage>
    with TickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  String? selectedTemplateId;
  
  final List<GoldGiftTemplate> templates = [
    GoldGiftTemplate(
      id: 'royal_classic',
      name: 'كلاسيكي ملكي',
      description: 'تصميم ملكي فاخر مع تيجان ذهبية وموسيقى أوركسترالية',
      primaryColor: const Color(0xFFFFD700),
      secondaryColor: const Color(0xFFFFA500),
      backgroundPattern: 'royal_classic',
      icon: '👑',
      features: ['تيجان ذهبية', 'موسيقى أوركسترالية', 'ملفات غير محدودة', 'تأثيرات ملكية'],
    ),
    GoldGiftTemplate(
      id: 'diamond_birthday',
      name: 'عيد ميلاد ماسي',
      description: 'احتفال أسطوري مع كعكة ماسية وألعاب نارية ذهبية',
      primaryColor: const Color(0xFFB8860B),
      secondaryColor: const Color(0xFFFFD700),
      backgroundPattern: 'diamond_birthday',
      icon: '💎',
      features: ['كعكة ماسية', 'ألعاب نارية ذهبية', 'أغاني مخصصة', 'تأثيرات ماسية'],
    ),
    GoldGiftTemplate(
      id: 'eternal_love',
      name: 'حب أبدي',
      description: 'رومانسية خالدة مع قلوب ذهبية وموسيقى سيمفونية',
      primaryColor: const Color(0xFFDC143C),
      secondaryColor: const Color(0xFFFFD700),
      backgroundPattern: 'eternal_love',
      icon: '💛',
      features: ['قلوب ذهبية', 'موسيقى سيمفونية', 'ورود ذهبية', 'تأثيرات أبدية'],
    ),
    GoldGiftTemplate(
      id: 'royal_wedding',
      name: 'زفاف ملكي',
      description: 'حفل زفاف أسطوري مع قصر ذهبي وأوركسترا كاملة',
      primaryColor: const Color(0xFFFFD700),
      secondaryColor: const Color(0xFFFFF8DC),
      backgroundPattern: 'royal_wedding',
      icon: '🏰',
      features: ['قصر ذهبي', 'أوركسترا كاملة', 'عربة ملكية', 'تأثيرات قصر'],
    ),
    GoldGiftTemplate(
      id: 'golden_achievement',
      name: 'إنجاز ذهبي',
      description: 'احتفال بالإنجازات العظيمة مع تماثيل ذهبية وموسيقى انتصار',
      primaryColor: const Color(0xFFFFD700),
      secondaryColor: const Color(0xFFFFA500),
      backgroundPattern: 'golden_achievement',
      icon: '🏆',
      features: ['تماثيل ذهبية', 'موسيقى انتصار', 'نسور ذهبية', 'تأثيرات إنجاز'],
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
          title: const Text('قوالب الهدية الذهبية', style: TextStyle(fontWeight: FontWeight.w800)),
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
                  Color(0xFFFFD700),
                  Color(0xFFFFA500),
                  Color(0xFFFF8C00),
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
                Color(0xFFFFFAF0),
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
                  color: const Color(0xFFFFD700).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('🥇', style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 12),
              const Text(
                'اختر القالب الملكي',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB8860B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'اختر من بين ${templates.length} قوالب ذهبية ملكية',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              '100 ج.م • ملفات غير محدودة • مميزات حصرية • 365 يوم',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFFB8860B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplatesList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final template = templates[index];
        final isSelected = selectedTemplateId == template.id;
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 20),
          child: GestureDetector(
            onTap: () => _selectTemplate(template.id),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    const Color(0xFFFFD700).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected 
                      ? template.primaryColor 
                      : Colors.grey[300]!,
                  width: isSelected ? 4 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected 
                        ? template.primaryColor.withOpacity(0.3)
                        : Colors.black.withOpacity(0.08),
                    blurRadius: isSelected ? 20 : 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // معاينة القالب الذهبي
                  Container(
                    width: 120,
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          template.primaryColor,
                          template.secondaryColor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: template.primaryColor.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // تأثيرات ذهبية
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.4),
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.1),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        // الأيقونة الكبيرة
                        Center(
                          child: Text(
                            template.icon,
                            style: const TextStyle(fontSize: 48),
                          ),
                        ),
                        
                        // شارة الذهب
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text('🥇', style: TextStyle(fontSize: 16)),
                          ),
                        ),
                        
                        // تأثير التحديد الذهبي
                        if (isSelected)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: template.primaryColor.withOpacity(0.5),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.check,
                                color: template.primaryColor,
                                size: 20,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 20),
                  
                  // معلومات القالب المفصلة
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              template.name,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: template.primaryColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: template.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'حصري',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFB8860B),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          template.description,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: template.features.map((feature) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  template.primaryColor.withOpacity(0.1),
                                  template.secondaryColor.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: template.primaryColor.withOpacity(0.2),
                              ),
                            ),
                            child: Text(
                              feature,
                              style: TextStyle(
                                fontSize: 12,
                                color: template.primaryColor,
                                fontWeight: FontWeight.w600,
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
        height: 70,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              selectedTemplate.primaryColor,
              selectedTemplate.secondaryColor,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: selectedTemplate.primaryColor.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _continueWithTemplate,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('👑', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'متابعة مع ${selectedTemplate.name}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
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
        '/gold-gift-design',
        arguments: {
          'template': selectedTemplate,
        },
      );
    }
  }
}
