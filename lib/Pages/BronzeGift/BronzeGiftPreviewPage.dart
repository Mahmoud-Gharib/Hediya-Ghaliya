import 'package:flutter/material.dart';

class BronzeGiftPreviewPage extends StatefulWidget {
  static const routeName = '/bronze-gift-preview';
  const BronzeGiftPreviewPage({super.key});

  @override
  State<BronzeGiftPreviewPage> createState() => _BronzeGiftPreviewPageState();
}

class _BronzeGiftPreviewPageState extends State<BronzeGiftPreviewPage>
    with TickerProviderStateMixin {
  
  late AnimationController _cardAnimationController;
  late AnimationController _textAnimationController;
  late AnimationController _mediaAnimationController;
  late Animation<double> _cardScaleAnimation;
  late Animation<double> _cardRotationAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _mediaFadeAnimation;
  
  Map<String, dynamic>? giftData;
  bool isOpened = false;
  int currentMediaIndex = 0;

  @override
  void initState() {
    super.initState();
    
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _textAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _mediaAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _cardScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _cardAnimationController, curve: Curves.elasticOut),
    );
    
    _cardRotationAnimation = Tween<double>(begin: 0.1, end: 0.0).animate(
      CurvedAnimation(parent: _cardAnimationController, curve: Curves.easeOutBack),
    );
    
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textAnimationController, curve: Curves.easeInOut),
    );
    
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textAnimationController, curve: Curves.easeOutBack));
    
    _mediaFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mediaAnimationController, curve: Curves.easeInOut),
    );
    
    _cardAnimationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      giftData = args;
    }
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _textAnimationController.dispose();
    _mediaAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF2C1810),
        appBar: AppBar(
          title: const Text('معاينة الهدية البرونزية', style: TextStyle(fontWeight: FontWeight.w800)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF2C1810),
                Color(0xFF3D2817),
                Color(0xFF4A3220),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!isOpened) ...[
                            _buildClosedGift(),
                            const SizedBox(height: 40),
                            _buildOpenButton(),
                          ] else ...[
                            _buildOpenedGift(),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                if (isOpened) _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClosedGift() {
    return AnimatedBuilder(
      animation: _cardAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _cardScaleAnimation.value,
          child: Transform.rotate(
            angle: _cardRotationAnimation.value,
            child: Container(
              width: 300,
              height: 380,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFCD7F32),
                    Color(0xFFD2691E),
                    Color(0xFFFF6347),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFCD7F32).withOpacity(0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // نمط الخلفية البرونزي
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.2),
                            Colors.transparent,
                            Colors.black.withOpacity(0.2),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // الشريطة البرونزية
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 70,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withOpacity(0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('🥉', style: TextStyle(fontSize: 28)),
                            SizedBox(width: 8),
                            Text('🎁', style: TextStyle(fontSize: 28)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // النص الرئيسي
                  Positioned(
                    bottom: 100,
                    left: 20,
                    right: 20,
                    child: Column(
                      children: [
                        const Text(
                          'هدية برونزية مميزة',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'إلى: ${giftData?['recipientName'] ?? 'صديقي العزيز'}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            '3 ملفات وسائط • تسجيل صوتي',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // تأثيرات لامعة برونزية
                  Positioned(
                    top: 120,
                    right: 30,
                    child: Container(
                      width: 25,
                      height: 25,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 180,
                    left: 40,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 240,
                    right: 50,
                    child: Container(
                      width: 15,
                      height: 15,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
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

  Widget _buildOpenButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _openGift,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🥉', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Icon(Icons.card_giftcard, color: Colors.white, size: 24),
            SizedBox(width: 12),
            Text(
              'افتح الهدية البرونزية',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpenedGift() {
    final mediaPaths = giftData?['mediaPaths'] as List<String>? ?? [];
    
    return FadeTransition(
      opacity: _textFadeAnimation,
      child: SlideTransition(
        position: _textSlideAnimation,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              // رأس الهدية البرونزية
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFCD7F32), Color(0xFFD2691E)],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    const Text('🥉', style: TextStyle(fontSize: 32)),
                    const SizedBox(width: 12),
                    const Text('🎁', style: TextStyle(fontSize: 32)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'هدية برونزية مميزة',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'إلى: ${giftData?['recipientName'] ?? 'صديقي العزيز'}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // الوسائط المتعددة
              if (mediaPaths.isNotEmpty) ...[
                FadeTransition(
                  opacity: _mediaFadeAnimation,
                  child: Container(
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.grey[100],
                    ),
                    child: Stack(
                      children: [
                        // معاينة الوسائط
                        Container(
                          width: double.infinity,
                          height: 250,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            image: const DecorationImage(
                              image: AssetImage('assets/images/placeholder.jpg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        
                        // مؤشر الوسائط
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${currentMediaIndex + 1}/${mediaPaths.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        
                        // أزرار التنقل
                        if (mediaPaths.length > 1) ...[
                          Positioned(
                            left: 12,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  onPressed: _previousMedia,
                                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 12,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  onPressed: _nextMedia,
                                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              
              // الرسالة
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8DC),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color(0xFFCD7F32).withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.message,
                          color: const Color(0xFFCD7F32),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'رسالة الهدية',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFCD7F32),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      giftData?['message'] ?? 'رسالة جميلة مليئة بالحب والمشاعر الطيبة مع المزيد من التفاصيل والكلمات المعبرة',
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: Color(0xFF2C3E50),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // التسجيل الصوتي
              if (giftData?['voicePath'] != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFCD7F32).withOpacity(0.1),
                        const Color(0xFFD2691E).withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: const Color(0xFFCD7F32).withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.mic,
                            color: const Color(0xFFCD7F32),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'رسالة صوتية شخصية',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFCD7F32),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFCD7F32),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: _playVoiceMessage,
                              icon: const Icon(Icons.play_arrow, color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: const Color(0xFFCD7F32).withOpacity(0.3),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: 0.4,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFCD7F32),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            '0:30',
                            style: TextStyle(
                              color: Color(0xFFCD7F32),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              
              // معلومات إضافية
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFCD7F32).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Text('🥉', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.favorite,
                      color: Colors.red[400],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'هدية برونزية مُرسلة بكل حب ❤️',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('سيتم تنفيذ المشاركة قريباً'),
                    backgroundColor: Color(0xFFCD7F32),
                  ),
                );
              },
              icon: const Icon(Icons.share),
              label: const Text('مشاركة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/my-gifts');
              },
              icon: const Icon(Icons.list),
              label: const Text('هداياي'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCD7F32),
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
    );
  }

  void _openGift() {
    setState(() {
      isOpened = true;
    });
    _textAnimationController.forward();
    _mediaAnimationController.forward();
  }

  void _previousMedia() {
    final mediaPaths = giftData?['mediaPaths'] as List<String>? ?? [];
    if (mediaPaths.isNotEmpty) {
      setState(() {
        currentMediaIndex = (currentMediaIndex - 1 + mediaPaths.length) % mediaPaths.length;
      });
    }
  }

  void _nextMedia() {
    final mediaPaths = giftData?['mediaPaths'] as List<String>? ?? [];
    if (mediaPaths.isNotEmpty) {
      setState(() {
        currentMediaIndex = (currentMediaIndex + 1) % mediaPaths.length;
      });
    }
  }

  void _playVoiceMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('يتم تشغيل الرسالة الصوتية'),
        backgroundColor: Color(0xFFCD7F32),
      ),
    );
  }
}
