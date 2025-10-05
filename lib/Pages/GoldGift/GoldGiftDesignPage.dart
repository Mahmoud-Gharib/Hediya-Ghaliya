import 'package:flutter/material.dart';

class GoldGiftDesignPage extends StatefulWidget {
  static const routeName = '/gold-gift-design';
  const GoldGiftDesignPage({super.key});

  @override
  State<GoldGiftDesignPage> createState() => _GoldGiftDesignPageState();
}

class _GoldGiftDesignPageState extends State<GoldGiftDesignPage>
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
  String? voiceRecordingPath;
  bool hasCustomMusic = false;
  int currentStep = 0;
  final int maxSteps = 6;

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
          title: const Text('تصميم الهدية الذهبية', style: TextStyle(fontWeight: FontWeight.w800)),
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
                                  ? const Color(0xFFFFD700) 
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
              color: Color(0xFFB8860B),
            ),
          ),
        ],
      ),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0: return 'معلومات المستلم';
      case 1: return 'رسالة غير محدودة';
      case 2: return 'ملفات وسائط غير محدودة';
      case 3: return 'موسيقى مخصصة';
      case 4: return 'تسجيل صوتي شخصي';
      case 5: return 'جدولة ذكية';
      default: return '';
    }
  }

  Widget _buildCurrentStep() {
    switch (currentStep) {
      case 0: return _buildRecipientInfoStep();
      case 1: return _buildMessageStep();
      case 2: return _buildMediaStep();
      case 3: return _buildMusicStep();
      case 4: return _buildVoiceStep();
      case 5: return _buildScheduleStep();
      default: return Container();
    }
  }

  Widget _buildRecipientInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildStepCard(
            title: 'معلومات المستلم الملكية',
            icon: Icons.person,
            child: Column(
              children: [
                _buildTextField(
                  controller: _recipientNameController,
                  label: 'اسم المستلم',
                  hint: 'أدخل اسم الشخص المميز',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _recipientPhoneController,
                  label: 'رقم هاتف المستلم',
                  hint: 'رقم الهاتف للتواصل الفوري',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoCard(
            'مميزات الباقة الذهبية الحصرية',
            [
              '👑 ملفات وسائط غير محدودة',
              '🎵 موسيقى مخصصة وتسجيل صوتي',
              '⏰ جدولة ذكية متقدمة',
              '📝 رسالة بلا حدود',
              '🏆 صالحة لمدة عام كامل',
              '💎 تأثيرات ملكية حصرية',
            ],
            Icons.workspace_premium,
            const Color(0xFFFFD700),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildStepCard(
            title: 'رسالة ملكية بلا حدود',
            icon: Icons.message,
            child: Column(
              children: [
                TextField(
                  controller: _messageController,
                  maxLines: 12,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    hintText: 'اكتب رسالتك الملكية بلا حدود...\nعبر عن مشاعرك بحرية كاملة\nاكتب قصة، ذكريات، أحلام، أو أي شيء تريده\nالباقة الذهبية تمنحك مساحة لا نهائية للتعبير',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFFFFAF0),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Text('👑', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(
                        'عدد الأحرف: ${_messageController.text.length} (بلا حدود)',
                        style: const TextStyle(
                          color: Color(0xFFB8860B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  Widget _buildMediaStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildStepCard(
            title: 'ملفات وسائط غير محدودة',
            icon: Icons.perm_media,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Text('👑', style: TextStyle(fontSize: 24)),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'أضف ملفات وسائط بلا حدود - صور، فيديوهات، مستندات',
                          style: TextStyle(
                            color: Color(0xFFB8860B),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ...List.generate(10, (index) => _buildMediaSlot(index)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _addMoreMedia,
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة المزيد من الملفات'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMusicStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildStepCard(
            title: 'موسيقى مخصصة حصرية',
            icon: Icons.music_note,
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('رفع موسيقى مخصصة'),
                  subtitle: const Text('ارفع الموسيقى المفضلة لديك'),
                  value: hasCustomMusic,
                  onChanged: (value) {
                    setState(() {
                      hasCustomMusic = value;
                    });
                  },
                  activeColor: const Color(0xFFFFD700),
                ),
                if (hasCustomMusic) ...[
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _selectCustomMusic,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('رفع ملف موسيقى'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 16),
                  ...['موسيقى ملكية', 'سيمفونية ذهبية', 'أوركسترا فاخرة', 'بدون موسيقى']
                      .map((music) => _buildMusicOption(music)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildStepCard(
            title: 'تسجيل صوتي شخصي',
            icon: Icons.mic,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text('🎤', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 16),
                      const Text(
                        'سجل رسالة صوتية شخصية',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB8860B),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _startRecording,
                        icon: const Icon(Icons.fiber_manual_record),
                        label: Text(voiceRecordingPath == null ? 'ابدأ التسجيل' : 'إعادة التسجيل'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                        ),
                      ),
                      if (voiceRecordingPath != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green),
                              SizedBox(width: 8),
                              Text('تم التسجيل بنجاح'),
                            ],
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

  Widget _buildScheduleStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildStepCard(
            title: 'جدولة ذكية متقدمة',
            icon: Icons.schedule,
            child: Column(
              children: [
                ListTile(
                  leading: const Text('⚡', style: TextStyle(fontSize: 24)),
                  title: const Text('إرسال فوري'),
                  subtitle: const Text('إرسال الهدية الآن'),
                  trailing: Radio<String>(
                    value: 'now',
                    groupValue: scheduledDelivery == null ? 'now' : 'scheduled',
                    onChanged: (value) {
                      setState(() {
                        scheduledDelivery = DateTime.now();
                      });
                    },
                  ),
                ),
                ListTile(
                  leading: const Text('📅', style: TextStyle(fontSize: 24)),
                  title: const Text('جدولة متقدمة'),
                  subtitle: const Text('اختر تاريخ ووقت محدد'),
                  trailing: Radio<String>(
                    value: 'scheduled',
                    groupValue: scheduledDelivery != null && scheduledDelivery != DateTime.now() ? 'scheduled' : 'now',
                    onChanged: (value) {
                      _selectDateTime();
                    },
                  ),
                ),
                if (scheduledDelivery != null && scheduledDelivery != DateTime.now()) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'موعد الإرسال: ${scheduledDelivery!.day}/${scheduledDelivery!.month}/${scheduledDelivery!.year} - ${scheduledDelivery!.hour}:${scheduledDelivery!.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        color: Color(0xFFB8860B),
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
    );
  }

  Widget _buildStepCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.1),
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
                  color: const Color(0xFFFFD700).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFFB8860B), size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB8860B),
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
        prefixIcon: Icon(icon, color: const Color(0xFFB8860B)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2),
        ),
        filled: true,
        fillColor: const Color(0xFFFFFAF0),
      ),
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
            child: Text(
              point,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
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
        color: hasMedia ? const Color(0xFFFFD700).withOpacity(0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasMedia ? const Color(0xFFFFD700).withOpacity(0.3) : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            hasMedia ? Icons.check_circle : Icons.add_circle_outline,
            color: hasMedia ? const Color(0xFFFFD700) : Colors.grey[500],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              hasMedia ? 'ملف ${index + 1} - تم الاختيار' : 'ملف ${index + 1}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: hasMedia ? const Color(0xFFB8860B) : Colors.grey[600],
              ),
            ),
          ),
          TextButton(
            onPressed: () => _selectMedia(index),
            child: Text(
              hasMedia ? 'تغيير' : 'اختيار',
              style: const TextStyle(color: Color(0xFFB8860B), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMusicOption(String music) {
    final isSelected = selectedMusicPath == music;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Text('🎵', style: TextStyle(fontSize: 24)),
        title: Text(music),
        trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFFFFD700)) : null,
        onTap: () {
          setState(() {
            selectedMusicPath = music;
          });
        },
        tileColor: isSelected ? const Color(0xFFFFD700).withOpacity(0.1) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('السابق', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          if (currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _canProceed() ? _nextStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _canProceed() ? const Color(0xFFFFD700) : Colors.grey[300],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                currentStep == maxSteps - 1 ? '👑 إنشاء الهدية الملكية' : 'التالي',
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
      case 0: return _recipientNameController.text.trim().isNotEmpty && _recipientPhoneController.text.trim().isNotEmpty;
      case 1: return _messageController.text.trim().isNotEmpty;
      case 2: return selectedMediaPaths.isNotEmpty;
      case 3: return selectedMusicPath != null || hasCustomMusic;
      case 4: return voiceRecordingPath != null;
      case 5: return scheduledDelivery != null;
      default: return false;
    }
  }

  void _previousStep() {
    if (currentStep > 0) {
      setState(() { currentStep--; });
      _animationController.reset();
      _animationController.forward();
    }
  }

  void _nextStep() {
    if (currentStep < maxSteps - 1) {
      setState(() { currentStep++; });
      _animationController.reset();
      _animationController.forward();
    } else {
      _createGift();
    }
  }

  void _selectMedia(int index) {
    setState(() {
      if (index >= selectedMediaPaths.length) {
        selectedMediaPaths.add('gold_media_${index + 1}');
      }
    });
  }

  void _addMoreMedia() {
    setState(() {
      selectedMediaPaths.add('gold_media_${selectedMediaPaths.length + 1}');
    });
  }

  void _selectCustomMusic() {
    setState(() {
      selectedMusicPath = 'موسيقى مخصصة';
    });
  }

  void _startRecording() {
    setState(() {
      voiceRecordingPath = 'gold_voice_recording.mp3';
    });
  }

  void _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
      if (time != null) {
        setState(() {
          scheduledDelivery = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  void _createGift() {
    Navigator.pushNamed(
      context,
      '/gold-gift-preview',
      arguments: {
        'recipientName': _recipientNameController.text,
        'recipientPhone': _recipientPhoneController.text,
        'message': _messageController.text,
        'mediaPaths': selectedMediaPaths,
        'musicPath': selectedMusicPath,
        'voiceRecordingPath': voiceRecordingPath,
        'scheduledDelivery': scheduledDelivery,
      },
    );
  }
}
