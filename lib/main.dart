import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/navigation.dart';

import 'pages/sign_in_page.dart';
import 'pages/sign_up_page.dart';
import 'pages/home_page.dart';

import 'pages/create_gift_page.dart';
import 'pages/my_gifts_page.dart';

import 'pages/profile_page.dart';
import 'pages/notifications_page.dart';
import 'pages/about_page.dart';
import 'pages/chat/user_chat_page.dart';
import 'pages/chat/admin_chat_page.dart';

import 'pages/package_selection_page.dart';
import 'pages/SelectOccasionPage.dart';
import 'pages/SelectRelationshipPage.dart';
import 'pages/SelectColorPage.dart';
import 'pages/AppInfoPage.dart';
import 'pages/MessageInputPage.dart';
import 'pages/UploadImagesPage.dart';
import 'pages/UploadMusicPage.dart';
import 'pages/UploadVideoPage.dart';

import 'pages/PreviewGiftPage.dart';

import 'pages/free_gift_creator.dart';
import 'pages/latest_gift_page.dart';


Future<void> main() async 
{
  WidgetsFlutterBinding.ensureInitialized();
  // Load stored theme/lang
  final prefs = await SharedPreferences.getInstance();
  final themeStr = prefs.getString('themeMode');
  ThemeMode themeMode = ThemeMode.system;
  switch (themeStr) 
  {
    case 'light':
      themeMode = ThemeMode.light;
      break;
    case 'dark':
      themeMode = ThemeMode.dark;
      break;
    case 'system':
    default:
      themeMode = ThemeMode.system;
  }
  final lang = prefs.getString('appLang') ?? 'ar';
  final initialLocale = lang == 'en' ? const Locale('en') : const Locale('ar');
  runApp(HediyaGhaliaApp(initialThemeMode: themeMode, initialLocale: initialLocale));
}

// Simple pulsing logo using the static image asset
class LogoPulse extends StatefulWidget 
{
  final double size;
  final bool autoPlay;
  const LogoPulse({super.key, this.size = 160, this.autoPlay = true});

  @override
  State<LogoPulse> createState() => _LogoPulseState();
}

class _LogoPulseState extends State<LogoPulse> with SingleTickerProviderStateMixin 
{
  late final AnimationController _c;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() 
  {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.96, end: 1.04).chain(CurveTween(curve: Curves.easeOut)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.04, end: 0.96).chain(CurveTween(curve: Curves.easeIn)), weight: 50),
    ]).animate(_c);
    _opacity = Tween<double>(begin: 0.9, end: 1.0).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
    if (widget.autoPlay) {
      _c.repeat(reverse: true);
    }
  }

  @override
  void dispose() 
  {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) 
  {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.scale(
            scale: _scale.value,
            child: Image.asset(
              'assets/images/Logo.png',
              width: widget.size,
              height: widget.size,
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }
}

class HediyaGhaliaApp extends StatelessWidget 
{
  final ThemeMode initialThemeMode;
  final Locale initialLocale;
  const HediyaGhaliaApp({super.key, this.initialThemeMode = ThemeMode.system, this.initialLocale = const Locale('ar')});

  @override
  Widget build(BuildContext context) 
  {
    // Load saved theme and language at startup
    ThemeMode themeMode = initialThemeMode;
    Locale locale = initialLocale;

    // Pass theme and language to MaterialApp
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'هدية غالية',
      navigatorKey: appNavigatorKey,
      themeMode: themeMode,
      locale: locale,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8E24AA)),
        useMaterial3: true,
        fontFamily: 'Arial',
      ),
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashPage(),
      routes: {
        HomePage.routeName: (_) => const HomePage(),
        WelcomePage.routeName: (_) => const WelcomePage(),
        CreateGiftPage.routeName: (_) => const CreateGiftPage(),
        MyGiftsPage.routeName: (_) => const MyGiftsPage(),
        SignInPage.routeName: (_) => const SignInPage(),
        SignUpPage.routeName: (_) => const SignUpPage(),
        AboutPage.routeName: (_) => const AboutPage(),
        ProfilePage.routeName: (_) => const ProfilePage(),
        UserChatPage.routeName: (_) => const UserChatPage(),
        AdminChatPage.routeName: (_) => const AdminChatPage(),
        NotificationsPage.routeName: (_) => const NotificationsPage(),
        '/package-selection': (_) => const PackageSelectionPage(),
        '/select-occasion': (_) => SelectOccasionPage(),
        '/select-relationship': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return SelectRelationshipPage(
            occasionType: args?['occasionType'] ?? '',
          );
        },
        '/select-color': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return SelectColorPage(
            occasionType: args?['occasionType'] ?? '',
            recipientRelation: args?['recipientRelation'] ?? '',
          );
        },
        '/app-info': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return AppInfoPage(
            occasionType: args?['occasionType'] ?? '',
            recipientRelation: args?['recipientRelation'] ?? '',
            selectedColor: args?['selectedColor'] ?? '',
          );
        },
        '/message-input': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return MessageInputPage(
            occasionType: args?['occasionType'] ?? '',
            recipientRelation: args?['recipientRelation'] ?? '',
            appName: args?['appName'] ?? '',
            appIcon: args?['appIcon'] ?? File(''),
            selectedColor: args?['selectedColor'] ?? '',
          );
        },
        '/upload-images': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return UploadImagesPage(
            occasionType: args?['occasionType'] ?? '',
            recipientRelation: args?['recipientRelation'] ?? '',
            appName: args?['appName'] ?? '',
            appIcon: args?['appIcon'] ?? File(''),
            messageText: args?['messageText'] ?? '',
            selectedColor: args?['selectedColor'] ?? '',
          );
        },
        '/upload-music': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return UploadMusicPage(
            occasionType: args?['occasionType'] ?? '',
            recipientRelation: args?['recipientRelation'] ?? '',
            appName: args?['appName'] ?? '',
            appIcon: args?['appIcon'] ?? File(''),
            messageText: args?['messageText'] ?? '',
            images: args?['images'] ?? <File>[],
            imagesText: args?['imagesText'] ?? '',
            selectedColor: args?['selectedColor'] ?? '',
          );
        },
        '/upload-video': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return UploadVideoPage(
            occasionType: args?['occasionType'] ?? '',
            recipientRelation: args?['recipientRelation'] ?? '',
            appName: args?['appName'] ?? '',
            appIcon: args?['appIcon'] ?? File(''),
            messageText: args?['messageText'] ?? '',
            images: args?['images'] ?? <File>[],
            imagesText: args?['imagesText'] ?? '',
            musicFile: args?['musicFile'],
            musicText: args?['musicText'] ?? '',
            selectedColor: args?['selectedColor'] ?? '',
          );
        },
        '/preview-gift': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return PreviewGiftPage(
            occasionType: args?['occasionType'] ?? '',
            recipientRelation: args?['recipientRelation'] ?? '',
            appName: args?['appName'] ?? '',
            appIcon: args?['appIcon'],
            messageText: args?['messageText'] ?? '',
            images: args?['images'] ?? <File>[],
            imagesText: args?['imagesText'] ?? '',
            musicFile: args?['musicFile'],
            musicText: args?['musicText'] ?? '',
            videoFile: args?['videoFile'],
            videoText: args?['videoText'] ?? '',
            selectedColor: args?['selectedColor'] ?? '',
          );
        },
        '/free-gift-creator': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return FreeGiftCreatorPage(
            occasionType: args?['occasionType'],
            recipientRelation: args?['recipientRelation'],
            appName: args?['appName'],
            appIcon: args?['appIcon'],
            openingMessage: args?['openingMessage'],
            selectedImages: args?['selectedImages'],
          );
        },
        LatestGiftPage.routeName: (_) => const LatestGiftPage(),
      },
    );
  }
}

// Splash with animated gradient + logo motion
class SplashPage extends StatefulWidget 
{
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin 
{
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  Alignment _begin = Alignment.topLeft;
  Alignment _end = Alignment.bottomRight;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);
    _scale = Tween(begin: 0.85, end: 1.05).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _fade = Tween(begin: 0.6, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // subtle gradient drift
    Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() {
        _begin = _begin == Alignment.topLeft ? Alignment.topRight : Alignment.topLeft;
        _end = _end == Alignment.bottomRight ? Alignment.bottomLeft : Alignment.bottomRight;
      });
    });

    // Decide next route based on persisted login state after short splash
    Timer(const Duration(seconds: 5), () async {
      if (!mounted) return;
      final prefs = await SharedPreferences.getInstance();
      final loggedIn = prefs.getBool('logged_in') ?? false;
      final phone = prefs.getString('phone');
      if (loggedIn && phone != null && phone.isNotEmpty) {
        Navigator.of(context).pushReplacementNamed(HomePage.routeName, arguments: {'phone': phone});
      } else {
        Navigator.of(context).pushReplacementNamed(WelcomePage.routeName);
      }
    });
  }

  @override
  void dispose() 
  {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 900),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: _begin,
            end: _end,
            colors: const [
              Color(0xFF7B1FA2), // deep purple
              Color(0xFFE91E63), // pink
              Color(0xFFFFC107), // amber
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _scale,
                child: Opacity(
                  opacity: _fade.value,
                  child: const Hero(
                    tag: 'gift_logo',
                    child: LogoPulse(size: 180, autoPlay: true),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ShaderMask(
                shaderCallback: (rect) => const LinearGradient(colors: [Colors.white, Color(0xFFFFF59D)])
                    .createShader(Rect.fromLTWH(0, 0, rect.width, rect.height)),
                child: const Text(
                  'هدية غالية',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
				'لكل شخص غالي.....يستاهل هدية أغلي',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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

  // Phrases
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

  List<Widget> _buildStaggeredWords(
  {
    required String text,
    required double start,
    required double step,
    required TextStyle style,
    TextAlign align = TextAlign.center,
  }) {
    final words = text.split(' ');
    return List.generate(words.length, (i) {
      final begin = (start + i * step).clamp(0.0, 0.98);
      final end = (begin + step + 0.08).clamp(0.0, 1.0);
      final fade = CurvedAnimation(parent: _c, curve: Interval(begin, end, curve: Curves.easeOut));
      final slide = CurvedAnimation(parent: _c, curve: Interval(begin, end, curve: Curves.easeOutBack));
      return FadeTransition(
        opacity: fade,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0.0, 0.25), end: Offset.zero).animate(slide),
          child: Text(words[i], style: style, textAlign: align),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) 
  {
    // Timings
    const titleStart = 0.05;
    const titleStep = 0.06; // per word
    const subtitleStart = 0.275;
    const subtitleStep = 0.0225;

    final btn1Anim = CurvedAnimation(parent: _c, curve: const Interval(0.90, 1.00, curve: Curves.easeOutCubic));
    final btn2Anim = CurvedAnimation(parent: _c, curve: const Interval(0.94, 1.00, curve: Curves.easeOutCubic));

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF311B92), Color(0xFF8E24AA), Color(0xFFFF6F61)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Hero(
                      tag: 'gift_logo',
                      child: LogoPulse(size: 150, autoPlay: true),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Glass card with animated text
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 24, offset: const Offset(0, 12)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Title words
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 6,
                        runSpacing: 8,
                        children: _buildStaggeredWords(
                          text: _title,
                          start: titleStart,
                          step: titleStep,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Subtitle words
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 6,
                        runSpacing: 8,
                        children: _buildStaggeredWords(
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
                // Buttons appear after text finishes
                FadeTransition(
                  opacity: btn1Anim,
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(btn1Anim),
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, SignUpPage.routeName),
                      style: ElevatedButton.styleFrom(
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
                FadeTransition(
                  opacity: btn2Anim,
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero).animate(btn2Anim),
                    child: OutlinedButton(
                      onPressed: () => Navigator.pushNamed(context, SignInPage.routeName),
                      style: OutlinedButton.styleFrom(
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
    );
  }
}

