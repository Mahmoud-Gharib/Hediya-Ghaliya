import 'dart:io';
import 'package:flutter/material.dart';

/// صفحة إنشاء الهدية للباقة المجانية 🆓
class FreeGiftCreatorPage extends StatefulWidget {
  final String? occasionType;
  final String? recipientRelation;
  final String? appName;
  final File? appIcon;
  final String? openingMessage;
  final List<File>? selectedImages;

  const FreeGiftCreatorPage({
    super.key,
    this.occasionType,
    this.recipientRelation,
    this.appName,
    this.appIcon,
    this.openingMessage,
    this.selectedImages,
  });

  @override
  State<FreeGiftCreatorPage> createState() => _FreeGiftCreatorPageState();
}

class _FreeGiftCreatorPageState extends State<FreeGiftCreatorPage> {
  final _messageController = TextEditingController();
  final _senderNameController = TextEditingController();
  final _receiverNameController = TextEditingController();
  
  int _currentWordCount = 0;
  static const int _maxWords = 200;

  @override
  void initState() {
    super.initState();
    // Initialize with data from previous steps if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        setState(() {
          if (widget.openingMessage != null) {
            _messageController.text = widget.openingMessage!;
          } else if (args['openingMessage'] != null) {
            _messageController.text = args['openingMessage'];
          }
        });
      }
    });
    _messageController.addListener(_updateWordCount);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _senderNameController.dispose();
    _receiverNameController.dispose();
    super.dispose();
  }

  void _updateWordCount() {
    final text = _messageController.text.trim();
    final words = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
    setState(() {
      _currentWordCount = words;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          '🆓 إنشاء هدية مجانية',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF48BB78),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // معلومات التطبيق
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (widget.appIcon != null && widget.appIcon!.existsSync())
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            widget.appIcon!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6B46C1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.apps,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.appName ?? 'اسم التطبيق',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${widget.occasionType ?? 'المناسبة'} • ${widget.recipientRelation ?? 'العلاقة'}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (widget.selectedImages != null && widget.selectedImages!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'الصور المرفقة:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B46C1),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.selectedImages!.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(left: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                widget.selectedImages![index],
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // معلومات المرسل والمستقبل
            _buildSectionTitle('👥 معلومات الهدية'),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _senderNameController,
                    label: 'اسم المرسل',
                    hint: 'مثال: أحمد',
                    icon: Icons.person,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _receiverNameController,
                    label: 'اسم المستقبل',
                    hint: 'مثال: فاطمة',
                    icon: Icons.person_outline,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // كتابة الرسالة
            _buildSectionTitle('✍️ رسالتك (الخط الافتراضي - اللون الأسود)'),
            const SizedBox(height: 12),
            
            _buildMessageField(),

            const SizedBox(height: 24),

            // معاينة الخلفية الافتراضية
            _buildBackgroundPreview(),

            const SizedBox(height: 24),

            // قيود الباقة المجانية
            _buildLimitations(),

            const SizedBox(height: 32),

            // أزرار العمل
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2D3748),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        textDirection: TextDirection.rtl,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF48BB78)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          labelStyle: const TextStyle(color: Color(0xFF4A5568)),
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildMessageField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _currentWordCount > _maxWords 
              ? Colors.red 
              : Colors.grey.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // عداد الكلمات
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _currentWordCount > _maxWords 
                  ? Colors.red.shade50 
                  : Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'عدد الكلمات:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                Text(
                  '$_currentWordCount / $_maxWords',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _currentWordCount > _maxWords 
                        ? Colors.red 
                        : const Color(0xFF48BB78),
                  ),
                ),
              ],
            ),
          ),
          
          // حقل النص
          TextField(
            controller: _messageController,
            maxLines: 8,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black, // اللون الأسود فقط
              fontFamily: 'Arial', // الخط الافتراضي
              height: 1.5,
            ),
            decoration: const InputDecoration(
              hintText: 'اكتب رسالتك هنا...\nمثال: عزيزتي فاطمة، أتمنى لك عيد ميلاد سعيد...',
              hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('🖼️ الخلفية الافتراضية (غير قابلة للتغيير)'),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE6FFFA), Color(0xFFB2F5EA)],
            ),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.card_giftcard, size: 32, color: Color(0xFF48BB78)),
                SizedBox(height: 4),
                Text(
                  'خلفية افتراضية ثابتة',
                  style: TextStyle(fontSize: 12, color: Color(0xFF2D3748)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLimitations() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: Colors.orange.shade600),
              const SizedBox(width: 8),
              const Text(
                'قيود الباقة المجانية:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '❌ لا يمكن إضافة صور\n'
            '❌ لا يمكن إضافة موسيقى\n'
            '❌ لا يمكن إضافة فيديو\n'
            '❌ لا يمكن تغيير الخطوط أو الألوان\n'
            '❌ لا يوجد توليد APK\n'
            '✅ معاينة مباشرة داخل التطبيق فقط',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF4A5568),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _canPreview() ? _showPreview : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF48BB78),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              '👁️ معاينة الهدية',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/package-selection'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              '⬆️ ترقية الباقة',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool _canPreview() {
    return _senderNameController.text.trim().isNotEmpty &&
           _receiverNameController.text.trim().isNotEmpty &&
           _messageController.text.trim().isNotEmpty &&
           _currentWordCount <= _maxWords;
  }

  void _showPreview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FreeGiftPreviewPage(
          senderName: _senderNameController.text.trim(),
          receiverName: _receiverNameController.text.trim(),
          message: _messageController.text.trim(),
        ),
      ),
    );
  }
}

/// صفحة معاينة الهدية المجانية 👁️
class FreeGiftPreviewPage extends StatelessWidget {
  final String senderName;
  final String receiverName;
  final String message;

  const FreeGiftPreviewPage({
    super.key,
    required this.senderName,
    required this.receiverName,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          '👁️ معاينة الهدية المجانية',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE6FFFA), Color(0xFFB2F5EA)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.card_giftcard,
                  size: 64,
                  color: Color(0xFF48BB78),
                ),
                const SizedBox(height: 16),
                Text(
                  'إلى: $receiverName',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                    fontFamily: 'Arial',
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    message,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontFamily: 'Arial',
                      height: 1.6,
                    ),
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'من: $senderName ❤️',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A5568),
                    fontFamily: 'Arial',
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF48BB78).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '🆓 باقة مجانية - هدية غالية',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF48BB78),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'رجوع للتعديل',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/package-selection'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '⬆️ ترقية للحصول على APK',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
