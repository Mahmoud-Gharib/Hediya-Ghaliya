import 'package:flutter/material.dart';

class FreeGiftTemplate {
  final String id;
  final String name;
  final String description;
  final Color primaryColor;
  final Color secondaryColor;
  final String backgroundPattern;
  final String icon;
  final List<String> features;

  FreeGiftTemplate({
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

class FreeGiftTemplatesPage extends StatefulWidget {
  static const routeName = '/free-gift-templates';
  const FreeGiftTemplatesPage({super.key});

  @override
  State<FreeGiftTemplatesPage> createState() => _FreeGiftTemplatesPageState();
}

class _FreeGiftTemplatesPageState extends State<FreeGiftTemplatesPage>
    with TickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  String? selectedTemplateId;
  
  final List<FreeGiftTemplate> templates = [
    FreeGiftTemplate(
      id: 'classic',
      name: 'كلاسيكي',
      description: 'تصميم أنيق وبسيط مناسب لجميع المناسبات',
      primaryColor: const Color(0xFF9C27B0),
      secondaryColor: const Color(0xFFE91E63),
      backgroundPattern: 'classic',
      icon: '🎁',
      features: ['خط أنيق', 'ألوان هادئة', 'تصميم بسيط'],
    ),
    FreeGiftTemplate(
      id: 'birthday',
      name: 'عيد ميلاد',
      description: 'تصميم مرح ومليء بالألوان لأعياد الميلاد',
      primaryColor: const Color(0xFFFF6F61),
      secondaryColor: const Color(0xFFFFD700),
      backgroundPattern: 'birthday',
      icon: '🎂',
      features: ['ألوان مرحة', 'رموز تعبيرية', 'تأثيرات احتفالية'],
    ),
    FreeGiftTemplate(
      id: 'love',
      name: 'حب ورومانسية',
      description: 'تصميم رومانسي مثالي للأحباب والأزواج',
      primaryColor: const Color(0xFFE91E63),
      secondaryColor: const Color(0xFFFF69B4),
      backgroundPattern: 'love',
      icon: '💕',
      features: ['ألوان دافئة', 'قلوب وورود', 'خط رومانسي'],
    ),
    FreeGiftTemplate(
      id: 'friendship',
      name: 'صداقة',
      description: 'تصميم ودود ومرح للأصدقاء المقربين',
      primaryColor: const Color(0xFF4CAF50),
      secondaryColor: const Color(0xFF8BC34A),
      backgroundPattern: 'friendship',
      icon: '🤝',
      features: ['ألوان طبيعية', 'رموز الصداقة', 'تصميم ودود'],
    ),
    FreeGiftTemplate(
      id: 'congratulations',
      name: 'تهنئة',
      description: 'تصميم احتفالي للتهاني والإنجازات',
      primaryColor: const Color(0xFFFFD700),
      secondaryColor: const Color(0xFFFFA500),
      backgroundPattern: 'congratulations',
      icon: '🎉',
      features: ['ألوان ذهبية', 'نجوم وتيجان', 'تأثيرات لامعة'],
    ),
    FreeGiftTemplate(
      id: 'thank_you',
      name: 'شكر وامتنان',
      description: 'تصميم هادئ للتعبير عن الشكر والامتنان',
      primaryColor: const Color(0xFF607D8B),
      secondaryColor: const Color(0xFF90A4AE),
      backgroundPattern: 'thank_you',
      icon: '🙏',
      features: ['ألوان هادئة', 'رموز الامتنان', 'خط أنيق'],
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
          title: const Text('قوالب الهدية المجانية', style: TextStyle(fontWeight: FontWeight.w800)),
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
                  Color(0xFF9C27B0),
                  Color(0xFFE91E63),
                  Color(0xFFFF6F61),
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
                Color(0xFFF3E5F5),
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
          const Text(
            'اختر القالب المناسب',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF9C27B0),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اختر من بين ${templates.length} قوالب مجانية جميلة',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
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
          margin: const EdgeInsets.only(bottom: 16),
          child: GestureDetector(
            onTap: () => _selectTemplate(template.id),
            child: Container(
              padding: const EdgeInsets.all(20),
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
              child: Row(
                children: [
                  // معاينة القالب
                  Container(
                    width: 80,
                    height: 100,
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
                        
                        // تأثير التحديد
                        if (isSelected)
                          Positioned(
                            top: 5,
                            right: 5,
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
                  
                  const SizedBox(width: 16),
                  
                  // معلومات القالب
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          template.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: template.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          template.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: template.features.map((feature) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: template.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              feature,
                              style: TextStyle(
                                fontSize: 12,
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
        '/free-gift-design',
        arguments: {
          'template': selectedTemplate,
        },
      );
    }
  }
}
