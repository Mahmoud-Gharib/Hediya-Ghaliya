import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hediya_ghaliya/Pages/SplashPage.dart';
import 'package:hediya_ghaliya/Pages/WelcomePage.dart';
import 'package:hediya_ghaliya/Pages/SignInPage.dart';
import 'package:hediya_ghaliya/Pages/SignUpPage.dart';
import 'package:hediya_ghaliya/Pages/HomePage.dart';


/********************** Main *************************/

Future<void> main() async 
{
  WidgetsFlutterBinding.ensureInitialized();
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

/********************** HediyaGhaliaApp *************************/

class HediyaGhaliaApp extends StatelessWidget 
{
  final ThemeMode initialThemeMode;
  final Locale initialLocale;
  const HediyaGhaliaApp({super.key, this.initialThemeMode = ThemeMode.system, this.initialLocale = const Locale('ar')});

  @override
  Widget build(BuildContext context) 
  {
    ThemeMode themeMode = initialThemeMode;
    Locale locale = initialLocale;

    return MaterialApp
	(
      debugShowCheckedModeBanner: false,
      title: 'هدية غالية',
      //navigatorKey: appNavigatorKey,
      themeMode: themeMode,
      locale: locale,
      theme: ThemeData
	  (
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8E24AA)),
        useMaterial3: true,
        fontFamily: 'Arial',
      ),
      supportedLocales: const 
	  [
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const 
	  [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashPage(),
      routes: 
	  {
			WelcomePage.routeName: (_) => const WelcomePage(),
			SignInPage.routeName : (_) => const SignInPage (),
			SignUpPage.routeName : (_) => const SignUpPage (),
			HomePage.routeName   : (_) => const HomePage   (),

      },
    );
  }
}