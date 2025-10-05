import 'package:flutter/material.dart';

class SilverGiftDesignPage extends StatefulWidget {
  static const routeName = '/silver-gift-design';
  const SilverGiftDesignPage({super.key});

  @override
  State<SilverGiftDesignPage> createState() => _SilverGiftDesignPageState();
}

class _SilverGiftDesignPageState extends State<SilverGiftDesignPage>
    with TickerProviderStateMixin {
  
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _recipientNameController = TextEditingController();
  final TextEditingController _recipientPhoneController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  List<String> selectedMediaPaths = [];
  String? selectedMusicPath;
  DateTime? scheduledDelivery;
  int currentStep = 0;
  final int maxSteps = 5;
  
  // قيود الباقة الفضية
  final int maxMessageLength = 1000;
  final int maxMediaFiles = 5;

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
          title: const Text('تصميم الهدية الفضية', style: TextStyle(fontWeight: FontWeight.w800)),
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
                                  ? const Color(0xFFC0C0C0) 
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
              color: Color(0xFF708090),
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
        return 'كتابة الرسالة المفصلة';
      case 2:
        return 'إضافة الوسائط (5 ملفات)';
      case 3:
        return 'اختيار الموسيقى الخلفية';
      case 4:
        return 'جدولة الإرسال';
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
        return _buildMediaStep();
      case 3:
        return _buildMusicStep();
      case 4:
        return _buildScheduleStep();
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
                  hint: 'أدخل رقم الهاتف (مطلوب للإشعارات)',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoCard(
            'مميزات الباقة الفضية',
            [
              '5 ملفات وسائط متنوعة',
              'موسيقى خلفية مخصصة',
              'جدولة إرسال الهدية',
              'رسالة مفصلة حتى 1000 حرف',
              'صالحة لمدة 60 يوماً',
            ],
            Icons.workspace_premium,
            const Color(0xFFC0C0C0),
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
            title: 'رسالة الهدية المفصلة',
            icon: Icons.message,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _messageController,
                  maxLength: maxMessageLength,
                  maxLines: 10,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    hintText: 'اكتب رسالتك المفصلة هنا...\nيمكنك الآن كتابة رسالة طويلة ومعبرة مع الباقة الفضية\nشارك مشاعرك وذكرياتك بحرية أكبر',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFC0C0C0), width: 2),
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC0C0C0).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'باقة فضية',
                        style: TextStyle(
                          color: Color(0xFF708090),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepCard(
            title: 'إضافة الوسائط المتنوعة',
            icon: Icons.perm_media,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC0C0C0).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Text('🥈', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'يمكنك إضافة حتى $maxMediaFiles ملفات متنوعة',
                          style: const TextStyle(
                            color: Color(0xFF708090),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ...List.generate(maxMediaFiles, (index) => 
                  _buildMediaSlot(index)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMusicStep() {
    final musicOptions = [
      {'name': 'كلاسيكية هادئة', 'icon': '🎼', 'duration': '3:45'},
      {'name': 'رومانسية حالمة', 'icon': '💕', 'duration': '4:12'},
      {'name': 'احتفالية مرحة', 'icon': '🎉', 'duration': '3:28'},
      {'name': 'طبيعية مريحة', 'icon': '🌿', 'duration': '5:03'},
      {'name': 'بدون موسيقى', 'icon': '🔇', 'duration': '--'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepCard(
            title: 'اختيار الموسيقى الخلفية',
            icon: Icons.music_note,
            child: Column(
              children: musicOptions.map((music) => 
                _buildMusicOption(music)
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepCard(
            title: 'جدولة إرسال الهدية',
            icon: Icons.schedule,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC0C0C0).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text('⏰', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'متى تريد إرسال الهدية؟',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF708090),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _selectDateTime(),
                              icon: const Icon(Icons.calendar_today),
                              label: Text(
                                scheduledDelivery == null 
                                    ? 'اختر التاريخ والوقت'
                                    : 'تم اختيار الموعد',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: scheduledDelivery == null 
                                    ? const Color(0xFFC0C0C0)
                                    : Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                scheduledDelivery = DateTime.now();
                              });
                            },
                            icon: const Icon(Icons.send),
                            label: const Text('إرسال فوري'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (scheduledDelivery != null && scheduledDelivery != DateTime.now()) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'سيتم الإرسال في: ${scheduledDelivery!.day}/${scheduledDelivery!.month}/${scheduledDelivery!.year} الساعة ${scheduledDelivery!.hour}:${scheduledDelivery!.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
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
                  color: const Color(0xFFC0C0C0).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF708090),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF708090),
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
        prefixIcon: Icon(icon, color: const Color(0xFF708090)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFC0C0C0), width: 2),
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

  Widget _buildMediaSlot(int index) {
    final hasMedia = index < selectedMediaPaths.length;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasMedia ? Colors.green.withOpacity(0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasMedia ? Colors.green.withOpacity(0.3) : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: hasMedia ? Colors.green.withOpacity(0.1) : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              hasMedia ? Icons.check_circle : Icons.add_circle_outline,
              color: hasMedia ? Colors.green : Colors.grey[500],
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasMedia ? 'تم اختيار الملف ${index + 1}' : 'ملف ${index + 1}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: hasMedia ? Colors.green : Colors.grey[600],
                  ),
                ),
                if (hasMedia)
                  Text(
                    'media_${index + 1}.jpg',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _selectMedia(index),
            child: Text(
              hasMedia ? 'تغيير' : 'اختيار',
              style: const TextStyle(
                color: Color(0xFF708090),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMusicOption(Map<String, String> music) {
    final isSelected = selectedMusicPath == music['name'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedMusicPath = music['name'];
          });
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFC0C0C0).withOpacity(0.1) : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFFC0C0C0) : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Text(music['icon']!, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      music['name']!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? const Color(0xFF708090) : Colors.grey[700],
                      ),
                    ),
                    Text(
                      'المدة: ${music['duration']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF708090),
                  size: 24,
                ),
            ],
          ),
        ),
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
                    ? const Color(0xFFC0C0C0) 
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
        return _recipientNameController.text.trim().isNotEmpty &&
               _recipientPhoneController.text.trim().isNotEmpty;
      case 1:
        return _messageController.text.trim().isNotEmpty && 
               _messageController.text.length <= maxMessageLength;
      case 2:
        return selectedMediaPaths.isNotEmpty;
      case 3:
        return selectedMusicPath != null;
      case 4:
        return scheduledDelivery != null;
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

  void _selectMedia(int index) {
    setState(() {
      if (index >= selectedMediaPaths.length) {
        selectedMediaPaths.add('silver_media_${index + 1}');
      } else {
        selectedMediaPaths[index] = 'silver_media_${index + 1}_updated';
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم اختيار الملف ${index + 1}'),
        backgroundColor: const Color(0xFFC0C0C0),
      ),
    );
  }

  void _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      
      if (time != null) {
        setState(() {
          scheduledDelivery = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _createGift() {
    Navigator.pushNamed(
      context,
      '/silver-gift-preview',
      arguments: {
        'recipientName': _recipientNameController.text,
        'recipientPhone': _recipientPhoneController.text,
        'message': _messageController.text,
        'mediaPaths': selectedMediaPaths,
        'musicPath': selectedMusicPath,
        'scheduledDelivery': scheduledDelivery,
      },
    );
  }
}
