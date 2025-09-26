import 'package:flutter/material.dart';

import 'package:hediya_ghaliya/Pages/SplashPage.dart';
import 'package:hediya_ghaliya/Pages/SignInPage.dart';
import 'package:hediya_ghaliya/Pages/SignUpPage.dart';

/********************** WelcomePage *************************/

class WelcomePage extends StatefulWidget 
{
  static const routeName = '/welcome';
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with SingleTickerProviderStateMixin 
{
  late final AnimationController _c;

  final String _title = 'أهلًا بك في هدية غالية';
  final String _subtitle = 'هنا تقدر تعمل هدية غالية ل شخص غالي عليك بطريقه مختلفه و مميزه , عبر عن مشاعرك ب كلمات, صور، .موسيقى، فيديو في شكل تطبيق جميل';

  @override
  void initState() 
  {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 3800))..forward();
  }

  @override
  void dispose() 
  {
    _c.dispose();
    super.dispose();
  }

  List<Widget> _buildStaggeredWords
  (
   {
    required String text,
    required double start,
    required double step,
    required TextStyle style,
    TextAlign align = TextAlign.center,
   }
  ) 
  {
    final words = text.split(' ');
    return List.generate(words.length, (i) 
	{
      final begin = (start + i * step).clamp(0.0, 0.98);
      final end = (begin + step + 0.08).clamp(0.0, 1.0);
      final fade = CurvedAnimation(parent: _c, curve: Interval(begin, end, curve: Curves.easeOut));
      final slide = CurvedAnimation(parent: _c, curve: Interval(begin, end, curve: Curves.easeOutBack));
      return FadeTransition
	  (
        opacity: fade,
        child: SlideTransition
		(
          position: Tween<Offset>(begin: const Offset(0.0, 0.25), end: Offset.zero).animate(slide),
          child: Text(words[i], style: style, textAlign: align),
        ),
      );
    }
	);
  }

  @override
  Widget build(BuildContext context) 
  {
    const titleStart = 0.05;
    const titleStep = 0.06; 
    const subtitleStart = 0.275;
    const subtitleStep = 0.0225;

    final btn1Anim = CurvedAnimation(parent: _c, curve: const Interval(0.90, 1.00, curve: Curves.easeOutCubic));
    final btn2Anim = CurvedAnimation(parent: _c, curve: const Interval(0.94, 1.00, curve: Curves.easeOutCubic));

    return Scaffold
	(
      body: Container
	  (
        decoration: const BoxDecoration
		(
          gradient: LinearGradient
		  (
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF311B92), Color(0xFF8E24AA), Color(0xFFFF6F61)],
          ),
        ),
        child: SafeArea
		(
          child: SingleChildScrollView
		  (
            child: ConstrainedBox
			(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight
			  (
                child: Padding
				(
                  padding: const EdgeInsets.all(20.0),
                  child: Column
				  (
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: 
					[
                const SizedBox(height: 12),
                Row
				(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const 
				  [
                    Hero
					(
                      tag: 'welcome_logo',
                      child: LogoPulse(size: 150, autoPlay: true),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container
				(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration
				  (
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                    boxShadow: 
					[
                      BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 24, offset: const Offset(0, 12)),
                    ],
                  ),
                  child: Column
				  (
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: 
					[
                      Wrap
					  (
                        alignment: WrapAlignment.center,
                        spacing: 6,
                        runSpacing: 8,
                        children: _buildStaggeredWords
						(
                          text: _title,
                          start: titleStart,
                          step: titleStep,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap
					  (
                        alignment: WrapAlignment.center,
                        spacing: 6,
                        runSpacing: 8,
                        children: _buildStaggeredWords
						(
                          text: _subtitle,
                          start: subtitleStart,
                          step: subtitleStep,
                          style: const TextStyle(fontSize: 16, color: Colors.white70, height: 1.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                FadeTransition
				(
                  opacity: btn1Anim,
                  child: SlideTransition
				  (
                    position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(btn1Anim),
                    child: ElevatedButton
					(
                      onPressed: () => Navigator.pushNamed(context, SignUpPage.routeName),
                      style: ElevatedButton.styleFrom
					  (
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        elevation: 8,
                        shadowColor: Colors.black.withOpacity(0.3),
                      ),
                      child: const Text('إنشاء حساب', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FadeTransition
				(
                  opacity: btn2Anim,
                  child: SlideTransition
				  (
                    position: Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero).animate(btn2Anim),
                    child: OutlinedButton
					(
                      onPressed: () => Navigator.pushNamed(context, SignInPage.routeName),
                      style: OutlinedButton.styleFrom
					  (
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        side: const BorderSide(color: Colors.white, width: 1.5),
                      ),
                      child: const Text('تسجيل دخول', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
