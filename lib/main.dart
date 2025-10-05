import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:hediya_ghaliya/Pages/SplashPage.dart';
import 'package:hediya_ghaliya/Pages/WelcomePage.dart';
import 'package:hediya_ghaliya/Pages/SignInPage.dart';
import 'package:hediya_ghaliya/Pages/SignUpPage.dart';
import 'package:hediya_ghaliya/Pages/HomePage.dart';

import 'package:hediya_ghaliya/Pages/ProfilePage.dart';
import 'package:hediya_ghaliya/Pages/AboutPage.dart';

import 'package:hediya_ghaliya/Pages/CreateGiftPage.dart';
import 'package:hediya_ghaliya/Pages/MyGiftsPage.dart';
import 'package:hediya_ghaliya/Pages/LatestGiftPage.dart';

import 'package:hediya_ghaliya/Pages/GiftPackageDetailsPage.dart';

import 'package:hediya_ghaliya/Pages/FreeGift/FreeGiftDesignPage.dart';
import 'package:hediya_ghaliya/Pages/FreeGift/FreeGiftPreviewPage.dart';
import 'package:hediya_ghaliya/Pages/FreeGift/FreeGiftTemplatesPage.dart';

import 'package:hediya_ghaliya/Pages/BronzeGift/BronzeGiftDesignPage.dart';
import 'package:hediya_ghaliya/Pages/BronzeGift/BronzeGiftPreviewPage.dart';
import 'package:hediya_ghaliya/Pages/BronzeGift/BronzeGiftTemplatesPage.dart';

import 'package:hediya_ghaliya/Pages/SilverGift/SilverGiftTemplatesPage.dart';
import 'package:hediya_ghaliya/Pages/SilverGift/SilverGiftDesignPage.dart';
import 'package:hediya_ghaliya/Pages/SilverGift/SilverGiftPreviewPage.dart';

import 'package:hediya_ghaliya/Pages/GoldGift/GoldGiftTemplatesPage.dart';
import 'package:hediya_ghaliya/Pages/GoldGift/GoldGiftDesignPage.dart';
import 'package:hediya_ghaliya/Pages/GoldGift/GoldGiftPreviewPage.dart';

import 'package:hediya_ghaliya/Services/Navigation.dart';

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
      navigatorKey: appNavigatorKey,
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
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashPage(),
      routes: 
	  {
		WelcomePage.routeName: (_) => const WelcomePage(),
		SignInPage.routeName : (_) => const SignInPage (),
		SignUpPage.routeName : (_) => const SignUpPage (),
		HomePage.routeName   : (_) => const HomePage   (),
		
		ProfilePage.routeName: (_) => const ProfilePage(),
		AboutPage.routeName  : (_) => const AboutPage  (),
		
		CreateGiftPage.routeName: (_) => const CreateGiftPage(),
		MyGiftsPage.routeName:    (_) => const MyGiftsPage   (),
		LatestGiftPage.routeName: (_) => const LatestGiftPage(),
		
		GiftPackageDetailsPage.routeName: (_) => const GiftPackageDetailsPage(),
		
		FreeGiftDesignPage.routeName:    (_) => const FreeGiftDesignPage   (),
		FreeGiftPreviewPage.routeName:   (_) => const FreeGiftPreviewPage  (),
		FreeGiftTemplatesPage.routeName: (_) => const FreeGiftTemplatesPage(),
		
		BronzeGiftDesignPage.routeName:    (_) => const BronzeGiftDesignPage   (),
		BronzeGiftPreviewPage.routeName:   (_) => const BronzeGiftPreviewPage  (),
		BronzeGiftTemplatesPage.routeName: (_) => const BronzeGiftTemplatesPage(),

		SilverGiftTemplatesPage.routeName: (_) => const SilverGiftTemplatesPage(),
		SilverGiftDesignPage.routeName:    (_) => const SilverGiftDesignPage   (),
		SilverGiftPreviewPage.routeName:   (_) => const SilverGiftPreviewPage  (),
		
		GoldGiftTemplatesPage.routeName: (_) => const GoldGiftTemplatesPage(),
		GoldGiftDesignPage.routeName:    (_) => const GoldGiftDesignPage   (),
		GoldGiftPreviewPage.routeName:   (_) => const GoldGiftPreviewPage  (),

      },
    );
  }
}