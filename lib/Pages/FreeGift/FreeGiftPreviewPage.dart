import 'package:flutter/material.dart';

class FreeGiftPreviewPage extends StatefulWidget {
  static const routeName = '/free-gift-preview';
  const FreeGiftPreviewPage({super.key});

  @override
  State<FreeGiftPreviewPage> createState() => _FreeGiftPreviewPageState();
}

class _FreeGiftPreviewPageState extends State<FreeGiftPreviewPage>
    with TickerProviderStateMixin {
  
  late AnimationController _cardAnimationController;
  late AnimationController _textAnimationController;
  late Animation<double> _cardScaleAnimation;
  late Animation<double> _cardRotationAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  
  Map<String, dynamic>? giftData;
  bool isOpened = false;

  @override
  void initState() {
    super.initState();
    
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _textAnimationController = AnimationController(
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        appBar: AppBar(
          title: const Text('معاينة الهدية', style: TextStyle(fontWeight: FontWeight.w800)),
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
                Color(0xFF1A1A2E),
                Color(0xFF16213E),
                Color(0xFF0F3460),
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
              width: 280,
              height: 350,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF9C27B0),
                    Color(0xFFE91E63),
                    Color(0xFFFF6F61),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9C27B0).withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // نمط الخلفية
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
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
                  
                  // الشريطة
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '🎁',
                          style: TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                  ),
                  
                  // النص الرئيسي
                  Positioned(
                    bottom: 80,
                    left: 20,
                    right: 20,
                    child: Column(
                      children: [
                        const Text(
                          'هدية خاصة',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'إلى: ${giftData?['recipientName'] ?? 'صديقي العزيز'}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  // تأثيرات لامعة
                  Positioned(
                    top: 100,
                    right: 30,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 150,
                    left: 40,
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
            Icon(Icons.card_giftcard, color: Colors.white, size: 24),
            SizedBox(width: 12),
            Text(
              'افتح الهدية',
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
              // رأس الهدية
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9C27B0), Color(0xFFE91E63)],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    const Text('🎁', style: TextStyle(fontSize: 32)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'هدية مجانية',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'إلى: ${giftData?['recipientName'] ?? 'صديقي العزيز'}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // الصورة (إن وجدت)
              if (giftData?['imagePath'] != null) ...[
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/placeholder.jpg'), // مؤقت
                      fit: BoxFit.cover,
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
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color(0xFF9C27B0).withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.message,
                          color: const Color(0xFF9C27B0),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'رسالة الهدية',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF9C27B0),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      giftData?['message'] ?? 'رسالة جميلة مليئة بالحب والمشاعر الطيبة',
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
              
              // معلومات إضافية
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF9C27B0).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      color: Colors.red[400],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'هدية مُرسلة بكل حب ❤️',
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
                // TODO: مشاركة الهدية
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('سيتم تنفيذ المشاركة قريباً'),
                    backgroundColor: Color(0xFF9C27B0),
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
    );
  }

  void _openGift() {
    setState(() {
      isOpened = true;
    });
    _textAnimationController.forward();
    
    // تأثير اهتزاز للهاتف (إن أمكن)
    // HapticFeedback.heavyImpact();
  }
}
