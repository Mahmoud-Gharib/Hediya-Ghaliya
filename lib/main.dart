import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/navigation.dart';

import 'pages/sign_in_page.dart';
import 'pages/sign_up_page.dart';
import 'pages/home_page.dart';
import 'pages/create_gift_page.dart';
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

import 'models/package.dart';

Future<void> main() async 
{
  WidgetsFlutterBinding.ensureInitialized();
  // Load stored theme/lang
  final prefs = await SharedPreferences.getInstance();
  final themeStr = prefs.getString('themeMode');
  ThemeMode themeMode = ThemeMode.system;
  switch (themeStr) {
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

// Reusable animated gift box + popping heart logo
class GiftHeartLogo extends StatefulWidget {
  final double size;
  final bool autoPlay; // play opening animation automatically
  const GiftHeartLogo({super.key, this.size = 160, this.autoPlay = true});

  @override
  State<GiftHeartLogo> createState() => _GiftHeartLogoState();
}

class _GiftHeartLogoState extends State<GiftHeartLogo> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _lidOpen; // 0 (closed) -> 1 (open)
  late final Animation<double> _heartRise; // 0 -> 1
  late final Animation<double> _heartScale; // 0.6 -> 1.0 pop
  late final Animation<double> _sparkle; // 0..1 to blink

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));
    _lidOpen = CurvedAnimation(parent: _c, curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack));
    _heartRise = CurvedAnimation(parent: _c, curve: const Interval(0.35, 0.95, curve: Curves.easeOut));
    _heartScale = Tween(begin: 0.6, end: 1.0).animate(CurvedAnimation(parent: _c, curve: const Interval(0.35, 0.75, curve: Curves.elasticOut)));
    _sparkle = CurvedAnimation(parent: _c, curve: const Interval(0.6, 1.0, curve: Curves.easeInOut));

    if (widget.autoPlay) {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final boxSize = size;
    final lidHeight = size * 0.18;
    final heartSize = size * 0.55;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (!_c.isAnimating) {
          _c.forward(from: 0);
        }
      },
      child: SizedBox(
        width: boxSize,
        height: boxSize,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                // Bottom glow from the box
                Positioned(
                  left: boxSize * 0.12,
                  right: boxSize * 0.12,
                  bottom: boxSize * 0.08,
                  child: Container(
                    height: boxSize * 0.10,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(boxSize * 0.2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD54F).withOpacity(0.7 * _sparkle.value),
                          blurRadius: 28,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),

                // Gift box body
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: boxSize * 0.58,
                    decoration: BoxDecoration(
                      color: const Color(0xFF29B6F6),
                      borderRadius: BorderRadius.circular(18),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF29B6F6), Color(0xFF0288D1)],
                      ),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 18, offset: Offset(0, 8)),
                      ],
                    ),
                    child: Stack(children: [
                      // Vertical ribbon
                      Align(
                        alignment: Alignment.center,
                        child: Container(width: boxSize * 0.16, color: Colors.white.withOpacity(0.9)),
                      ),
                      // Bow (simplified)
                      Positioned(
                        top: boxSize * 0.02,
                        left: boxSize * 0.23,
                        child: _bow(size: boxSize * 0.2, color: Colors.white),
                      ),
                      // Inner rim (to add depth)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: boxSize * 0.04,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0277BD),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6, offset: const Offset(0, 2)),
                            ],
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),

                // Lid (3D rotate open)
                Positioned(
                  left: boxSize * 0.06,
                  right: boxSize * 0.06,
                  bottom: boxSize * 0.58,
                  child: Transform(
                    alignment: Alignment.bottomCenter,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.0015)
                      ..rotateX(-math.pi * 0.95 * _lidOpen.value),
                    child: Container(
                      height: lidHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF4FC3F7), Color(0xFF039BE5)],
                        ),
                        boxShadow: const [
                          BoxShadow(color: Colors.black54, blurRadius: 18, offset: Offset(0, 8)),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          height: lidHeight * 0.5,
                          width: boxSize * 0.4,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ),
                ),

                // Heart rising (clipped inside the box interior)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: ClipRect(
                    child: SizedBox(
                      height: boxSize * 0.60,
                      child: Stack(children: [
                        Positioned(
                          left: (boxSize - heartSize) / 2,
                          bottom: boxSize * (0.06 + 0.60 * _heartRise.value),
                          child: Transform.scale(
                            scale: _heartScale.value * (1 + 0.03 * math.sin(_c.value * 12.0)),
                            child: _gradientHeart(size: heartSize),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),

                // Sparkles
                ..._sparkles(boxSize),
                ..._burstStars(boxSize),
              ],
            );
          },
        ),
      ),
    );
  }

  // Simple ribbon bow using two rounded containers
  Widget _bow({required double size, required Color color}) {
    return SizedBox(
      width: size * 2.2,
      height: size * 1.1,
      child: Stack(children: [
        Positioned(
          left: 0,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(size)),
          ),
        ),
        Positioned(
          right: 0,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(size)),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Container(
            width: size * 0.5,
            height: size * 0.6,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(size * 0.3)),
          ),
        ),
      ]),
    );
  }

  Widget _gradientHeart({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(shape: BoxShape.circle, boxShadow: [
        BoxShadow(color: Color(0xFFFF80AB), blurRadius: 40, spreadRadius: 6),
      ]),
      child: ShaderMask(
        shaderCallback: (rect) => const LinearGradient(
          colors: [Color(0xFFFF4081), Color(0xFFFFC1E3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(rect),
        blendMode: BlendMode.srcATop,
        child: const Icon(Icons.favorite, size: 200, color: Colors.white),
      ),
    );
  }

  List<Widget> _sparkles(double boxSize) {
    final stars = <Widget>[];
    final positions = [
      const Offset(-0.35, 0.65),
      const Offset(0.38, 0.7),
      const Offset(-0.15, 0.95),
      const Offset(0.15, 0.95),
    ];
    for (var i = 0; i < positions.length; i++) {
      final o = positions[i];
      final opacity = ((math.sin((_sparkle.value + i * 0.5) * math.pi * 2) + 1) / 2) * 0.9;
      stars.add(Positioned(
        left: boxSize * (0.5 + o.dx) - 6,
        bottom: boxSize * (o.dy),
        child: Opacity(
          opacity: opacity,
          child: Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFFF176),
              boxShadow: [BoxShadow(color: Color(0xFFFFF59D), blurRadius: 10, spreadRadius: 2)],
            ),
          ),
        ),
      ));
    }
    return stars;
  }

  // Burst golden stars when the heart rises
  List<Widget> _burstStars(double boxSize) {
    final widgets = <Widget>[];
    final t = _heartRise.value;
    // Emit after the heart starts to rise
    if (t <= 0.15) return widgets;
    final count = 10;
    for (int i = 0; i < count; i++) {
      final angle = (i / count) * math.pi * 2;
      final radius = (0.05 + 0.25 * (t - 0.15)) * boxSize;
      final dx = math.cos(angle) * radius;
      final dy = math.sin(angle) * radius;
      final baseX = boxSize / 2;
      final baseY = boxSize * (0.30 + 0.25 * t);
      final opacity = (1.0 - (t - 0.15)).clamp(0.0, 1.0);
      widgets.add(Positioned(
        left: baseX + dx - 4,
        bottom: baseY + dy,
        child: Opacity(
          opacity: opacity,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFFD54F),
              boxShadow: [
                BoxShadow(color: Color(0xFFFFF59D), blurRadius: 10, spreadRadius: 1.5),
              ],
            ),
          ),
        ),
      ));
    }
    return widgets;
  }
}

// Simple pulsing logo using the static image asset
class LogoPulse extends StatefulWidget {
  final double size;
  final bool autoPlay;
  const LogoPulse({super.key, this.size = 160, this.autoPlay = true});

  @override
  State<LogoPulse> createState() => _LogoPulseState();
}

class _LogoPulseState extends State<LogoPulse> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
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
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

class HediyaGhaliaApp extends StatelessWidget {
  final ThemeMode initialThemeMode;
  final Locale initialLocale;
  const HediyaGhaliaApp({super.key, this.initialThemeMode = ThemeMode.system, this.initialLocale = const Locale('ar')});

  @override
  Widget build(BuildContext context) {
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
      },
    );
  }
}

// Splash with animated gradient + logo motion
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
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
    Timer(const Duration(seconds: 2), () async {
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                'إبداعك يتحوّل إلى هدية لا تُنسى',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WelcomePage extends StatefulWidget {
  static const routeName = '/welcome';
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  // Phrases
  final String _title = 'أهلًا بك في هدية غالية';
  final String _subtitle = 'حوّل مشاعرك إلى تجربة رقمية لا تُنسى — صور، رسائل، موسيقى، وذكريات في تطبيق واحد جميل.';

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 3800))..forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  List<Widget> _buildStaggeredWords({
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
  Widget build(BuildContext context) {
    // Timings
    const titleStart = 0.05;
    const titleStep = 0.06; // per word
    const subtitleStart = 0.55;
    const subtitleStep = 0.045;

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

class MyGiftsPage extends StatefulWidget {
  static const routeName = '/gifts';
  const MyGiftsPage({super.key});

  @override
  State<MyGiftsPage> createState() => _MyGiftsPageState();
}

class _MyGiftsPageState extends State<MyGiftsPage> {
  final String username = 'mahmoud-gharib';
  final String repo = 'app_upload';
  final String fileKeyword = 'apk';
  String? userPhone;

  int page = 1;
  bool isLoading = false;
  bool hasMore = true;

  final List<_ReleaseItem> _releases = [];
  List<_ReleaseItem> _filtered = [];

  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map && args['phone'] is String) {
        userPhone = args['phone'] as String;
      }
      fetchReleases();
    });
  }

  Future<void> fetchReleases() async {
    if (isLoading || !hasMore) return;
    setState(() => isLoading = true);

    final url = 'https://api.github.com/repos/$username/$repo/releases?page=$page&per_page=30';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (data.isEmpty) {
        hasMore = false;
      } else {
        for (final release in data) {
          final publishedAt = release['published_at'] as String? ?? '';
          final assets = (release['assets'] as List<dynamic>? ?? []);
          final matchedAssets = assets.where((asset) {
            final name = (asset['name'] as String? ?? '').toLowerCase();
            final phone = (userPhone ?? '').toLowerCase();
            return name.contains(fileKeyword.toLowerCase()) && (phone.isEmpty || name.contains(phone));
          }).toList();

          for (final asset in matchedAssets) {
            _releases.add(_ReleaseItem(
              dateIso: publishedAt,
              name: asset['name'] as String? ?? 'file',
              url: asset['browser_download_url'] as String? ?? '',
            ));
          }
        }
        page++;
      }
    }

    _applyFilter();
    if (mounted) setState(() => isLoading = false);
  }

  void _applyFilter() {
    if (selectedDate == null) {
      _filtered = List.from(_releases);
    } else {
      final target = DateFormat('yyyy-MM-dd').format(selectedDate!);
      _filtered = _releases.where((r) => r.dateIso.startsWith(target)).toList();
    }
    _filtered.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    if (mounted) setState(() {});
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(2020),
      lastDate: now,
      locale: const Locale('ar'),
    );
    if (picked != null) {
      selectedDate = picked;
      _applyFilter();
    }
  }

  Future<void> _download(String url) async {
    if (kIsWeb) {
      // On web, just open in new tab
      await launchUrlString(url, mode: LaunchMode.externalApplication);
      return;
    }

    if (Platform.isAndroid) {
      final status = await Permission.manageExternalStorage.request();
      if (!status.isGranted) {
        _snack('يجب السماح بصلاحية التخزين لتحميل الملف');
        return;
      }
      try {
        final downloads = Directory('/storage/emulated/0/Download');
        if (!downloads.existsSync()) downloads.createSync(recursive: true);
        final fileName = Uri.parse(url).pathSegments.last;
        final filePath = '${downloads.path}/$fileName';
        final dio = Dio();
        _snack('بدأ التحميل...');
        await dio.download(url, filePath);
        _snack('تم تحميل الملف: $fileName');
        await OpenFile.open(filePath);
      } catch (e) {
        _snack('فشل في تحميل الملف');
      }
      return;
    }

    // iOS or others: try default launcher
    final ok = await canLaunchUrl(Uri.parse(url));
    if (ok) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      _snack('تعذر فتح الرابط');
    }
  }

  Future<void> _shareFile(String url, String fileName) async {
    try {
      // على الويب: مشاركة الرابط مباشرة
      if (kIsWeb) {
        _snack('مشاركة رابط الملف...');
        
        final shareText = '''
🎁 هدية غالية من تطبيق "هدية غالية"

اسم الملف: $fileName
رابط التحميل: $url

تطبيق هدية غالية - أجمل الهدايا الرقمية
        '''.trim();
        
        await Share.share(
          shareText,
          subject: 'مشاركة هدية غالية',
        );
        
        _snack('تم مشاركة رابط الملف');
        return;
      }
      
      // على الموبايل: تحميل الملف ومشاركته
      _snack('جاري تحضير الملف للمشاركة...');
      
      // التحقق من صحة الرابط
      if (url.isEmpty) {
        _snack('رابط الملف غير صحيح');
        return;
      }
      
      // تحميل الملف مؤقتاً
      final dio = Dio();
      
      // إعداد خيارات Dio
      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(seconds: 60);
      dio.options.headers = {
        'User-Agent': 'HediyaGhaliya/1.0',
      };
      
      final tempDir = await getTemporaryDirectory();
      final cleanFileName = fileName.replaceAll(RegExp(r'[^\w\-_\.\u0600-\u06FF]'), '_');
      final tempFilePath = '${tempDir.path}/$cleanFileName';
      
      // حذف الملف إذا كان موجوداً مسبقاً
      final existingFile = File(tempFilePath);
      if (existingFile.existsSync()) {
        await existingFile.delete();
      }
      
      // تحميل الملف مع progress
      await dio.download(
        url, 
        tempFilePath,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
        ),
        onReceiveProgress: (received, total) {
          if (total > 0 && mounted) {
            final progress = (received / total * 100).toStringAsFixed(0);
            ScaffoldMessenger.of(context).clearSnackBars();
            _snack('تحميل: $progress%');
          }
        },
      );
      
      // التحقق من وجود الملف وحجمه
      final file = File(tempFilePath);
      if (!file.existsSync()) {
        _snack('فشل في حفظ الملف');
        return;
      }
      
      final fileSize = await file.length();
      if (fileSize == 0) {
        _snack('الملف فارغ أو تالف');
        return;
      }
      
      // مشاركة الملف
      ScaffoldMessenger.of(context).clearSnackBars();
      _snack('فتح نافذة المشاركة...');
      
      final result = await Share.shareXFiles(
        [XFile(tempFilePath)],
        text: 'هدية غالية من تطبيق "هدية غالية" 🎁\n\nاسم الملف: $fileName\nحجم الملف: ${(fileSize / 1024 / 1024).toStringAsFixed(1)} MB',
        subject: 'مشاركة هدية غالية',
      );
      
      // تنظيف الملف المؤقت بعد المشاركة
      try {
        await file.delete();
      } catch (_) {
        // تجاهل أخطاء الحذف
      }
      
      if (result.status == ShareResultStatus.success) {
        _snack('تم مشاركة الملف بنجاح');
      } else if (result.status == ShareResultStatus.dismissed) {
        _snack('تم إلغاء المشاركة');
      } else {
        _snack('فشل في المشاركة');
      }
      
    } catch (e) {
      String errorMsg = 'فشل في تحضير الملف للمشاركة';
      
      if (kIsWeb) {
        errorMsg = 'فشل في مشاركة الرابط';
      } else if (e.toString().contains('SocketException')) {
        errorMsg = 'خطأ في الاتصال بالإنترنت';
      } else if (e.toString().contains('TimeoutException')) {
        errorMsg = 'انتهت مهلة التحميل';
      } else if (e.toString().contains('404')) {
        errorMsg = 'الملف غير موجود';
      } else if (e.toString().contains('403')) {
        errorMsg = 'غير مسموح بالوصول للملف';
      }
      
      _snack(errorMsg);
      print('Share error: $e'); // للتشخيص
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = const TextStyle(fontWeight: FontWeight.w800);
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎁 هداياي الغالية', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.calendar_today), tooltip: 'اختيار تاريخ', onPressed: _pickDate),
          if (selectedDate != null)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'مسح الفلتر',
              onPressed: () {
                selectedDate = null;
                _applyFilter();
              },
            ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF311B92), Color(0xFF8E24AA), Color(0xFFFF6F61)],
            ),
          ),
        ),
      ),
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 6),
                Center(child: Icon(Icons.card_giftcard, size: 64, color: Colors.white.withOpacity(0.95))),
                const SizedBox(height: 10),
                Center(
                  child: Text('إصدارات الهدايا الخاصة بك', style: titleStyle.copyWith(color: Colors.white, fontSize: 20)),
                ),
                const SizedBox(height: 12),
                if (selectedDate != null)
                  Center(
                    child: Text(
                      '📅 ${DateFormat('yyyy-MM-dd').format(selectedDate!)}',
                      style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                    ),
                  ),
                const SizedBox(height: 12),
                Expanded(
                  child: _buildResponsiveTable(context),
                ),
                if (isLoading) ...[
                  const SizedBox(height: 12),
                  const Center(child: CircularProgressIndicator(color: Colors.white)),
                ]
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: hasMore && !isLoading
          ? FloatingActionButton.extended(
              onPressed: fetchReleases,
              icon: const Icon(Icons.more_horiz, color: Colors.white),
              label: const Text('تحميل المزيد', style: TextStyle(color: Colors.white)),
              backgroundColor: const Color(0xFFFF6F61),
            )
          : null,
    );
  }

  Widget _buildResponsiveTable(BuildContext context) {
    if (_filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.info_outline, size: 40, color: Colors.white70),
            SizedBox(height: 8),
            Text('لا توجد إصدارات متاحة', style: TextStyle(color: Colors.white70)),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Ultra-narrow screens: use compact list layout
        if (constraints.maxWidth < 420) {
          return _buildCompactList(context);
        }

        // DataTable with dynamic name column width to avoid overflow
        const dateColWidth = 112.0; // yyyy-MM-dd
        const timeColWidth = 92.0;  // hh:mm a
        const actionColWidth = 64.0; // icon button
        const shareColWidth = 64.0; // share button
        const paddings = 48.0; // margins within table rows
        final nameWidth = (constraints.maxWidth - dateColWidth - timeColWidth - actionColWidth - shareColWidth - paddings).clamp(140.0, 420.0);

        final columns = const [
          DataColumn(label: Text('الاسم')),
          DataColumn(label: Text('التاريخ')),
          DataColumn(label: Text('الوقت')),
          DataColumn(label: Text('تحميل')),
          DataColumn(label: Text('مشاركة')),
        ];
        final rows = _filtered.map((r) {
          final date = r.dateTime;
          final dateStr = DateFormat('yyyy-MM-dd').format(date);
          final timeStr = DateFormat('hh:mm a').format(date);
          final name = userPhone != null ? r.name.replaceAll(userPhone!, '').trim() : r.name;
          return DataRow(cells: [
            DataCell(SizedBox(width: nameWidth, child: Text(name, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white)))) ,
            DataCell(Text(dateStr, style: const TextStyle(color: Colors.white))),
            DataCell(Text(timeStr, style: const TextStyle(color: Colors.white))),
            DataCell(IconButton(icon: const Icon(Icons.download, color: Colors.amber), onPressed: () => _download(r.url))),
            DataCell(IconButton(icon: const Icon(Icons.share, color: Colors.lightBlue), onPressed: () => _shareFile(r.url, r.name))),
          ]);
        }).toList();

        final table = Theme(
          data: Theme.of(context).copyWith(
            cardColor: Colors.white.withOpacity(0.08),
            dividerColor: Colors.white24,
            dataTableTheme: DataTableThemeData(
              headingRowColor: WidgetStatePropertyAll(Colors.white.withOpacity(0.10)),
              dataRowColor: WidgetStatePropertyAll(Colors.white.withOpacity(0.06)),
              headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
              dataTextStyle: const TextStyle(color: Colors.white70),
            ),
          ),
          child: DataTable(columns: columns, rows: rows, columnSpacing: 12, horizontalMargin: 12),
        );

        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.18)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: table,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompactList(BuildContext context) {
    return ListView.separated(
      itemCount: _filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final r = _filtered[i];
        final dt = r.dateTime;
        final dateStr = DateFormat('yyyy-MM-dd').format(dt);
        final timeStr = DateFormat('hh:mm a').format(dt);
        final name = userPhone != null ? r.name.replaceAll(userPhone!, '').trim() : r.name;
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.16)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            leading: IconButton(
              icon: const Icon(Icons.download, color: Colors.amber),
              onPressed: () => _download(r.url),
              tooltip: 'تحميل',
            ),
            title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white)),
            subtitle: Text('$dateStr  •  $timeStr', style: const TextStyle(color: Colors.white70)),
            trailing: IconButton(
              icon: const Icon(Icons.share, color: Colors.lightBlue),
              onPressed: () => _shareFile(r.url, r.name),
              tooltip: 'مشاركة',
            ),
          ),
        );
      },
    );
  }
}

class _ReleaseItem {
  final String dateIso;
  final String name;
  final String url;
  const _ReleaseItem({required this.dateIso, required this.name, required this.url});
  DateTime get dateTime => DateTime.tryParse(dateIso)?.toLocal() ?? DateTime.fromMillisecondsSinceEpoch(0);
}

 
