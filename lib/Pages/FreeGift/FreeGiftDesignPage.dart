import 'package:flutter/material.dart';

class FreeGiftDesignPage extends StatefulWidget {
  static const routeName = '/free-gift-design';
  const FreeGiftDesignPage({super.key});

  @override
  State<FreeGiftDesignPage> createState() => _FreeGiftDesignPageState();
}

class _FreeGiftDesignPageState extends State<FreeGiftDesignPage>
    with TickerProviderStateMixin {
  
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _recipientNameController = TextEditingController();
  final TextEditingController _recipientPhoneController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  String? selectedImagePath;
  int currentStep = 0;
  final int maxSteps = 3;
  
  // قيود الباقة المجانية
  final int maxMessageLength = 200;
  final int maxImages = 1;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _recipientNameController.dispose();
    _recipientPhoneController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تصميم الهدية المجانية', style: TextStyle(fontWeight: FontWeight.w800)),
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
              _buildProgressIndicator(),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildCurrentStep(),
                  ),
                ),
              ),
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: List.generate(maxSteps, (index) {
              final isActive = index <= currentStep;
              final isCompleted = index < currentStep;
              
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index < maxSteps - 1 ? 8 : 0),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: isCompleted 
                              ? Colors.green 
                              : isActive 
                                  ? const Color(0xFF9C27B0) 
                                  : Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isCompleted ? Icons.check : Icons.circle,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      if (index < maxSteps - 1)
                        Expanded(
                          child: Container(
                            height: 2,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            color: isCompleted 
                                ? Colors.green 
                                : Colors.grey[300],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            _getStepTitle(currentStep),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF9C27B0),
            ),
          ),
        ],
      ),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'معلومات المستلم';
      case 1:
        return 'كتابة الرسالة';
      case 2:
        return 'إضافة صورة (اختياري)';
      default:
        return '';
    }
  }

  Widget _buildCurrentStep() {
    switch (currentStep) {
      case 0:
        return _buildRecipientInfoStep();
      case 1:
        return _buildMessageStep();
      case 2:
        return _buildImageStep();
      default:
        return Container();
    }
  }

  Widget _buildRecipientInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepCard(
            title: 'معلومات المستلم',
            icon: Icons.person,
            child: Column(
              children: [
                _buildTextField(
                  controller: _recipientNameController,
                  label: 'اسم المستلم',
                  hint: 'أدخل اسم الشخص الذي ستهديه',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _recipientPhoneController,
                  label: 'رقم هاتف المستلم',
                  hint: 'أدخل رقم الهاتف (اختياري)',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoCard(
            'نصائح مهمة',
            [
              'تأكد من صحة اسم المستلم',
              'رقم الهاتف اختياري ولكن مفيد للتواصل',
              'يمكنك تعديل هذه المعلومات لاحقاً',
            ],
            Icons.lightbulb_outline,
            Colors.amber,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepCard(
            title: 'رسالة الهدية',
            icon: Icons.message,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _messageController,
                  maxLength: maxMessageLength,
                  maxLines: 6,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    hintText: 'اكتب رسالتك هنا...\nمثال: عيد ميلاد سعيد! أتمنى لك يوماً مليئاً بالفرح والسعادة',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF9C27B0), width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_messageController.text.length}/$maxMessageLength حرف',
                      style: TextStyle(
                        color: _messageController.text.length > maxMessageLength * 0.9 
                            ? Colors.red 
                            : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    if (_messageController.text.length > maxMessageLength * 0.9)
                      Text(
                        'اقترب من الحد الأقصى!',
                        style: TextStyle(
                          color: Colors.red[600],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoCard(
            'قيود الباقة المجانية',
            [
              'حد أقصى $maxMessageLength حرف للرسالة',
              'يمكنك استخدام الرموز التعبيرية 😊',
              'الرسالة ستظهر بخط جميل في الهدية',
            ],
            Icons.info_outline,
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildImageStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepCard(
            title: 'إضافة صورة',
            icon: Icons.image,
            child: Column(
              children: [
                if (selectedImagePath == null)
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'اضغط لإضافة صورة',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '(اختياري)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/placeholder.jpg'), // مؤقت
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  selectedImagePath = null;
                                });
                              },
                              icon: const Icon(Icons.close, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _selectImage,
                    icon: Icon(selectedImagePath == null ? Icons.add_photo_alternate : Icons.edit),
                    label: Text(selectedImagePath == null ? 'اختر صورة' : 'تغيير الصورة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9C27B0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoCard(
            'معلومات الصورة',
            [
              'يمكنك إضافة صورة واحدة فقط (باقة مجانية)',
              'الصورة اختيارية - يمكنك تخطي هذه الخطوة',
              'أفضل أحجام: مربعة أو مستطيلة',
              'سيتم ضغط الصورة تلقائياً',
            ],
            Icons.info_outline,
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF9C27B0).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF9C27B0),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9C27B0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF9C27B0)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF9C27B0), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      onChanged: (value) {
        setState(() {});
      },
    );
  }

  Widget _buildInfoCard(String title, List<String> points, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...points.map((point) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    point,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (currentStep > 0)
            Expanded(
              child: ElevatedButton(
                onPressed: _previousStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.grey[700],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'السابق',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          if (currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _canProceed() ? _nextStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _canProceed() 
                    ? const Color(0xFF9C27B0) 
                    : Colors.grey[300],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                currentStep == maxSteps - 1 ? 'إنشاء الهدية' : 'التالي',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (currentStep) {
      case 0:
        return _recipientNameController.text.trim().isNotEmpty;
      case 1:
        return _messageController.text.trim().isNotEmpty && 
               _messageController.text.length <= maxMessageLength;
      case 2:
        return true; // الصورة اختيارية
      default:
        return false;
    }
  }

  void _previousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  void _nextStep() {
    if (currentStep < maxSteps - 1) {
      setState(() {
        currentStep++;
      });
      _animationController.reset();
      _animationController.forward();
    } else {
      _createGift();
    }
  }

  void _selectImage() {
    // TODO: تنفيذ اختيار الصورة
    setState(() {
      selectedImagePath = 'temp_path'; // مؤقت
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('سيتم تنفيذ اختيار الصورة قريباً'),
        backgroundColor: Color(0xFF9C27B0),
      ),
    );
  }

  void _createGift() {
    // TODO: تنفيذ إنشاء الهدية
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تم إنشاء الهدية!'),
        content: const Text('تم إنشاء هديتك المجانية بنجاح. سيتم إرسالها قريباً.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }
}
