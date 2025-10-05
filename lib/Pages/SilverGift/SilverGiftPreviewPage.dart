import 'package:flutter/material.dart';

class SilverGiftPreviewPage extends StatefulWidget {
  static const routeName = '/silver-gift-preview';
  const SilverGiftPreviewPage({super.key});

  @override
  State<SilverGiftPreviewPage> createState() => _SilverGiftPreviewPageState();
}

class _SilverGiftPreviewPageState extends State<SilverGiftPreviewPage>
    with TickerProviderStateMixin {
  
  late AnimationController _cardAnimationController;
  late AnimationController _textAnimationController;
  late AnimationController _musicAnimationController;
  late Animation<double> _cardScaleAnimation;
  late Animation<double> _cardRotationAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _musicFadeAnimation;
  
  Map<String, dynamic>? giftData;
  bool isOpened = false;
  int currentMediaIndex = 0;
  bool isMusicPlaying = false;

  @override
  void initState() {
    super.initState();
    
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _textAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _musicAnimationController = AnimationController(
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
    
    _musicFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _musicAnimationController, curve: Curves.easeInOut),
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
    _musicAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF2F4F4F),
        appBar: AppBar(
          title: const Text('معاينة الهدية الفضية', style: TextStyle(fontWeight: FontWeight.w800)),
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
                Color(0xFF2F4F4F),
                Color(0xFF708090),
                Color(0xFFB0C4DE),
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
              width: 320,
              height: 400,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFC0C0C0),
                    Color(0xFFE5E5E5),
                    Color(0xFFB0C4DE),
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFC0C0C0).withOpacity(0.5),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // نمط الخلفية الفضية المتقدم
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
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
                  
                  // الشريطة الفضية الفاخرة
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE5E5E5), Color(0xFFC0C0C0)],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFC0C0C0).withOpacity(0.6),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('🥈', style: TextStyle(fontSize: 32)),
                            SizedBox(width: 12),
                            Text('🎁', style: TextStyle(fontSize: 32)),
                            SizedBox(width: 12),
                            Text('🎵', style: TextStyle(fontSize: 28)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // النص الرئيسي
                  Positioned(
                    bottom: 120,
                    left: 20,
                    right: 20,
                    child: Column(
                      children: [
                        const Text(
                          'هدية فضية فاخرة',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'إلى: ${giftData?['recipientName'] ?? 'صديقي العزيز'}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '5 ملفات وسائط • موسيقى • جدولة',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // تأثيرات لامعة فضية متقدمة
                  Positioned(
                    top: 140,
                    right: 40,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 200,
                    left: 50,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 280,
                    right: 60,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
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
          colors: [Color(0xFFE5E5E5), Color(0xFFC0C0C0)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC0C0C0).withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _openGift,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🥈', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text('🎵', style: TextStyle(fontSize: 20)),
            SizedBox(width: 12),
            Icon(Icons.card_giftcard, color: Colors.white, size: 28),
            SizedBox(width: 16),
            Text(
              'افتح الهدية الفضية',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
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
          padding: const EdgeInsets.all(35),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 25,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            children: [
              // رأس الهدية الفضية
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFC0C0C0), Color(0xFFE5E5E5)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Text('🥈', style: TextStyle(fontSize: 36)),
                    const SizedBox(width: 12),
                    const Text('🎁', style: TextStyle(fontSize: 36)),
                    const SizedBox(width: 12),
                    const Text('🎵', style: TextStyle(fontSize: 32)),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'هدية فضية فاخرة',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'إلى: ${giftData?['recipientName'] ?? 'صديقي العزيز'}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // الموسيقى الخلفية
              if (giftData?['musicPath'] != null && giftData?['musicPath'] != 'بدون موسيقى') ...[
                FadeTransition(
                  opacity: _musicFadeAnimation,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFC0C0C0).withOpacity(0.1),
                          const Color(0xFFE5E5E5).withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: const Color(0xFFC0C0C0).withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Text('🎵', style: TextStyle(fontSize: 24)),
                            const SizedBox(width: 12),
                            const Text(
                              'موسيقى خلفية',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF708090),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: isMusicPlaying ? Colors.red : const Color(0xFFC0C0C0),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                onPressed: _toggleMusic,
                                icon: Icon(
                                  isMusicPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    giftData?['musicPath'] ?? 'موسيقى جميلة',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF708090),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFC0C0C0).withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: isMusicPlaying ? 0.6 : 0.0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFC0C0C0),
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
              
              // الوسائط المتعددة
              if (mediaPaths.isNotEmpty) ...[
                Container(
                  height: 280,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey[100],
                  ),
                  child: Stack(
                    children: [
                      // معاينة الوسائط
                      Container(
                        width: double.infinity,
                        height: 280,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: const DecorationImage(
                            image: AssetImage('assets/images/placeholder.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      
                      // مؤشر الوسائط المحسن
                      Positioned(
                        top: 15,
                        right: 15,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            '${currentMediaIndex + 1}/${mediaPaths.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      
                      // أزرار التنقل المحسنة
                      if (mediaPaths.length > 1) ...[
                        Positioned(
                          left: 15,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFC0C0C0).withOpacity(0.8),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                onPressed: _previousMedia,
                                icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 15,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFC0C0C0).withOpacity(0.8),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                onPressed: _nextMedia,
                                icon: const Icon(Icons.chevron_right, color: Colors.white, size: 28),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
              
              // الرسالة المفصلة
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFC0C0C0).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.message,
                          color: const Color(0xFF708090),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'رسالة الهدية',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF708090),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      giftData?['message'] ?? 'رسالة جميلة ومفصلة مليئة بالحب والمشاعر الطيبة مع المزيد من التفاصيل والكلمات المعبرة التي تحمل في طياتها أجمل المعاني',
                      style: const TextStyle(
                        fontSize: 18,
                        height: 1.8,
                        color: Color(0xFF2C3E50),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // معلومات الجدولة
              if (giftData?['scheduledDelivery'] != null) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC0C0C0).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      const Text('⏰', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.schedule,
                        color: const Color(0xFF708090),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'تم جدولة الإرسال في الوقت المحدد',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF666666),
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
              
              // معلومات إضافية
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFC0C0C0).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    const Text('🥈', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.favorite,
                      color: Colors.red[400],
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'هدية فضية فاخرة مُرسلة بكل حب ❤️',
                        style: TextStyle(
                          fontSize: 16,
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
                    backgroundColor: Color(0xFFC0C0C0),
                  ),
                );
              },
              icon: const Icon(Icons.share),
              label: const Text('مشاركة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
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
                backgroundColor: const Color(0xFFC0C0C0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
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
    _musicAnimationController.forward();
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

  void _toggleMusic() {
    setState(() {
      isMusicPlaying = !isMusicPlaying;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isMusicPlaying ? 'تم تشغيل الموسيقى' : 'تم إيقاف الموسيقى'),
        backgroundColor: const Color(0xFFC0C0C0),
      ),
    );
  }
}
