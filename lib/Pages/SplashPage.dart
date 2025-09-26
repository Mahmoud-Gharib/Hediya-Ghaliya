import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hediya_ghaliya/Pages/WelcomePage.dart';
import 'package:hediya_ghaliya/Pages/HomePage.dart';

/********************** SplashPage *************************/

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
  void initState() 
  {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);
    _scale = Tween(begin: 0.85, end: 1.05).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _fade = Tween(begin: 0.6, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    Timer.periodic(const Duration(seconds: 1), (t) 
	{
      if (!mounted) return t.cancel();
      setState(() 
	  {
        _begin = _begin == Alignment.topLeft ? Alignment.topRight : Alignment.topLeft;
        _end = _end == Alignment.bottomRight ? Alignment.bottomLeft : Alignment.bottomRight;
      });
    });

    Timer(const Duration(seconds: 5), () async 
	{
      if (!mounted) return;
      final prefs = await SharedPreferences.getInstance();
      final loggedIn = prefs.getBool('logged_in') ?? false;
      final phone = prefs.getString('phone');
      if (loggedIn && phone != null && phone.isNotEmpty) 
	  {
        Navigator.of(context).pushReplacementNamed(HomePage.routeName, arguments: {'phone': phone});
      } 
	  else 
	  {
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
    return Scaffold
	(
      body: AnimatedContainer
	  (
        duration: const Duration(milliseconds: 900),
        decoration: BoxDecoration
		(
          gradient: LinearGradient
		  (
            begin: _begin,
            end: _end,
            colors: const 
			[
              Color(0xFF7B1FA2), 
              Color(0xFFE91E63),
              Color(0xFFFFC107),
            ],
          ),
        ),
        child: Center
		(
          child: Column
		  (
            mainAxisSize: MainAxisSize.min,
            children: 
			[
              ScaleTransition
			  (
                scale: _scale,
                child: Opacity
				(
                  opacity: _fade.value,
                  child: const Hero
				  (
                    tag: 'splash_logo',
                    child: LogoPulse(size: 180, autoPlay: true),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ShaderMask
			  (
                shaderCallback: (rect) => const LinearGradient(colors: [Colors.white, Color(0xFFFFF59D)])
                    .createShader(Rect.fromLTWH(0, 0, rect.width, rect.height)),
                child: const Text
				(
                  'هدية غالية',
                  style: TextStyle
				  (
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text
			  (
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

/********************** LogoPulse *************************/

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
    _scale = TweenSequence<double>
	(
	 [
      TweenSequenceItem(tween: Tween(begin: 0.96, end: 1.04).chain(CurveTween(curve: Curves.easeOut)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.04, end: 0.96).chain(CurveTween(curve: Curves.easeIn)), weight: 50),
     ]
	).animate(_c);
    _opacity = Tween<double>(begin: 0.9, end: 1.0).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
    if (widget.autoPlay) 
	{
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
    return AnimatedBuilder
	(
      animation: _c,
      builder: (context, _) 
	  {
        return Opacity
		(
          opacity: _opacity.value,
          child: Transform.scale
		  (
            scale: _scale.value,
            child: Image.asset
			(
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