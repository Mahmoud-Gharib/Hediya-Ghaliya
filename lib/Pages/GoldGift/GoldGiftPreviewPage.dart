import 'package:flutter/material.dart';

class GoldGiftPreviewPage extends StatefulWidget {
  static const routeName = '/gold-gift-preview';
  const GoldGiftPreviewPage({super.key});

  @override
  State<GoldGiftPreviewPage> createState() => _GoldGiftPreviewPageState();
}

class _GoldGiftPreviewPageState extends State<GoldGiftPreviewPage>
    with TickerProviderStateMixin {
  
  late AnimationController _cardAnimationController;
  late AnimationController _textAnimationController;
  late AnimationController _musicAnimationController;
  late AnimationController _crownAnimationController;
  late Animation<double> _cardScaleAnimation;
  late Animation<double> _cardRotationAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _musicFadeAnimation;
  late Animation<double> _crownRotationAnimation;
  
  Map<String, dynamic>? giftData;
  bool isOpened = false;
  int currentMediaIndex = 0;
  bool isMusicPlaying = false;
  bool isVoicePlaying = false;

  @override
  void initState() {
    super.initState();
    
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _textAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _musicAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _crownAnimationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _cardScaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _cardAnimationController, curve: Curves.elasticOut),
    );
    
    _cardRotationAnimation = Tween<double>(begin: 0.15, end: 0.0).animate(
      CurvedAnimation(parent: _cardAnimationController, curve: Curves.easeOutBack),
    );
    
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textAnimationController, curve: Curves.easeInOut),
    );
    
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textAnimationController, curve: Curves.easeOutBack));
    
    _musicFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _musicAnimationController, curve: Curves.easeInOut),
    );
    
    _crownRotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _crownAnimationController, curve: Curves.linear),
    );
    
    _cardAnimationController.forward();
    _crownAnimationController.repeat();
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
    _crownAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A1A),
        appBar: AppBar(
          title: const Text('معاينة الهدية الملكية', style: TextStyle(fontWeight: FontWeight.w800)),
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
                Color(0xFF1A1A1A),
                Color(0xFF2C1810),
                Color(0xFF3D2914),
                Color(0xFFB8860B),
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
                            const SizedBox(height: 50),
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
              width: 350,
              height: 450,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFD700),
                    Color(0xFFFFA500),
                    Color(0xFFFF8C00),
                    Color(0xFFB8860B),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.6),
                    blurRadius: 50,
                    offset: const Offset(0, 25),
                  ),
                  BoxShadow(
                    color: const Color(0xFFFFA500).withOpacity(0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // نمط الخلفية الذهبية المتقدم
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.5),
                            Colors.transparent,
                            Colors.black.withOpacity(0.2),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // الشريطة الذهبية الملكية
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFA500), Color(0xFFFFD700)],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withOpacity(0.8),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedBuilder(
                              animation: _crownAnimationController,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _crownRotationAnimation.value * 0.1,
                                  child: const Text('👑', style: TextStyle(fontSize: 40)),
                                );
                              },
                            ),
                            const SizedBox(width: 12),
                            const Text('🎁', style: TextStyle(fontSize: 40)),
                            const SizedBox(width: 12),
                            const Text('💎', style: TextStyle(fontSize: 36)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // النص الرئيسي الملكي
                  Positioned(
                    bottom: 140,
                    left: 20,
                    right: 20,
                    child: Column(
                      children: [
                        const Text(
                          'هدية ملكية حصرية',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 10,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'إلى: ${giftData?['recipientName'] ?? 'الشخص المميز'}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                          child: const Text(
                            '👑 ملفات غير محدودة • موسيقى مخصصة • تسجيل صوتي • 365 يوم',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // تأثيرات لامعة ذهبية متقدمة
                  Positioned(
                    top: 160,
                    right: 30,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withOpacity(0.5),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 240,
                    left: 40,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFA500).withOpacity(0.4),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 320,
                    right: 50,
                    child: Container(
                      width: 25,
                      height: 25,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF8C00).withOpacity(0.3),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // تأثيرات ماسية إضافية
                  Positioned(
                    top: 200,
                    left: 60,
                    child: Transform.rotate(
                      angle: 0.5,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 280,
                    left: 80,
                    child: Transform.rotate(
                      angle: 1.0,
                      child: Container(
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(3),
                        ),
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
          colors: [Color(0xFFFFA500), Color(0xFFFFD700)],
        ),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.6),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _openGift,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(35),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('👑', style: TextStyle(fontSize: 28)),
            SizedBox(width: 12),
            Text('💎', style: TextStyle(fontSize: 24)),
            SizedBox(width: 16),
            Icon(Icons.card_giftcard, color: Colors.white, size: 32),
            SizedBox(width: 20),
            Text(
              'افتح الهدية الملكية',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // This builds the gift content when it's opened
Widget _buildOpenedGift() {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.card_giftcard, size: 100, color: Colors.amber),
        SizedBox(height: 20),
        Text(
          "Your Golden Gift 🎁",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}

// This builds action buttons after the gift is opened
Widget _buildActionButtons() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      ElevatedButton(
        onPressed: () {
          // Example action
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Action 1 pressed")),
          );
        },
        child: Text("Action 1"),
      ),
      SizedBox(width: 10),
      ElevatedButton(
        onPressed: () {
          // Example action
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Action 2 pressed")),
          );
        },
        child: Text("Action 2"),
      ),
    ],
  );
}

// This handles the "open gift" button press
void _openGift() {
  setState(() {
    isOpened = true; // assume you have a bool variable called isOpened
  });
}

}
